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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import IDP

protocol RegisteredDevicesService {
    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError>

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never>

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError>

    func cardWall(for profileId: UUID) -> AnyPublisher<CardWallCANDomain.State, Never>
}

// sourcery: CodedError = "018"
enum RegisteredDevicesServiceError: Swift.Error, Equatable, LocalizedError {
    // sourcery: errorCode = "01"
    case missingAuthentication
    // sourcery: errorCode = "02"
    case missingToken
    // sourcery: errorCode = "03"
    case loginHandlerError(LoginHandlerError)
    // sourcery: errorCode = "04"
    case idpError(IDPError)

    var errorDescription: String? {
        switch self {
        case .missingAuthentication:
            return "Authentication expected but failed, logout to proceed"
        case .missingToken:
            return "SSO for existing Token failed, logout and retry"
        case let .loginHandlerError(error):
            return error.localizedDescription
        case let .idpError(error):
            return "IDP Error: \(error.localizedDescription)"
        }
    }
}

struct DefaultRegisteredDevicesService: RegisteredDevicesService {
    let userSessionProvider: UserSessionProvider

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        let userSession = userSessionProvider.userSession(for: profileId)
        let idpSession = userSession.pairingIdpSession
        let loginHandler = userSession.pairingIdpSessionLoginHandler

        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { isAuthenticated -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> in
                guard Result.success(false) != isAuthenticated else {
                    return Fail(error: RegisteredDevicesServiceError.missingAuthentication)
                        .eraseToAnyPublisher()
                }

                if case let Result.failure(error) = isAuthenticated {
                    return Fail(error: RegisteredDevicesServiceError.loginHandlerError(error))
                        .eraseToAnyPublisher()
                } else {
                    return idpSession.autoRefreshedToken
                        .first()
                        .mapError(RegisteredDevicesServiceError.idpError)
                        .flatMap { token -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> in
                            guard let token = token else {
                                return Fail(error: RegisteredDevicesServiceError.missingToken)
                                    .eraseToAnyPublisher()
                            }

                            return idpSession.listDevices(token: token)
                                .mapError(RegisteredDevicesServiceError.idpError)
                                .first()
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        let userSession = userSessionProvider.userSession(for: profileId)
        return userSession.secureUserStore.keyIdentifier.first()
            .map { identifier in
                guard let identifier = identifier,
                      let base64Identifier = identifier.encodeBase64UrlSafe() else {
                    return nil
                }
                return String(data: base64Identifier, encoding: .utf8)
            }
            .eraseToAnyPublisher()
    }

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        let userSession = userSessionProvider.userSession(for: profileId)
        let idpSession = userSession.pairingIdpSession

        return idpSession.autoRefreshedToken
            .mapError(RegisteredDevicesServiceError.idpError)
            .first()
            .flatMap { token -> AnyPublisher<Bool, RegisteredDevicesServiceError> in
                guard let token = token else {
                    return Fail(error: RegisteredDevicesServiceError.missingToken)
                        .eraseToAnyPublisher()
                }

                return idpSession.unregisterDevice(device, token: token)
                    .mapError(RegisteredDevicesServiceError.idpError)
                    .first()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func cardWall(for profileId: UUID) -> AnyPublisher<CardWallCANDomain.State, Never> {
        let userSession = userSessionProvider.userSession(for: profileId)
        let userDataStore = userSession.secureUserStore

        return userDataStore.can
            .first()
            .map { can in
                CardWallCANDomain.State(
                    isDemoModus: userSession.isDemoMode,
                    profileId: userSession.profileId,
                    can: can ?? ""
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: TCA Dependency

extension DefaultRegisteredDevicesService {
    static let live: Self = .init(userSessionProvider: UserSessionProviderDependency.liveValue)
}

struct RegisteredDevicesServiceDependency: DependencyKey {
    static let liveValue: RegisteredDevicesService = DefaultRegisteredDevicesService.live

    static let testValue: RegisteredDevicesService = UnimplementedRegisteredDevicesService()
}

extension DependencyValues {
    var registeredDevicesService: RegisteredDevicesService {
        get { self[RegisteredDevicesServiceDependency.self] }
        set { self[RegisteredDevicesServiceDependency.self] = newValue }
    }
}
