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
import Combine
import Dependencies
import eRpKit
import ErxTaskRepository
import FeatureCardWall
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy

protocol RedeemService {
    func redeem(_ orders: [OrderRequest], profileId: UUID)
        -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>
    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId: UUID)
        -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>
}

struct RedeemServiceDependency: DependencyKey {
    // Is initially unimplemented because there is no reasonable default
    // Use the dependency values from `ErxTaskRepositoryRedeemService` to override
    static let liveValue: RedeemService = UnimplementedRedeemService()
    static let previewValue: RedeemService = DemoRedeemService()
}

extension DependencyValues {
    var redeemService: RedeemService {
        get { self[RedeemServiceDependency.self] }
        set { self[RedeemServiceDependency.self] = newValue }
    }
}

struct ErxTaskRepositoryRedeemService: RedeemService {
    @Dependency(\.erxTaskRepository) var erxTaskRepository
    let loginHandler: LoginHandler

    func redeem(_ orders: [OrderRequest],
                profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        loginHandler
            .isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { authenticated -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> in
                // [REQ:gemSpec_eRp_FdV:A_20167-02#3,A_20172] no token/not authorized, show authenticator module
                if Result.success(false) == authenticated {
                    return Fail(error: RedeemServiceError.noTokenAvailable).eraseToAnyPublisher()
                }
                if case let Result.failure(error) = authenticated {
                    return Fail(error: RedeemServiceError.loginHandler(error: error)).eraseToAnyPublisher()
                } else {
                    return checkAndRedeemViaRepository(orders: orders, profileId: profileId)
                        .mapError(RedeemServiceError.from)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId _: UUID)
        -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> {
        loginHandler
            .isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { authenticated -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> in
                // [REQ:gemSpec_eRp_FdV:A_20167-02#3,A_20172] no token/not authorized, show authenticator module
                if Result.success(false) == authenticated {
                    return Fail(error: RedeemServiceError.noTokenAvailable).eraseToAnyPublisher()
                }
                if case let Result.failure(error) = authenticated {
                    return Fail(error: RedeemServiceError.loginHandler(error: error)).eraseToAnyPublisher()
                } else {
                    return redeemViaRepositoryDiGa(orders: orders)
                        .mapError(RedeemServiceError.from)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func checkAndRedeemViaRepository(
        orders: [OrderRequest],
        profileId: UUID
    ) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        @Dependency(\.schedulers) var schedulers
        return Future {
            try await erxTaskRepository.loadRemoteAllTasks(nil, profileId)
        }
        .receive(on: schedulers.main)
        .mapError { RedeemServiceError.eRxRepository($0.asErxRepositoryError()) }
        .flatMap { tasks -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> in
            let taskIds = orders.map(\.taskID)
            @Dependency(\.date) var date

            let updatedTasks = tasks
                .filter { taskIds.contains($0.id) }
                .map {
                    Prescription(
                        erxTask: $0,
                        date: date()
                    )
                }

            let notRedeemablePrescriptions = updatedTasks.filter { !$0.isPharmacyRedeemable }
            guard notRedeemablePrescriptions.isEmpty else {
                return Fail<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>(
                    error: RedeemServiceError.prescriptionAlreadyRedeemed(notRedeemablePrescriptions)
                ).eraseToAnyPublisher()
            }
            return redeemViaRepository(orders: orders)
                .mapError(RedeemServiceError.from)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func redeemViaRepository(
        orders: [OrderRequest]
    ) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, Swift.Error> {
        var erxTaskOrders = [(ErxTaskOrder, OrderRequest)]()
        var responses: IdentifiedArrayOf<OrderResponse> = []
        for order in orders {
            do {
                let erxTaskOrder = try ErxTaskOrder(order)
                erxTaskOrders.append((erxTaskOrder, order))
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
            responses.append(OrderResponse(requested: order, result: .progress(.loading)))
        }

        let redeemErxTaskPublishers: [AnyPublisher<OrderResponse, Never>] =
            erxTaskOrders.map { erxTaskOrder, order in
                Future {
                    try await erxTaskRepository.redeem(erxTaskOrder)
                }
                .mapError { $0.asErxRepositoryError() }
                .map { _ in
                    OrderResponse(requested: order, result: .success(true))
                }
                .catch { error in
                    Just(
                        OrderResponse(
                            requested: order,
                            result: .failure(RedeemServiceError.eRxRepository(error))
                        )
                    )
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }

        // Collects all order responses and merges them into a single emit of the publisher
        return Publishers.MergeMany(redeemErxTaskPublishers)
            .collect(redeemErxTaskPublishers.count)
            .setFailureType(to: RedeemServiceError.self)
            .tryMap { collection in
                var responseCollection: IdentifiedArrayOf<OrderResponse> = []
                try collection.forEach { response in
                    guard let index = responses.firstIndex(where: { $0.id == response.id }) else {
                        throw RedeemServiceError.InternalError.idMissmatch
                    }
                    responses.update(response, at: index)
                    responses.forEach { responseCollection.updateOrAppend($0) }
                }
                return responseCollection
            }
            .eraseToAnyPublisher()
    }

    func redeemViaRepositoryDiGa(
        orders: [OrderDiGaRequest]
    ) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, Swift.Error> {
        var erxTaskOrders = [(ErxTaskOrder, OrderDiGaRequest)]()
        var responses: IdentifiedArrayOf<OrderDiGaResponse> = []
        for order in orders {
            do {
                let erxTaskOrder = try ErxTaskOrder(order)
                erxTaskOrders.append((erxTaskOrder, order))
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
            responses.append(OrderDiGaResponse(requested: order, result: .progress(.loading)))
        }

        let redeemErxTaskPublishers: [AnyPublisher<OrderDiGaResponse, Never>] =
            erxTaskOrders.map { erxTaskOrder, order in
                Future {
                    try await erxTaskRepository.redeem(erxTaskOrder)
                }
                .mapError { $0.asErxRepositoryError() }
                .map { _ in
                    OrderDiGaResponse(requested: order, result: .success(true))
                }
                .catch { error in
                    Just(
                        OrderDiGaResponse(
                            requested: order,
                            result: .failure(RedeemServiceError.eRxRepository(error))
                        )
                    )
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }

        // Collects all order responses and merges them into a single emit of the publisher
        return Publishers.MergeMany(redeemErxTaskPublishers)
            .collect(redeemErxTaskPublishers.count)
            .setFailureType(to: RedeemServiceError.self)
            .tryMap { collection in
                var responseCollection: IdentifiedArrayOf<OrderDiGaResponse> = []
                try collection.forEach { response in
                    guard let index = responses.firstIndex(where: { $0.id == response.id }) else {
                        throw RedeemServiceError.InternalError.idMissmatch
                    }
                    responses.update(response, at: index)
                    responses.forEach { responseCollection.updateOrAppend($0) }
                }
                return responseCollection
            }
            .eraseToAnyPublisher()
    }
}

extension Swift.Error {
    /// Map any Error to an RedeemServiceError
    public func asErxRepositoryError() -> ErxRepositoryError {
        if let error = self as? LocalStoreError {
            return ErxRepositoryError.local(error)
        } else if let error = self as? RemoteStoreError {
            return ErxRepositoryError.remote(error)
        } else {
            // this should not happen if used on any `ErxRepositoryError`
            return ErxRepositoryError.local(LocalStoreError.notImplemented)
        }
    }
}

// sourcery: skipUnimplemented
extension ErxTaskRepositoryRedeemService: DependencyKey {
    static let liveValue: () -> RedeemService = {
        @Dependency(\.userSession) var userSession
        @Dependency(\.loginHandlerServiceFactory) var loginHandlerFactory
        @Dependency(\.secureEnclaveSignatureProviderFactory) var secureEnclaveSignatureProviderFactory

        return ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerFactory.construct(
                userSession.idpSession,
                secureEnclaveSignatureProviderFactory.construct(userSession.profileId)
            )
        )
    }

    static let testValue: () -> RedeemService = { UnimplementedRedeemService() }
}

extension DependencyValues {
    var erxTaskRepositoryRedeemService: () -> RedeemService {
        get { self[ErxTaskRepositoryRedeemService.self] }
        set { self[ErxTaskRepositoryRedeemService.self] = newValue }
    }
}

struct DemoRedeemService: RedeemService {
    func redeem(_ orders: [OrderRequest],
                profileId _: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        var responses = IdentifiedArrayOf<OrderResponse>()
        for order in orders {
            responses.append(OrderResponse(requested: order, result: .success(true)))
        }
        return Just(responses).setFailureType(to: RedeemServiceError.self).eraseToAnyPublisher()
    }

    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId _: UUID)
        -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> {
        var responses = IdentifiedArrayOf<OrderDiGaResponse>()
        for order in orders {
            responses.append(OrderDiGaResponse(requested: order, result: .success(true)))
        }
        return Just(responses).setFailureType(to: RedeemServiceError.self).eraseToAnyPublisher()
    }
}
