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

protocol ChargeItemsDomainService {
    /// Tries to fetch the Charge Items from the repository
    func fetchChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>

    /// Performs an authentication of the user
    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>

    /// Grant a consent to the server to emit the user's Charge Items
    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never>

    /// Tries to fetch the Charge Items from the repository w/o requesting the consent state (e.g. was just granted)
    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID)
        -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>

    /// Tries to revoke the consent given for handling Charge Items.
    /// Since the Charge Items are then deleted on the server, a local deletion is performed afterwards
    /// and the results are aggregated
    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never>
}

enum ChargeItemDomainServiceFetchResult: Equatable {
    case success([ErxChargeItem])
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

enum ChargeItemsDomainServiceGrantResult: Equatable {
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

enum ChargeItemsDomainServiceRevokeResult: Equatable {
    case success(ChargeItemsDomainServiceDeleteResult)
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

enum ChargeItemsDomainServiceDeleteResult: Equatable {
    case success
    case error(Error)

    // sourcery: CodedError = "034"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case unexpected
    }
}

struct DefaultChargeItemsDomainService: ChargeItemsDomainService {
    let userSessionProvider: UserSessionProvider

    private func loginHandler(for profileId: UUID) -> LoginHandler {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.idpSessionLoginHandler
    }

    private func erxTaskRepository(for profileId: UUID) -> ErxTaskRepository {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.erxTaskRepository
    }

    func fetchChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
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

    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { profile -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> in
                            guard let insuranceId = profile.insuranceId else {
                                // At this point, we expect the profile to be associated with an insuranceId
                                return Just(.error(.unexpected))
                                    .eraseToAnyPublisher()
                            }
                            let chargeItemsConsent = Self.createChargeItemsConsent(insuranceId: insuranceId)
                            return erxTaskRepository.grantConsent(chargeItemsConsent)
                                .first()
                                .map { receivedConsent -> ChargeItemsDomainServiceGrantResult in
                                    if Self.checkForValidChargeItemsConsent(receivedConsent, for: insuranceId) {
                                        return .success
                                    } else {
                                        return .error(.unexpectedGrantConsentResponse)
                                    }
                                }
                                .catch { error -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> in
                                    Just(.error(.erxRepository(error))).eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> in
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

    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> {
        let loginHandler = loginHandler(for: profileId)
        let erxTaskRepository = erxTaskRepository(for: profileId)
        let userSession = userSessionProvider.userSession(for: profileId)

        return loginHandler.isAuthenticated()
            .first()
            .flatMap { (loginResult: LoginResult) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> in
                switch loginResult {
                case .success(true):
                    return userSession.profile()
                        .first()
                        .flatMap { _ -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> in
                            erxTaskRepository.revokeConsent(.chargcons)
                                .first()
                                .flatMap { wasSuccessful -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> in
                                    switch wasSuccessful {
                                    case true:
                                        return self.deleteAllLocalChargeItems(for: profileId)
                                            .first()
                                            .map(ChargeItemsDomainServiceRevokeResult.success)
                                            .eraseToAnyPublisher()
                                    case false:
                                        return Just(.error(.unexpected))
                                            .eraseToAnyPublisher() //  either true or error is returned
                                    }
                                }
                                .catch { error -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> in
                                    Just(.error(.erxRepository(error))).eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                        .catch { error -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> in
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

    private func deleteAllLocalChargeItems(for _: UUID) -> AnyPublisher<ChargeItemsDomainServiceDeleteResult, Never> {
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

struct DummyChargeItemsDomainService: ChargeItemsDomainService {
    func fetchChargeItems(for _: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        Just(.success([
            ErxChargeItem(identifier: "abc1", fhirData: Data(), enteredDate: "2022-07-12T10:24:47+02:00"),
            ErxChargeItem(identifier: "abc2", fhirData: Data(), enteredDate: "2023-07-12T10:24:47+02:00"),
            ErxChargeItem(identifier: "abc3", fhirData: Data(), enteredDate: "2022-07-19T10:24:47+02:00"),
            ErxChargeItem(identifier: "abc4", fhirData: Data(), enteredDate: "2022-07-18T10:24:47+02:00"),
        ])).eraseToAnyPublisher()
    }

    func authenticate(for _: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never> {
        Just(.success).eraseToAnyPublisher()
    }

    func grantChargeItemsConsent(for _: UUID) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> {
        Just(.success).eraseToAnyPublisher()
    }

    func fetchChargeItemsAssumingConsentGranted(for _: UUID)
        -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        Just(.success([])).eraseToAnyPublisher()
    }

    func revokeChargeItemsConsent(for _: UUID) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> {
        Just(.success(.success)).eraseToAnyPublisher()
    }
}

// MARK: TCA Dependency

extension DefaultChargeItemsDomainService {
    static let live: Self = DefaultChargeItemsDomainService(userSessionProvider: UserSessionProviderDependency
        .liveValue)
}

struct ChargeItemsDomainServiceDependency: DependencyKey {
    static let liveValue: ChargeItemsDomainService = DefaultChargeItemsDomainService.live
    static let previewValue: ChargeItemsDomainService = DummyChargeItemsDomainService()
    static let testValue: ChargeItemsDomainService = UnimplementedChargeItemsDomainService()
}

extension DependencyValues {
    var chargeItemsDomainService: ChargeItemsDomainService {
        get { self[ChargeItemsDomainServiceDependency.self] }
        set { self[ChargeItemsDomainServiceDependency.self] = newValue }
    }
}
