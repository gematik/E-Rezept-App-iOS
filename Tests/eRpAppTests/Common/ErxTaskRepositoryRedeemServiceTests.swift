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

import Combine
import DataKit
@testable import eRpFeatures
import eRpKit
import Foundation
import IdentifiedCollections
import Nimble
import OpenSSL
import Pharmacy
import TestUtils
import XCTest

final class ErxTaskRepositoryRedeemServiceTests: XCTestCase {
    let mockRepository = MockErxTaskRepository()

    lazy var order1 = OrderRequest(
        redeemType: .onPremise,
        taskID: "task_id_1",
        accessCode: "access_code_1",
        telematikId: "telematik_id_1"
    )

    lazy var order2 = OrderRequest(
        redeemType: .shipment,
        phone: "1234567",
        taskID: "task_id_2",
        accessCode: "access_code_2",
        telematikId: "telematik_id_2"
    )
    lazy var order3 = OrderRequest(
        redeemType: .delivery,
        phone: "1234567",
        taskID: "task_id_3",
        accessCode: "access_code_3",
        telematikId: "telematik_id_3"
    )

    func testRedeemResponses_Success() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: true)
        )

        mockRepository.redeemClosure = { erxTaskOrder in
            Just(erxTaskOrder)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }

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
    }

    func testRedeemResponses_PartialSuccess() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: true)
        )

        var callsCount = 0
        mockRepository.redeemClosure = { erxTaskOrder in
            callsCount += 1
            if callsCount == 1 {
                return Fail(error: ErxRepositoryError.remote(.notImplemented))
                    .eraseToAnyPublisher()
            } else {
                return Just(erxTaskOrder)
                    .setFailureType(to: ErxRepositoryError.self)
                    .eraseToAnyPublisher()
            }
        }

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
    }

    func testRedeemResponses_All_Fail() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: true)
        )

        mockRepository.redeemClosure = { _ in
            Fail(error: ErxRepositoryError.remote(.notImplemented))
                .eraseToAnyPublisher()
        }

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
    }

    func testRedeemResponses_InputFailure() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: true)
        )

        mockRepository.redeemClosure = { erxTaskOrder in
            Just(erxTaskOrder)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }

        let orderWithMissingTelematikId = OrderRequest(
            redeemType: .shipment,
            taskID: "task_id_3",
            accessCode: "access_code_3"
        )

        sut.redeem([order1, order2, orderWithMissingTelematikId])
            .test(failure: { error in
                expect(error).to(equal(RedeemServiceError.internalError(.missingTelematikId)))
            }, expectations: { _ in
                fail("not expected to receive any response")
            })
    }

    func testRedeemResponses_When_Not_Authenticated() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: false)
        )

        mockRepository.redeemClosure = { erxTaskOrder in
            Just(erxTaskOrder)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }

        sut.redeem([order1, order2])
            .test(failure: { error in
                expect(error).to(equal(RedeemServiceError.noTokenAvailable))
            }, expectations: { _ in
                fail("not expected to receive any response")
            })
    }

    func testRedeemResponses_With_Error_From_LoginHandler() throws {
        let loginHandlerMock = MockLoginHandler()
        let expectedError = LoginHandlerError.idpError(.biometrics(.packagingAuthCertificate))
        loginHandlerMock.isAuthenticatedOrAuthenticateReturnValue = Just(LoginResult.failure(expectedError))
            .eraseToAnyPublisher()
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock
        )

        mockRepository.redeemClosure = { erxTaskOrder in
            Just(erxTaskOrder)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }

        sut.redeem([order1, order2])
            .test(failure: { error in
                expect(error).to(equal(RedeemServiceError.loginHandler(error: expectedError)))
            }, expectations: { _ in
                fail("not expected to receive any response")
            })
    }

    private func loginHandlerMock(authenticated: Bool) -> MockLoginHandler {
        let loginHandlerMock = MockLoginHandler()
        loginHandlerMock.isAuthenticatedReturnValue = Just(LoginResult.success(authenticated)).eraseToAnyPublisher()
        loginHandlerMock.isAuthenticatedOrAuthenticateReturnValue = Just(LoginResult.success(authenticated))
            .eraseToAnyPublisher()
        return loginHandlerMock
    }
}
