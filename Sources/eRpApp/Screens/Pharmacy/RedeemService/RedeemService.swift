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

import AVS
import Combine
import Dependencies
import eRpKit
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy

protocol RedeemService {
    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>
}

struct RedeemServiceDependency: DependencyKey {
    // Is initially unimplemented because there is no reasonable default
    // Use the dependency values from `AVSRedeemService` or `ErxTaskRepositoryRedeemService` to override
    static let liveValue: RedeemService = UnimplementedRedeemService()
    static let previewValue: RedeemService = DemoRedeemService()
}

extension DependencyValues {
    var redeemService: RedeemService {
        get { self[RedeemServiceDependency.self] }
        set { self[RedeemServiceDependency.self] = newValue }
    }
}

struct AVSRedeemService: RedeemService {
    let avsSession: AVSSession
    let avsTransactionDataStore: AVSTransactionDataStore

    let groupedRedeemTimeProvider: () -> Date = { Date() }

    // swiftlint:disable:next function_body_length
    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        guard orders.allSatisfy({ $0.endpoint != nil }),
              let endpoint = orders.first?.endpoint else {
            return Fail(error: RedeemServiceError.internalError(.missingAVSEndpoint)).eraseToAnyPublisher()
        }
        guard orders.allSatisfy({ !$0.recipients.isEmpty }),
              let recipients = orders.first?.recipients else {
            return Fail(error: RedeemServiceError.internalError(.missingAVSCertificate)).eraseToAnyPublisher()
        }

        var responses: IdentifiedArrayOf<OrderResponse> = []
        var orderAndMessages = [(Order, AVSMessage)]()
        for order in orders {
            do {
                let message = try AVSMessage(order)
                orderAndMessages.append((order, message))
            } catch {
                return Fail(error: RedeemServiceError.from(error)).eraseToAnyPublisher()
            }
            responses.append(OrderResponse(requested: order, result: .progress(.loading)))
        }

        let groupedRedeemTime: Date = groupedRedeemTimeProvider()

        let redeemMessagePublishers: [AnyPublisher<OrderResponse, Never>] =
            orderAndMessages.map { order, message -> AnyPublisher<OrderResponse, Never> in
                avsSession.redeem(message: message, endpoint: endpoint.asEndpoint(), recipients: recipients)
                    .mapError { RedeemServiceError.from($0) }
                    .flatMap { avsSessionResponse -> AnyPublisher<OrderResponse, RedeemServiceError> in
                        let httpStatusCode = avsSessionResponse.httpStatusCode
                        guard 200 ..< 300 ~= httpStatusCode else {
                            return Fail(error: .from(RedeemServiceError.InternalError.unexpectedHTTPStatusCode))
                                .eraseToAnyPublisher()
                        }
                        let orderResponse = OrderResponse(requested: order, result: .success(true))
                        return avsTransactionDataStore.save(
                            avsTransaction: .init(
                                transactionID: order.transactionID,
                                httpStatusCode: Int32(httpStatusCode),
                                groupedRedeemTime: groupedRedeemTime,
                                groupedRedeemID: order.orderID,
                                telematikID: order.telematikId,
                                taskId: order.taskID
                            )
                        )
                        .map { _ in orderResponse }
                        .mapError { .from(RedeemServiceError.InternalError.localStoreError($0)) }
                        .eraseToAnyPublisher()
                    }
                    .catch { error -> AnyPublisher<OrderResponse, Never> in // erase the RedeemServiceError to Never
                        Just(
                            OrderResponse(requested: order, result: .failure(error))
                        )
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }

        return Publishers.MergeMany(redeemMessagePublishers)
            .setFailureType(to: RedeemServiceError.self)
            .tryMap { response in
                guard let index = responses.firstIndex(where: { $0.id == response.id }) else {
                    throw RedeemServiceError.InternalError.idMissmatch
                }
                responses.update(response, at: index)
                return responses
            }
            .mapError(RedeemServiceError.from)
            .eraseToAnyPublisher()
    }
}

extension AVSRedeemService: DependencyKey {
    static let liveValue = AVSRedeemService(
        avsSession: UsersSessionContainerDependency.liveValue.userSession.avsSession,
        avsTransactionDataStore: UsersSessionContainerDependency.liveValue.userSession.avsTransactionDataStore
    )

    static let previewValue: AVSRedeemService = liveValue
}

extension DependencyValues {
    var avsRedeemService: AVSRedeemService {
        get { self[AVSRedeemService.self] }
        set { self[AVSRedeemService.self] = newValue }
    }
}

extension PharmacyLocation.AVSEndpoints.Endpoint {
    func asEndpoint() -> AVSEndpoint {
        AVSEndpoint(url: url, additionalHeaders: additionalHeaders)
    }
}

struct ErxTaskRepositoryRedeemService: RedeemService {
    let erxTaskRepository: ErxTaskRepository
    let loginHandler: LoginHandler

    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        loginHandler
            .isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { authenticated -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> in
                // [REQ:gemSpec_eRp_FdV:A_20167,A_20172] no token/not authorized, show authenticator module
                if Result.success(false) == authenticated {
                    return Fail(error: RedeemServiceError.noTokenAvailable).eraseToAnyPublisher()
                }
                if case let Result.failure(error) = authenticated {
                    return Fail(error: RedeemServiceError.loginHandler(error: error)).eraseToAnyPublisher()
                } else {
                    return redeemViaRepository(orders: orders)
                        .mapError(RedeemServiceError.from)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func redeemViaRepository(
        orders: [Order]
    ) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, Swift.Error> {
        var erxTaskOrders = [(ErxTaskOrder, Order)]()
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
                erxTaskRepository.redeem(order: erxTaskOrder)
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

        return Publishers.MergeMany(redeemErxTaskPublishers)
            .setFailureType(to: RedeemServiceError.self)
            .tryMap { response in
                guard let index = responses.firstIndex(where: { $0.id == response.id }) else {
                    throw RedeemServiceError.InternalError.idMissmatch
                }
                responses.update(response, at: index)
                return responses
            }
            .eraseToAnyPublisher()
    }
}

extension ErxTaskRepositoryRedeemService: DependencyKey {
    static let liveValue = {
        @Dependency(\.userSession) var userSession
        return ErxTaskRepositoryRedeemService(
            erxTaskRepository: userSession.erxTaskRepository,
            loginHandler: DefaultLoginHandler(
                idpSession: userSession.idpSession,
                signatureProvider: userSession.secureEnclaveSignatureProvider
            )
        )
    }()
}

extension DependencyValues {
    var erxTaskRepositoryRedeemService: ErxTaskRepositoryRedeemService {
        get { self[ErxTaskRepositoryRedeemService.self] }
        set { self[ErxTaskRepositoryRedeemService.self] = newValue }
    }
}

struct DemoRedeemService: RedeemService {
    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        var responses = IdentifiedArrayOf<OrderResponse>()
        for order in orders {
            responses.append(OrderResponse(requested: order, result: .success(true)))
        }
        return Just(responses).setFailureType(to: RedeemServiceError.self).eraseToAnyPublisher()
    }
}
