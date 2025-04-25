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

@testable import AVS
import Combine
import Dependencies
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import Foundation
import IdentifiedCollections
import Nimble
import OpenSSL
import Pharmacy
import TestUtils
import XCTest

final class AVSRedeemServiceTests: XCTestCase {
    @MainActor
    func testRedeemViaAVSResponses_Success() async throws {
        // given
        let mockAVSService = AVSSessionCustomMock()
        mockAVSService
            .redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure = { message, _, _ in
                AVSSessionResponse(message: message, httpStatusCode: 200)
            }
        let mockAVSTransactionDataStore = AVSTransactionDataStoreCustomMock()
        mockAVSTransactionDataStore.saveAvsTransactionsReturnValue = Just([AVSTransaction.Fixtures.transaction1])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let order1: OrderRequest = .Fixtures.order1
        let order2: OrderRequest = .Fixtures.order2
        let order3: OrderRequest = .Fixtures.order3

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        let cancellable = sut.redeem([order1, order2, order3])
            .subscribe(on: AnySchedulerOf<DispatchQueue>.immediate)
            .receive(on: AnySchedulerOf<DispatchQueue>.immediate)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error)
                    fail("no error expected")
                }
            } receiveValue: { orderResponses in
                receivedResponse = orderResponses
            }

        await expect(receivedResponse).toEventually(haveCount(3))

        expect(receivedResponse.inProgress).to(beFalse())
        expect(receivedResponse.areFailing).to(beFalse())
        expect(receivedResponse.areSuccessful).to(beTrue())
        expect(receivedResponse.arePartiallySuccessful).to(beFalse())
        expect(receivedResponse.progress).to(equal(1.0))
        expect(receivedResponse.count) == 3
        expect(receivedResponse[id: order1.taskID]?.requested).to(equal(order1))
        expect(receivedResponse[id: order2.taskID]?.requested).to(equal(order2))
        expect(receivedResponse[id: order3.taskID]?.requested).to(equal(order3))

        expect(receivedResponse.filter(\.isSuccess)).to(haveCount(3))
        expect(receivedResponse.filter(\.inProgress)).to(haveCount(0))

        await expect(mockAVSTransactionDataStore.saveAvsTransactionsCalled).toEventually(beTrue())
        await expect(mockAVSTransactionDataStore.saveAvsTransactionsCallsCount).toEventually(equal(3))
    }

    @MainActor
    func testRedeemViaAVSResponses_PartialSuccess() async throws {
        let mockAVSService = AVSSessionCustomMock()
        // given
        mockAVSService
            .redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure = { message, _, _ in
                let avsMessage = try AVSMessage(.Fixtures.order1)
                if avsMessage == message {
                    throw AVSError.internal(error: AVSError.InternalError.cmsContentCreation)
                } else {
                    return AVSSessionResponse(message: message, httpStatusCode: 200)
                }
            }
        let mockAVSTransactionDataStore = AVSTransactionDataStoreCustomMock()
        mockAVSTransactionDataStore.saveAvsTransactionsReturnValue = Just([AVSTransaction.Fixtures.transaction1])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        // when
        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let order1: OrderRequest = .Fixtures.order1
        let order2: OrderRequest = .Fixtures.order2
        let order3: OrderRequest = .Fixtures.order3

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        let cancellable = sut.redeem([order1, order2, order3])
            .subscribe(on: AnySchedulerOf<DispatchQueue>.immediate)
            .receive(on: AnySchedulerOf<DispatchQueue>.immediate)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error)
                    fail("no error expected")
                }
            } receiveValue: { orderResponses in
                receivedResponse = orderResponses
            }

        await expect(receivedResponse).toEventually(haveCount(3))

        expect(receivedResponse.inProgress).to(beFalse())
        expect(receivedResponse.areFailing).to(beFalse())
        expect(receivedResponse.areSuccessful).to(beFalse())
        expect(receivedResponse.arePartiallySuccessful).to(beTrue())
        expect(receivedResponse.progress).to(equal(1.0))
        expect(receivedResponse.count) == 3
        expect(receivedResponse[id: order1.taskID]?.requested).to(equal(order1))
        expect(receivedResponse[id: order2.taskID]?.requested).to(equal(order2))
        expect(receivedResponse[id: order3.taskID]?.requested).to(equal(order3))

        expect(receivedResponse.filter(\.inProgress)).to(haveCount(0))
        expect(receivedResponse.filter(\.isFailure)).to(haveCount(1))
        expect(receivedResponse.filter(\.isSuccess)).to(haveCount(2))

        expect(mockAVSTransactionDataStore.saveAvsTransactionsCalled) == true
        expect(mockAVSTransactionDataStore.saveAvsTransactionsCallsCount) == 2
    }

    @MainActor
    func testRedeemViaAVSResponses_All_Fail() async throws {
        let userDefaults = UserDefaultsStore(userDefaults: .standard)
        let mockAVSService = AVSSessionCustomMock()
        let mockAVSTransactionDataStore = AVSTransactionDataStoreCustomMock()
        await withDependencies {
            $0.appAuthenticationProvider = DefaultAuthenticationProvider(userDataStore: userDefaults)
            $0.appSecurityManager = DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper())
            $0.authenticationChallengeProvider = BiometricsAuthenticationChallengeProvider()
            $0.schedulers = Schedulers()
            $0.userDataStore = userDefaults
        } operation: {
            let sut = AVSRedeemService(
                avsSession: mockAVSService,
                avsTransactionDataStore: mockAVSTransactionDataStore
            )

            mockAVSService
                .redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure = { _, _, _ in
                    throw AVSError.internal(error: AVSError.InternalError.cmsContentCreation)
                }
            mockAVSTransactionDataStore.saveAvsTransactionsReturnValue = Just([AVSTransaction.Fixtures.transaction1])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let order1: OrderRequest = .Fixtures.order1
            let order2: OrderRequest = .Fixtures.order2
            let order3: OrderRequest = .Fixtures.order3

            var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
            let cancellable = sut.redeem([order1, order2, order3])
                .subscribe(on: AnySchedulerOf<DispatchQueue>.immediate)
                .receive(on: AnySchedulerOf<DispatchQueue>.immediate)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error)
                        fail("no error expected")
                    }
                } receiveValue: { orderResponses in
                    receivedResponse = orderResponses
                }

            await expect(receivedResponse).toEventually(haveCount(3))

            expect(receivedResponse.count) == 3
            expect(receivedResponse[id: order1.taskID]?.requested).to(equal(order1))
            expect(receivedResponse[id: order2.taskID]?.requested).to(equal(order2))
            expect(receivedResponse[id: order3.taskID]?.requested).to(equal(order3))
            expect(receivedResponse.filter(\.isFailure)).to(haveCount(3))
            expect(receivedResponse.filter(\.inProgress)).to(haveCount(0))

            expect(receivedResponse.inProgress).to(beFalse())
            expect(receivedResponse.areFailing).to(beTrue())
            expect(receivedResponse.areSuccessful).to(beFalse())
            expect(receivedResponse.arePartiallySuccessful).to(beFalse())
            expect(receivedResponse.progress).to(equal(1.0))

            expect(mockAVSTransactionDataStore.saveAvsTransactionsCalled) == false
        }
    }

    @MainActor
    func testRedeemViaAVSResponses_SetupFailure() async throws {
        let mockAVSService = AVSSessionCustomMock()
        let mockAVSTransactionDataStore = AVSTransactionDataStoreCustomMock()
        mockAVSTransactionDataStore.saveAvsTransactionsReturnValue = Just([AVSTransaction.Fixtures.transaction1])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let order: OrderRequest = .Fixtures.orderNoEndpoint

        let cancellable = sut.redeem([order])
            .subscribe(on: AnySchedulerOf<DispatchQueue>.immediate)
            .receive(on: AnySchedulerOf<DispatchQueue>.immediate)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    expect(error).to(equal(RedeemServiceError.internalError(.missingAVSEndpoint)))
                case .finished:
                    fail("no completion expected")
                }
            } receiveValue: { _ in
                fail("no order response expected")
            }

        await expect(mockAVSTransactionDataStore.saveAvsTransactionsCalled).toEventually(beFalse())
    }

    @MainActor
    func testGroupedOrdersHaveSameRedeemDateAndGroupRedemptionID() async throws {
        // given
        let mockAVSService = AVSSessionCustomMock()
        mockAVSService
            .redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure = { message, _, _ in
                AVSSessionResponse(message: message, httpStatusCode: 200)
            }
        let mockAVSTransactionDataStore = AVSTransactionDataStoreCustomMock()
        mockAVSTransactionDataStore.saveAvsTransactionsReturnValue = Just([AVSTransaction.Fixtures.transaction1])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let orderId = UUID()
        let orders: [OrderRequest] = OrderRequest.Fixtures.orders(with: orderId)

        // redeem once
        let cancellable = sut.redeem(orders)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error)
                    fail("no error expected")
                }
            } receiveValue: { _ in
            }

        await expect(mockAVSTransactionDataStore.saveAvsTransactionsCalled).toEventually(beTrue())
        await expect(mockAVSTransactionDataStore.saveAvsTransactionsCallsCount).toEventually(equal(3))

        await expect(mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations).toEventually(haveCount(3))
        let firstRedeemDateTime = mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations[0][0]
            .groupedRedeemTime
        expect(mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations.allSatisfy {
            $0[0].groupedRedeemTime == firstRedeemDateTime
        }) == true

        expect(mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations.allSatisfy {
            $0[0].groupedRedeemID == orderId
        }) == true
    }
}

// swiftlint:disable lower_acl_than_parent large_tuple line_length discouraged_optional_collection
private class AVSSessionCustomMock: AVSSession {
    public init() {}

    // MARK: - redeem

    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseThrowableError: (
        any Error
    )?
    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseCallsCount = 0
    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseCalled: Bool {
        redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseCallsCount > 0
    }

    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReceivedArguments: (
        message: AVSMessage,
        endpoint: AVSEndpoint,
        recipients: [X509]
    )?
    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReceivedInvocations: [
        (message: AVSMessage,
         endpoint: AVSEndpoint, recipients: [X509])
    ] = []
    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReturnValue: AVSSessionResponse!
    @MainActor public var redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure: ((
        AVSMessage,
        AVSEndpoint,
        [X509]
    ) async throws -> AVSSessionResponse)?

    public func redeem(message: AVSMessage, endpoint: AVSEndpoint,
                       recipients: [X509]) async throws -> AVSSessionResponse {
        await MainActor.run {
            redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseCallsCount += 1
        }
        await MainActor.run {
            redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReceivedArguments = (
                message: message,
                endpoint: endpoint,
                recipients: recipients
            )
        }
        await MainActor
            .run {
                redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReceivedInvocations
                    .append((message: message, endpoint: endpoint, recipients: recipients))
            }
        try await MainActor.run {
            if let error = redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseThrowableError {
                throw error
            }
        }
        if let redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure =
            await redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure {
            return try await redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseClosure(
                message,
                endpoint,
                recipients
            )
        } else {
            return await redeemMessageAVSMessageEndpointAVSEndpointRecipientsX509AVSSessionResponseReturnValue
        }
    }
}

private final class AVSTransactionDataStoreCustomMock: AVSTransactionDataStore {
    // MARK: - fetchAVSTransaction

    var fetchAVSTransactionByCallsCount = 0
    var fetchAVSTransactionByCalled: Bool {
        fetchAVSTransactionByCallsCount > 0
    }

    var fetchAVSTransactionByReceivedIdentifier: UUID?
    var fetchAVSTransactionByReceivedInvocations: [UUID] = []
    var fetchAVSTransactionByReturnValue: AnyPublisher<AVSTransaction?, LocalStoreError>!
    var fetchAVSTransactionByClosure: ((UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>)?

    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        fetchAVSTransactionByCallsCount += 1
        fetchAVSTransactionByReceivedIdentifier = identifier
        fetchAVSTransactionByReceivedInvocations.append(identifier)
        return fetchAVSTransactionByClosure.map { $0(identifier) } ?? fetchAVSTransactionByReturnValue
    }

    // MARK: - listAllAVSTransactions

    var listAllAVSTransactionsCallsCount = 0
    var listAllAVSTransactionsCalled: Bool {
        listAllAVSTransactionsCallsCount > 0
    }

    var listAllAVSTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var listAllAVSTransactionsClosure: (() -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        listAllAVSTransactionsCallsCount += 1
        return listAllAVSTransactionsClosure.map { $0() } ?? listAllAVSTransactionsReturnValue
    }

    // MARK: - save

    @MainActor var saveAvsTransactionsCallsCount = 0
    @MainActor var saveAvsTransactionsCalled: Bool {
        saveAvsTransactionsCallsCount > 0
    }

    @MainActor var saveAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    @MainActor var saveAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    @MainActor var saveAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    @MainActor var saveAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    @MainActor
    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        Task { @MainActor in
            saveAvsTransactionsCallsCount += 1
        }
        Task { @MainActor in
            saveAvsTransactionsReceivedAvsTransactions = avsTransactions
        }
        Task { @MainActor in
            saveAvsTransactionsReceivedInvocations.append(avsTransactions)
        }
        return saveAvsTransactionsClosure.map { $0(avsTransactions) } ?? saveAvsTransactionsReturnValue
    }

    // MARK: - delete

    var deleteAvsTransactionsCallsCount = 0
    var deleteAvsTransactionsCalled: Bool {
        deleteAvsTransactionsCallsCount > 0
    }

    var deleteAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var deleteAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var deleteAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var deleteAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        deleteAvsTransactionsCallsCount += 1
        deleteAvsTransactionsReceivedAvsTransactions = avsTransactions
        deleteAvsTransactionsReceivedInvocations.append(avsTransactions)
        return deleteAvsTransactionsClosure.map { $0(avsTransactions) } ?? deleteAvsTransactionsReturnValue
    }
}

// swiftlint:enable lower_acl_than_parent large_tuple line_length discouraged_optional_collection
