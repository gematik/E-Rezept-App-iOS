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

import AsyncHelpers
import CodedError
import Combine
import ConsentService
import Dependencies
import eRpKit
import ErxTaskRepository
import FeatureCardWall
import Foundation
import IDP

protocol ChargeItemListDomainService {
    /// Fetches charge items from the local store
    func fetchLocalChargeItems(for profileId: UUID) ->
        AnyPublisher<ChargeItemDomainServiceFetchResult, Never>

    /// Tries to fetch the Charge Items from the remote store
    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>

    /// Tries to delete a Charge Item from the remote store and on success on the local store as well
    func delete(chargeItem: ErxChargeItem, for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never>

    /// Performs an authentication of the user
    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>

    /// Grant a consent to the server to emit the user's Charge Items
    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never>

    /// Tries to fetch the Charge Items from the repository w/o requesting the consent state (e.g. was just granted)
    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>

    /// Tries to revoke the consent given for handling Charge Items.
    /// Since the Charge Items are then deleted on the server, a local deletion is performed afterwards
    /// and the results are aggregated
    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never>
}

enum ChargeItemDomainServiceFetchResult: Equatable {
    case success([ErxSparseChargeItem])
    case notAuthenticated
    case consentNotGranted
    case error(Error)

    @CodedError("030")
    enum Error: Equatable, Swift.Error {
        @ErrorCode("01")
        case localStore(LocalStoreError)
        @ErrorCode("02")
        case loginHandler(LoginHandlerError)
        @ErrorCode("03")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("04")
        case unexpected
        @ErrorCode("05")
        case consentService(ConsentService.Error)
    }
}

// swiftlint:disable:next type_name
enum ChargeItemDomainServiceAuthenticateResult: Equatable {
    case success
    case furtherAuthenticationRequired
    case error(Error)

    @CodedError("031")
    enum Error: Equatable, Swift.Error {
        @ErrorCode("01")
        case loginHandler(LoginHandlerError)
        @ErrorCode("02")
        case unexpected
    }
}

enum ChargeItemListDomainServiceGrantResult: Equatable {
    // successful
    case success // 201
    case conflict // 409 the user's consent has already been given

    // login handler
    case notAuthenticated

    case error(Error)

    @CodedError("032")
    enum Error: Equatable, Swift.Error {
        @ErrorCode("01")
        case localStore(LocalStoreError)
        @ErrorCode("02")
        case loginHandler(LoginHandlerError)
        @ErrorCode("03")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("04")
        case unexpectedGrantConsentResponse
        @ErrorCode("05")
        case unexpected
        @ErrorCode("06")
        case consentService(ConsentService.Error)
    }
}

enum ChargeItemListDomainServiceRevokeResult: Equatable {
    case success(ChargeItemDomainServiceDeleteResult)
    case notAuthenticated
    case conflict
    case error(Error)

    @CodedError("033")
    enum Error: Equatable, Swift.Error {
        @ErrorCode("01")
        case localStore(LocalStoreError)
        @ErrorCode("02")
        case loginHandler(LoginHandlerError)
        @ErrorCode("03")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("04")
        case unexpected
        @ErrorCode("05")
        case consentService(ConsentService.Error)
    }
}

enum ChargeItemDomainServiceDeleteResult: Equatable {
    case success
    case notAuthenticated
    case error(Error)

    @CodedError("034")
    enum Error: Equatable, Swift.Error {
        @ErrorCode("01")
        case localStore(LocalStoreError)
        @ErrorCode("02")
        case loginHandler(LoginHandlerError)
        @ErrorCode("03")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("04")
        case unexpected
    }
}

struct DefaultChargeItemListDomainService: ChargeItemListDomainService {
    let userSessionProvider: UserSessionProvider
    let consentService: ConsentService

    private func loginHandler(for profileId: UUID) -> LoginHandler {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.idpSessionLoginHandler
    }

    func fetchLocalChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        return Future {
            try await erxTaskRepository.loadLocalAllChargeItems(profileId)
        }
        .mapError { $0.asErxRepositoryError() }
        .first()
        .map { .success($0) }
        .catch { error in
            Just(ChargeItemDomainServiceFetchResult.error(.erxRepository(error)))
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        return Future<ConsentService.CheckResult, Swift.Error> {
            try await consentService.checkForConsent(.chargcons, profileId)
        }
        .mapError { error in
            guard let error = error as? ConsentService.Error
            else { return ConsentService.Error.unexpected }
            return error
        }
        .flatMap { consentServiceResult -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
            switch consentServiceResult {
            case .granted:
                return Future {
                    try await erxTaskRepository.loadRemoteChargeItems(profileId)
                }
                .mapError { $0.asErxRepositoryError() }
                .first()
                .map { ChargeItemDomainServiceFetchResult.success($0) }
                .catch { error in
                    Just(ChargeItemDomainServiceFetchResult.error(.erxRepository(error))).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            case .notGranted:
                return Just(ChargeItemDomainServiceFetchResult.consentNotGranted).eraseToAnyPublisher()
            case .notAuthenticated:
                return Just(ChargeItemDomainServiceFetchResult.notAuthenticated).eraseToAnyPublisher()

            case let .error(error):
                return Just(.error(.consentService(error))).eraseToAnyPublisher()
            }
        }
        .catch { error -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
            Just(.error(.consentService(error))).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func delete(
        chargeItem: ErxChargeItem,
        for profileId: UUID
    ) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        let loginHandler = loginHandler(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { profile -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> in
                            guard profile.insuranceId != nil else {
                                // At this point, we expect the profile to be associated with a insuranceId
                                return Just(.error(.unexpected))
                                    .eraseToAnyPublisher()
                            }
                            return Future {
                                try await erxTaskRepository.deleteChargeItems([chargeItem], profileId)
                            }
                            .mapError { $0.asErxRepositoryError() }
                            .first()
                            .map { _ in .success }
                            .catch { error in
                                Just(ChargeItemDomainServiceDeleteResult.error(.erxRepository(error)))
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> in
                            Just(.error(.localStore(error))).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()

                case LoginResult.success(false):
                    return Just(.notAuthenticated).eraseToAnyPublisher()
                case let LoginResult.failure(error):
                    return Just(.error(.loginHandler(error))).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .map { loginResult in
                switch loginResult {
                case .success(true):
                    return ChargeItemDomainServiceAuthenticateResult.success
                case .success(false):
                    return ChargeItemDomainServiceAuthenticateResult.furtherAuthenticationRequired
                case let .failure(loginHandlerError):
                    return ChargeItemDomainServiceAuthenticateResult.error(.loginHandler(loginHandlerError))
                }
            }
            .eraseToAnyPublisher()
    }

    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> {
        Future<ConsentService.GrantResult, Swift.Error> {
            try await consentService.grantConsent(.chargcons, profileId)
        }
        .mapError { error in
            guard let error = error as? ConsentService.Error
            else { return ConsentService.Error.unexpected }
            return error
        }
        .map { consentServiceResult -> ChargeItemListDomainServiceGrantResult in
            switch consentServiceResult {
            case .success: return .success
            case .conflict: return .conflict
            case .notAuthenticated: return .notAuthenticated
            case let .error(error):
                return ChargeItemListDomainServiceGrantResult.error(.consentService(error))
            }
        }
        .catch { error -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> in
            Just(.error(.consentService(error))).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        let loginHandler = loginHandler(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
                switch loginResult {
                case LoginResult.success(true):
                    return Future {
                        try await erxTaskRepository.loadRemoteChargeItems(profileId)
                    }
                    .mapError { $0.asErxRepositoryError() }
                    .first()
                    .map { .success($0) }
                    .catch { error in
                        Just(ChargeItemDomainServiceFetchResult.error(.erxRepository(error)))
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
                case LoginResult.success(false):
                    return Just(.notAuthenticated).eraseToAnyPublisher()
                case let LoginResult.failure(error):
                    return Just(.error(.loginHandler(error))).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> {
        Future<ConsentService.RevokeResult, Swift.Error> {
            try await consentService.revokeConsent(.chargcons, profileId)
        }
        .mapError { error in
            guard let error = error as? ConsentService.Error
            else { return ConsentService.Error.unexpected }
            return error
        }
        .flatMap { consentServiceResult -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
            switch consentServiceResult {
            case .success:
                return deleteAllLocalChargeItems(for: profileId)
                    .first()
                    .map { .success($0) }
                    .eraseToAnyPublisher()
            case .notAuthenticated:
                return Just(.notAuthenticated).eraseToAnyPublisher()
            case .conflict: return Just(.conflict).eraseToAnyPublisher()
            case let .error(error):
                return Just(ChargeItemListDomainServiceRevokeResult.error(.consentService(error)))
                    .eraseToAnyPublisher()
            }
        }
        .catch { error -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
            Just(.error(.consentService(error))).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func deleteAllLocalChargeItems(for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        let chargeItemsPublisher: AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> = Future {
            try await erxTaskRepository.loadLocalAllChargeItems(profileId)
        }
        .mapError { $0.asErxRepositoryError() }
        .eraseToAnyPublisher()

        return chargeItemsPublisher
            .first()
            .flatMap { chargeItems in
                Future {
                    try await erxTaskRepository.deleteLocalChargeItems(chargeItems.compactMap(\.chargeItem), profileId)
                }
                .mapError { $0.asErxRepositoryError() }
                .first()
                .map { _ in ChargeItemDomainServiceDeleteResult.success }
                .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> in
                Just(ChargeItemDomainServiceDeleteResult.error(.erxRepository(error)))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == ChargeItemDomainServiceDeleteResult,
    Failure == ConsentService.Error {
    func eraseToResult() -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> {
        map { .success($0) }
            .catch { error in
                Just(.error(.consentService(error)))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: TCA Dependency

extension DefaultChargeItemListDomainService {
    static let live: Self = DefaultChargeItemListDomainService(
        userSessionProvider: UserSessionProviderDependency
            .liveValue,
        consentService: ConsentService.liveValue
    )
}

struct ChargeItemListDomainServiceDependency: DependencyKey {
    static let liveValue: ChargeItemListDomainService = DefaultChargeItemListDomainService.live
    static let previewValue: ChargeItemListDomainService = DummyChargeItemListDomainService()
    static let testValue: ChargeItemListDomainService = UnimplementedChargeItemListDomainService()
}

extension DependencyValues {
    var chargeItemsDomainService: ChargeItemListDomainService {
        get { self[ChargeItemListDomainServiceDependency.self] }
        set { self[ChargeItemListDomainServiceDependency.self] = newValue }
    }
}
