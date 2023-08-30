//
//  Copyright (c) 2023 gematik GmbH
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

    // sourcery: CodedError = "030"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "03"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "04"
        case unexpected
    }
}

// swiftlint:disable:next type_name
enum ChargeItemDomainServiceAuthenticateResult: Equatable {
    case success
    case furtherAuthenticationRequired
    case error(Error)

    // sourcery: CodedError = "031"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "02"
        case unexpected
    }
}

enum ChargeItemListDomainServiceGrantResult: Equatable {
    case success
    case notAuthenticated
    case error(Error)

    // sourcery: CodedError = "032"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "03"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "04"
        case unexpectedGrantConsentResponse
        // sourcery: errorCode = "05"
        case unexpected
    }
}

enum ChargeItemListDomainServiceRevokeResult: Equatable {
    case success(ChargeItemDomainServiceDeleteResult)
    case notAuthenticated
    case error(Error)

    // sourcery: CodedError = "033"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "03"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "04"
        case unexpected
    }
}

enum ChargeItemDomainServiceDeleteResult: Equatable {
    case success
    case notAuthenticated
    case error(Error)

    // sourcery: CodedError = "034"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "03"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "04"
        case unexpected
    }
}

// swiftlint:disable:next type_body_length
struct DefaultChargeItemListDomainService: ChargeItemListDomainService {
    let userSessionProvider: UserSessionProvider

    private func loginHandler(for profileId: UUID) -> LoginHandler {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.idpSessionLoginHandler
    }

    private func erxTaskRepository(for profileId: UUID) -> ErxTaskRepository {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.erxTaskRepository
    }

    func fetchLocalChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        let erxTaskRepository = erxTaskRepository(for: profileId)
        return erxTaskRepository.loadLocalAll()
            .first()
            .map { .success($0) }
            .catch { error in
                Just(ChargeItemDomainServiceFetchResult.error(.erxRepository(error)))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { profile -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
                            guard let insuranceId = profile.insuranceId else {
                                // At this point, we expect the profile to be associated with a insuranceId
                                return Just(.error(.unexpected))
                                    .eraseToAnyPublisher()
                            }
                            return erxTaskRepository.fetchConsents()
                                .first()
                                .flatMap { erxConsents in
                                    if Self.checkForValidChargeItemsConsent(erxConsents, for: insuranceId) {
                                        return erxTaskRepository.loadRemoteChargeItems()
                                            .first()
                                            .map { .success($0) }
                                            .catch { error in
                                                Just(ChargeItemDomainServiceFetchResult.error(.erxRepository(error)))
                                                    .eraseToAnyPublisher()
                                            }
                                            .eraseToAnyPublisher()
                                    } else {
                                        return Just(ChargeItemDomainServiceFetchResult.consentNotGranted)
                                            .eraseToAnyPublisher()
                                    }
                                }
                                .catch { error -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
                                    Just(.error(.erxRepository(error))).eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
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

    func delete(
        chargeItem: ErxChargeItem,
        for profileId: UUID
    ) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
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
                            return erxTaskRepository.delete(chargeItems: [chargeItem])
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
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { profile -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> in
                            guard let insuranceId = profile.insuranceId else {
                                // At this point, we expect the profile to be associated with an insuranceId
                                return Just(.error(.unexpected))
                                    .eraseToAnyPublisher()
                            }
                            let chargeItemsConsent = Self.createChargeItemsConsent(insuranceId: insuranceId)
                            return erxTaskRepository.grantConsent(chargeItemsConsent)
                                .first()
                                .map { receivedConsent -> ChargeItemListDomainServiceGrantResult in
                                    if Self.checkForValidChargeItemsConsent(receivedConsent, for: insuranceId) {
                                        return .success
                                    } else {
                                        return .error(.unexpectedGrantConsentResponse)
                                    }
                                }
                                .catch { error -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> in
                                    Just(.error(.erxRepository(error))).eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> in
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

    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> in
                switch loginResult {
                case LoginResult.success(true):
                    return erxTaskRepository.loadRemoteChargeItems()
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
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { _ -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
                            erxTaskRepository.revokeConsent(.chargcons)
                                .first()
                                .flatMap { wasSuccessful -> AnyPublisher<
                                    ChargeItemListDomainServiceRevokeResult, Never
                                > in
                                switch wasSuccessful {
                                case true:
                                    return self.deleteAllLocalChargeItems(for: profileId)
                                        .first()
                                        .map(ChargeItemListDomainServiceRevokeResult.success)
                                        .eraseToAnyPublisher()
                                case false:
                                    return Just(.error(.unexpected))
                                        .eraseToAnyPublisher() //  either true or error is returned
                                }
                                }
                                .catch { error -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
                                    Just(.error(.erxRepository(error))).eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> in
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

    private func deleteAllLocalChargeItems(for _: UUID)
        -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        Just(.success).eraseToAnyPublisher() // to-do: integration
    }

    private static func checkForValidChargeItemsConsent(_ erxConsents: [ErxConsent], for insuranceId: String) -> Bool {
        erxConsents.contains { erxConsent in
            checkForValidChargeItemsConsent(erxConsent, for: insuranceId)
        }
    }

    private static func checkForValidChargeItemsConsent(_ erxConsent: ErxConsent?, for insuranceId: String) -> Bool {
        guard let erxConsent else { return false }
        return erxConsent.category == .chargcons && erxConsent.insuranceId == insuranceId
    }

    private static func createChargeItemsConsent(insuranceId: String) -> ErxConsent {
        ErxConsent(
            identifier: "\(ErxConsent.Category.chargcons.rawValue)-\(insuranceId)",
            insuranceId: insuranceId,
            timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
            scope: .patientPrivacy,
            category: .chargcons,
            policyRule: .optIn
        )
    }
}

// MARK: TCA Dependency

extension DefaultChargeItemListDomainService {
    static let live: Self = DefaultChargeItemListDomainService(userSessionProvider: UserSessionProviderDependency
        .liveValue)
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
