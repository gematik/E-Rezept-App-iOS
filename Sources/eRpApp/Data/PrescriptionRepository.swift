//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import CodedError
import Combine
import Dependencies
import eRpKit
import FeatureCardWall
import Foundation

protocol PrescriptionRepository {
    /// Load Prescriptions from local repository
    func loadLocal(for profileId: UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError>

    /// Load Prescriptions if preconditions are met else require further actions
    func forcedLoadRemote(for locale: String?, for profileId: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>

    /// "Silently" try to load Prescriptions if preconditions are met
    func silentLoadRemote(for locale: String?, for profileId: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>
}

struct DummyPrescriptionRepository: PrescriptionRepository {
    var prescriptions: [Prescription] = [
        ErxTask.Demo.expiredErxTask(with: .ready),
        ErxTask.Demo.expiredErxTask(with: .inProgress),
        ErxTask.Demo.expiredErxTask(with: .computed(status: .dispensed)),
        ErxTask.Demo.expiredErxTask(with: .completed),
    ].map {
        Prescription(erxTask: $0)
    }

    func loadLocal(for _: UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        Just(prescriptions).setFailureType(to: PrescriptionRepositoryError.self).eraseToAnyPublisher()
    }

    func forcedLoadRemote(for _: String?, for _: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
    }

    func silentLoadRemote(for _: String?, for _: UUID)
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
    // There seems to be no real difference between .notAuthenticated and .authenticationRequired result-wise
    // but rather indicating how the callee should proceed:
    //  - notAuthenticated: informative
    //  - authenticationRequired: insinuated more action(s): present cardwall, ask user how to proceed, ... etc.
}

@CodedError("027")
enum PrescriptionRepositoryError: Error, Equatable {
    @ErrorCode("01")
    case loginHandler(LoginHandlerError)
    @ErrorCode("02")
    case erxRepository(ErxRepositoryError)
}

class DefaultPrescriptionRepository: PrescriptionRepository, ActivityIndicating {
    init(loginHandler: LoginHandler) {
        self.loginHandler = loginHandler
    }

    let loginHandler: LoginHandler
    @Dependency(\.erxTaskRepository) var erxTaskRepository

    var isActive: AnyPublisher<Bool, Never> {
        isActivePublisher.removeDuplicates().eraseToAnyPublisher()
    }

    // TODO: maybe int? // swiftlint:disable:this todo
    private var isActivePublisher = CurrentValueSubject<Bool, Never>(false)

    func loadLocal(for profileId: UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        @Dependency(\.schedulers) var schedulers

        return erxTaskRepository.loadLocalAllTasks(profileId)
            .mapError { PrescriptionRepositoryError.erxRepository($0.asErxRepositoryError()) }
            .receive(on: schedulers.main)
            .map {
                $0.map {
                    Prescription(erxTask: $0)
                }
            }
            .eraseToAnyPublisher()
    }

    func silentLoadRemote(for locale: String?, for profileId: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        isActivePublisher.send(true)

        return withEscapedDependencies { dependencies in
            loginHandler
                .isAuthenticated()
                .setFailureType(to: PrescriptionRepositoryError.self)
                .first()
                .flatMap { isAuthenticated in
                    if Result.success(true) == isAuthenticated {
                        return dependencies.yield {
                            self.loadRemoteAndSave(for: locale, for: profileId)
                        }
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
    }

    private func loadRemoteAndSave(for locale: String?, for profileId: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        @Dependency(\.schedulers) var schedulers
        return Future {
            return try await self.erxTaskRepository.loadRemoteAllTasks(locale, profileId)
        }
        .receive(on: schedulers.main)
        .mapError { PrescriptionRepositoryError.erxRepository($0.asErxRepositoryError()) }
        .map {
            $0.map {
                Prescription(erxTask: $0)
            }
        }
        .map(PrescriptionRepositoryLoadRemoteResult.prescriptions)
        .first()
        .eraseToAnyPublisher()
    }

    func forcedLoadRemote(for locale: String?, for profileId: UUID)
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        isActivePublisher.send(true)
        return withEscapedDependencies { dependencies in
            loginHandler
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
                        return dependencies.yield {
                            return self.loadRemoteAndSave(for: locale, for: profileId)
                        }
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
