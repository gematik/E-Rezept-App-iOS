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

@testable import AVS
import Combine
import DataKit
import Dependencies
@testable import eRpApp
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
    var mockAVSService: MockAVSSession!
    var mockAVSTransactionDataStore: MockAVSTransactionDataStore!

    override func setUp() {
        super.setUp()

        mockAVSService = {
            let mockAVSService = MockAVSSession()
            mockAVSService.redeemMessageEndpointRecipientsClosure = { message, _, _ in
                Just(.init(message: message, httpStatusCode: 200))
                    .setFailureType(to: AVSError.self)
                    .eraseToAnyPublisher()
            }
            return mockAVSService
        }()

        mockAVSTransactionDataStore = {
            let mockAVSTransactionDataStore = MockAVSTransactionDataStore()
            mockAVSTransactionDataStore.saveAvsTransactionsClosure = { _ in
                Just([
                    AVSTransaction.Fixtures.transaction1,
                ])
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            }
            return mockAVSTransactionDataStore
        }()
    }

    func testRedeemViaAVSResponses_Success() throws {
        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let order1: Order = .Fixtures.order1
        let order2: Order = .Fixtures.order2
        let order3: Order = .Fixtures.order3

        var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponses.append(orderResponses)
            })

        expect(receivedResponses.count).toEventually(equal(3))
        let firstResponse = receivedResponses[0]

        expect(firstResponse.count) == 3
        expect(firstResponse.inProgress).to(beTrue())
        expect(firstResponse.areFailing).to(beFalse())
        expect(firstResponse.areSuccessful).to(beFalse())
        expect(firstResponse.arePartiallySuccessful).to(beFalse())
        expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
        expect(firstResponse[0].isSuccess).to(beTrue())
        expect(firstResponse[0].requested).to(equal(order1))
        expect(firstResponse[1].inProgress).to(beTrue())
        expect(firstResponse[1].requested).to(equal(order2))
        expect(firstResponse[2].inProgress).to(beTrue())
        expect(firstResponse[2].requested).to(equal(order3))

        let secondResponse = receivedResponses[1]
        expect(secondResponse.count) == 3
        expect(secondResponse.inProgress).to(beTrue())
        expect(secondResponse.areFailing).to(beFalse())
        expect(secondResponse.areSuccessful).to(beFalse())
        expect(secondResponse.arePartiallySuccessful).to(beFalse())
        expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
        expect(secondResponse[0].isSuccess).to(beTrue())
        expect(secondResponse[0].requested).to(equal(order1))
        expect(secondResponse[1].isSuccess).to(beTrue())
        expect(secondResponse[1].requested).to(equal(order2))
        expect(secondResponse[2].inProgress).to(beTrue())
        expect(secondResponse[2].requested).to(equal(order3))

        let thirdResponse = receivedResponses[2]
        expect(thirdResponse.inProgress).to(beFalse())
        expect(thirdResponse.areFailing).to(beFalse())
        expect(thirdResponse.areSuccessful).to(beTrue())
        expect(thirdResponse.arePartiallySuccessful).to(beFalse())
        expect(thirdResponse.progress).to(equal(1.0))
        expect(thirdResponse.count) == 3
        expect(thirdResponse[0].isSuccess).to(beTrue())
        expect(thirdResponse[0].requested).to(equal(order1))
        expect(thirdResponse[1].isSuccess).to(beTrue())
        expect(thirdResponse[1].requested).to(equal(order2))
        expect(thirdResponse[2].isSuccess).to(beTrue())
        expect(thirdResponse[2].requested).to(equal(order3))

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCalled) == true
        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCallsCount) == 3
    }

    func testRedeemViaAVSResponses_PartialSuccess() throws {
        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        var callsCount = 0
        mockAVSService.redeemMessageEndpointRecipientsClosure = { message, _, _ in
            callsCount += 1
            if callsCount == 1 {
                return Fail(error: AVSError.internal(error: AVSError.InternalError.cmsContentCreation))
                    .eraseToAnyPublisher()
            } else {
                return Just(.init(message: message, httpStatusCode: 200))
                    .setFailureType(to: AVSError.self)
                    .eraseToAnyPublisher()
            }
        }

        let order1: Order = .Fixtures.order1
        let order2: Order = .Fixtures.order2
        let order3: Order = .Fixtures.order3

        var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponses.append(orderResponses)
            })

        expect(receivedResponses.count).toEventually(equal(3))
        let firstResponse = receivedResponses[0]

        expect(firstResponse.count) == 3
        expect(firstResponse.inProgress).to(beTrue())
        expect(firstResponse.areFailing).to(beFalse())
        expect(firstResponse.areSuccessful).to(beFalse())
        expect(firstResponse.arePartiallySuccessful).to(beFalse())
        expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
        expect(firstResponse[0].isFailure).to(beTrue())
        expect(firstResponse[0].requested).to(equal(order1))
        expect(firstResponse[1].inProgress).to(beTrue())
        expect(firstResponse[1].requested).to(equal(order2))
        expect(firstResponse[2].inProgress).to(beTrue())
        expect(firstResponse[2].requested).to(equal(order3))

        let secondResponse = receivedResponses[1]
        expect(secondResponse.count) == 3
        expect(secondResponse.inProgress).to(beTrue())
        expect(secondResponse.areFailing).to(beFalse())
        expect(secondResponse.areSuccessful).to(beFalse())
        expect(secondResponse.arePartiallySuccessful).to(beFalse())
        expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
        expect(secondResponse[0].isFailure).to(beTrue())
        expect(secondResponse[0].requested).to(equal(order1))
        expect(secondResponse[1].isSuccess).to(beTrue())
        expect(secondResponse[1].requested).to(equal(order2))
        expect(secondResponse[2].inProgress).to(beTrue())
        expect(secondResponse[2].requested).to(equal(order3))

        let thirdResponse = receivedResponses[2]
        expect(thirdResponse.inProgress).to(beFalse())
        expect(thirdResponse.areFailing).to(beFalse())
        expect(thirdResponse.areSuccessful).to(beFalse())
        expect(thirdResponse.arePartiallySuccessful).to(beTrue())
        expect(thirdResponse.progress).to(equal(1.0))
        expect(thirdResponse.count) == 3
        expect(thirdResponse[0].isFailure).to(beTrue())
        expect(thirdResponse[0].requested).to(equal(order1))
        expect(thirdResponse[1].isSuccess).to(beTrue())
        expect(thirdResponse[1].requested).to(equal(order2))
        expect(thirdResponse[2].isSuccess).to(beTrue())
        expect(thirdResponse[2].requested).to(equal(order3))

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCalled) == true
        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCallsCount) == 2
    }

    func testRedeemViaAVSResponses_All_Fail() throws {
        let userDefaults = UserDefaultsStore(userDefaults: .standard)
        withDependencies {
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

            mockAVSService.redeemMessageEndpointRecipientsClosure = { _, _, _ in
                Fail(error: AVSError.internal(error: AVSError.InternalError.cmsContentCreation))
                    .eraseToAnyPublisher()
            }

            let order1: Order = .Fixtures.order1
            let order2: Order = .Fixtures.order2
            let order3: Order = .Fixtures.order3

            var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
            sut.redeem([order1, order2, order3])
                .test(failure: { error in
                    print(error)
                    fail("no error expected")
                }, expectations: { orderResponses in
                    receivedResponses.append(orderResponses)
                })

            expect(receivedResponses.count).toEventually(equal(3))
            let firstResponse = receivedResponses[0]

            expect(firstResponse.count) == 3
            expect(firstResponse.inProgress).to(beTrue())
            expect(firstResponse.areFailing).to(beFalse())
            expect(firstResponse.areSuccessful).to(beFalse())
            expect(firstResponse.arePartiallySuccessful).to(beFalse())
            expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
            expect(firstResponse[0].isFailure).to(beTrue())
            expect(firstResponse[0].requested).to(equal(order1))
            expect(firstResponse[1].inProgress).to(beTrue())
            expect(firstResponse[1].requested).to(equal(order2))
            expect(firstResponse[2].inProgress).to(beTrue())
            expect(firstResponse[2].requested).to(equal(order3))

            let secondResponse = receivedResponses[1]
            expect(secondResponse.count) == 3
            expect(secondResponse.inProgress).to(beTrue())
            expect(secondResponse.areFailing).to(beFalse())
            expect(secondResponse.areSuccessful).to(beFalse())
            expect(secondResponse.arePartiallySuccessful).to(beFalse())
            expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
            expect(secondResponse[0].isFailure).to(beTrue())
            expect(secondResponse[0].requested).to(equal(order1))
            expect(secondResponse[1].isFailure).to(beTrue())
            expect(secondResponse[1].requested).to(equal(order2))
            expect(secondResponse[2].inProgress).to(beTrue())
            expect(secondResponse[2].requested).to(equal(order3))

            let thirdResponse = receivedResponses[2]
            expect(thirdResponse.inProgress).to(beFalse())
            expect(thirdResponse.areFailing).to(beTrue())
            expect(thirdResponse.areSuccessful).to(beFalse())
            expect(thirdResponse.arePartiallySuccessful).to(beFalse())
            expect(thirdResponse.progress).to(equal(1.0))
            expect(thirdResponse.count) == 3
            expect(thirdResponse[0].isFailure).to(beTrue())
            expect(thirdResponse[0].requested).to(equal(order1))
            expect(thirdResponse[1].isFailure).to(beTrue())
            expect(thirdResponse[1].requested).to(equal(order2))
            expect(thirdResponse[2].isFailure).to(beTrue())
            expect(thirdResponse[2].requested).to(equal(order3))

            expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCalled) == false
        }
    }

    func testRedeemViaAVSResponses_SetupFailure() throws {
        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let order: Order = .Fixtures.orderNoEndpoint

        sut.redeem([order])
            .test(failure: { error in
                expect(error).to(equal(RedeemServiceError.internalError(.missingAVSEndpoint)))
            }, expectations: { _ in
                fail("no order response expected")
            })

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCalled) == false
    }

    func testGroupedOrdersHaveSameRedeemDateAndGroudRedemptionID() throws {
        let sut = AVSRedeemService(
            avsSession: mockAVSService,
            avsTransactionDataStore: mockAVSTransactionDataStore
        )

        let orderId = UUID()
        let orders: [Order] = Order.Fixtures.orders(with: orderId)

        // redeem once
        sut.redeem(orders)
            .test(
                failure: { error in
                    print(error)
                    fail("no error expected")
                },
                expectations: { _ in }
            )

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCalled) == true
        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsCallsCount) == 3

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations.count) == 3
        let firstRedeemDateTime = mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations[0][0]
            .groupedRedeemTime
        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations.allSatisfy {
            $0[0].groupedRedeemTime == firstRedeemDateTime
        }) == true

        expect(self.mockAVSTransactionDataStore.saveAvsTransactionsReceivedInvocations.allSatisfy {
            $0[0].groupedRedeemID == orderId
        }) == true
    }
}
