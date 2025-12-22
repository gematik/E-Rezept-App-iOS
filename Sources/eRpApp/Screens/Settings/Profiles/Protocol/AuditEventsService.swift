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
import ComposableArchitecture
import eRpKit
import ErxTaskRepository
import FeatureCardWall
import Foundation
import IDP

protocol AuditEventsService {
    func loadAuditEvents(for profileId: UUID, locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>

    func loadNextAuditEvents(for profileId: UUID, url: URL, locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>
}

@CodedError("028")
enum AuditEventsServiceError: Error, Equatable, LocalizedError {
    @ErrorCode("01")
    case missingAuthentication
    @ErrorCode("02")
    case loginHandlerError(LoginHandlerError)
    @ErrorCode("03")
    case erxRepositoryError(ErxRepositoryError)

    var errorDescription: String? {
        switch self {
        case .missingAuthentication:
            return "Authentication expected but failed, logout to proceed"
        case let .loginHandlerError(error):
            return error.localizedDescription
        case let .erxRepositoryError(error):
            return error.localizedDescription
        }
    }
}

struct DefaultAuditEventsService: AuditEventsService {
    let userSessionProvider: UserSessionProvider
    @Dependency(\.erxTaskRepository) var erxTaskRepository

    func loadAuditEvents(for profileId: UUID,
                         locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        let userSession = userSessionProvider.userSession(for: profileId)
        let loginHandler = userSession.idpSessionLoginHandler

        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { isAuthenticated -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> in
                guard Result.success(false) != isAuthenticated else {
                    return Fail(error: AuditEventsServiceError.missingAuthentication)
                        .eraseToAnyPublisher()
                }

                if case let Result.failure(error) = isAuthenticated {
                    return Fail(error: AuditEventsServiceError.loginHandlerError(error))
                        .eraseToAnyPublisher()
                }

                return Future {
                    try await erxTaskRepository.loadRemoteLatestAuditEvents(locale)
                }
                .mapError { AuditEventsServiceError.erxRepositoryError($0.asErxRepositoryError()) }
                .first()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func loadNextAuditEvents(
        for profileId: UUID,
        url: URL,
        locale: String?
    ) -> AnyPublisher<
        eRpKit.PagedContent<[eRpKit.ErxAuditEvent]>,
        AuditEventsServiceError
    > {
        let userSession = userSessionProvider.userSession(for: profileId)
        let loginHandler = userSession.idpSessionLoginHandler

        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { isAuthenticated -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> in
                guard Result.success(false) != isAuthenticated else {
                    return Fail(error: AuditEventsServiceError.missingAuthentication)
                        .eraseToAnyPublisher()
                }

                if case let Result.failure(error) = isAuthenticated {
                    return Fail(error: AuditEventsServiceError.loginHandlerError(error))
                        .eraseToAnyPublisher()
                }

                return Future {
                    try await erxTaskRepository.loadRemoteAuditEvents(url, locale)
                }
                .mapError { AuditEventsServiceError.erxRepositoryError($0.asErxRepositoryError()) }
                .first()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: TCA Dependency

extension DefaultAuditEventsService {
    static let live: Self = .init(userSessionProvider: UserSessionProviderDependency.liveValue)
}

struct DefaultAuditEventsServiceDependency: DependencyKey {
    static let liveValue: AuditEventsService = DefaultAuditEventsService.live

    static let testValue: AuditEventsService = UnimplementedAuditEventsService()
}

extension DependencyValues {
    var auditEventsService: AuditEventsService {
        get { self[DefaultAuditEventsServiceDependency.self] }
        set { self[DefaultAuditEventsServiceDependency.self] = newValue }
    }
}
