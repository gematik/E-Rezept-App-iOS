//
//  Copyright (c) 2024 gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//
//      https://joinup.ec.europa.eu/software/page/eupl
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//
//

import Combine
import Dependencies
import eRpKit

protocol PrescriptionRepository {
    /// Load Prescriptions from local repository
    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError>

    /// Load Prescriptions if preconditions are met else require further actions
    func forcedLoadRemote(for locale: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>

    /// "Silently" try to load Prescriptions if preconditions are met
    func silentLoadRemote(for locale: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>
}

struct DummyPrescriptionRepository: PrescriptionRepository {
    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        Just([]).setFailureType(to: PrescriptionRepositoryError.self).eraseToAnyPublisher()
    }

    func forcedLoadRemote(for _: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
    }

    func silentLoadRemote(for _: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
    }
}

enum PrescriptionRepositoryLoadRemoteResult: Equatable {
    case prescriptions([Prescription])
    case notAuthenticated
    case authenticationRequired
}

// sourcery: CodedError = "027"
enum PrescriptionRepositoryError: Error, Equatable {
    // sourcery: errorCode = "01"
    case loginHandler(LoginHandlerError)
    // sourcery: errorCode = "02"
    case erxRepository(ErxRepositoryError)
}

class DefaultPrescriptionRepository: PrescriptionRepository, ActivityIndicating {
    init(loginHandler: LoginHandler, erxTaskRepository: ErxTaskRepository) {
        self.loginHandler = loginHandler
        self.erxTaskRepository = erxTaskRepository
    }

    let loginHandler: LoginHandler
    let erxTaskRepository: ErxTaskRepository

    var isActive: AnyPublisher<Bool, Never> {
        isActivePublisher.removeDuplicates().eraseToAnyPublisher()
    }

    // TODO: maybe int? // swiftlint:disable:this todo
    private var isActivePublisher = CurrentValueSubject<Bool, Never>(false)

    @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        erxTaskRepository.loadLocalAll()
            .map {
                $0.map { Prescription(erxTask: $0, dateFormatter: self.uiDateFormatter) }
            }
            .mapError(PrescriptionRepositoryError.erxRepository)
            .eraseToAnyPublisher()
    }

    func silentLoadRemote(for locale: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        isActivePublisher.send(true)

        return loginHandler
            .isAuthenticated()
            .setFailureType(to: PrescriptionRepositoryError.self)
            .first()
            .flatMap { isAuthenticated in
                if Result.success(true) == isAuthenticated {
                    return self.loadRemoteAndSave(for: locale)
                } else {
                    return Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .eraseToAnyPublisher()
                }
            }
            .handleEvents(
                receiveCompletion: ({ [weak self] _ in
                    self?.isActivePublisher.send(false)
                }),
                receiveCancel: ({ [weak self] in
                    self?.isActivePublisher.send(false)
                })
            )
            .eraseToAnyPublisher()
    }

    private func loadRemoteAndSave(for locale: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        erxTaskRepository
            .loadRemoteAll(for: locale)
            .map {
                $0.map { Prescription(erxTask: $0, dateFormatter: self.uiDateFormatter) }
            }
            .map(PrescriptionRepositoryLoadRemoteResult.prescriptions)
            .mapError(PrescriptionRepositoryError.erxRepository)
            .first()
            .eraseToAnyPublisher()
    }

    func forcedLoadRemote(for locale: String?)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        isActivePublisher.send(true)

        return loginHandler
            .isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { isAuthenticated in
                // [REQ:gemSpec_eRp_FdV:A_20167-02#2,A_20172] no token/not authorized, show authenticator module
                if Result.success(false) == isAuthenticated {
                    return Just(PrescriptionRepositoryLoadRemoteResult.authenticationRequired)
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .eraseToAnyPublisher()
                }
                if case let Result.failure(error) = isAuthenticated {
                    return Fail(error: PrescriptionRepositoryError.loginHandler(error))
                        .eraseToAnyPublisher()
                } else {
                    return self.loadRemoteAndSave(for: locale)
                }
            }
            .handleEvents(
                receiveCompletion: ({ [weak self] _ in
                    self?.isActivePublisher.send(false)
                })
            )
            .eraseToAnyPublisher()
    }
}

struct PrescriptionRepositoryDependency: DependencyKey {
    static let liveValue: PrescriptionRepository? = nil

    static var previewValue: PrescriptionRepository? = DummyPrescriptionRepository()

    static var testValue: PrescriptionRepository? = UnimplementedPrescriptionRepository()
}

extension DependencyValues {
    var prescriptionRepository: PrescriptionRepository {
        get {
            self[PrescriptionRepositoryDependency.self] ?? changeableUserSessionContainer.userSession
                .prescriptionRepository
        }
        set { self[PrescriptionRepositoryDependency.self] = newValue }
    }
}
