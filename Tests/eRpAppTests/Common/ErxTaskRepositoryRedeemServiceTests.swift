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
import Dependencies
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
        flowType: "160",
        taskID: "task_id_1",
        accessCode: "access_code_1",
        telematikId: "telematik_id_1"
    )

    lazy var order2 = OrderRequest(
        redeemType: .shipment,
        flowType: "160",
        phone: "1234567",
        taskID: "task_id_2",
        accessCode: "access_code_2",
        telematikId: "telematik_id_2"
    )
    lazy var order3 = OrderRequest(
        redeemType: .delivery,
        flowType: "160",
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

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponse = orderResponses
            })

        expect(receivedResponse.count).toEventually(equal(3))

        expect(receivedResponse.inProgress).to(beFalse())
        expect(receivedResponse.areFailing).to(beFalse())
        expect(receivedResponse.areSuccessful).to(beTrue())
        expect(receivedResponse.arePartiallySuccessful).to(beFalse())
        expect(receivedResponse.progress).to(equal(1.0))
        expect(receivedResponse.count) == 3
        expect(receivedResponse[id: self.order1.taskID]?.isSuccess).to(beTrue())
        expect(receivedResponse[id: self.order1.taskID]?.requested).to(equal(order1))
        expect(receivedResponse[id: self.order2.taskID]?.isSuccess).to(beTrue())
        expect(receivedResponse[id: self.order2.taskID]?.requested).to(equal(order2))
        expect(receivedResponse[id: self.order3.taskID]?.isSuccess).to(beTrue())
        expect(receivedResponse[id: self.order3.taskID]?.requested).to(equal(order3))
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

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponse = orderResponses
            })

        expect(receivedResponse.count).toEventually(equal(3))

        expect(receivedResponse.inProgress).to(beFalse())
        expect(receivedResponse.areFailing).to(beFalse())
        expect(receivedResponse.areSuccessful).to(beFalse())
        expect(receivedResponse.arePartiallySuccessful).to(beTrue())
        expect(receivedResponse.progress).to(equal(1.0))
        expect(receivedResponse.count) == 3
        expect(receivedResponse[id: self.order1.taskID]?.isFailure).to(beTrue())
        expect(receivedResponse[id: self.order1.taskID]?.requested).to(equal(order1))
        expect(receivedResponse[id: self.order2.taskID]?.isSuccess).to(beTrue())
        expect(receivedResponse[id: self.order2.taskID]?.requested).to(equal(order2))
        expect(receivedResponse[id: self.order3.taskID]?.isSuccess).to(beTrue())
        expect(receivedResponse[id: self.order3.taskID]?.requested).to(equal(order3))
    }

    let now = Date()

    func testRedeemFailsDueToOutdatedPrescriptions() throws {
        let sut = ErxTaskRepositoryRedeemService(
            erxTaskRepository: mockRepository,
            loginHandler: loginHandlerMock(authenticated: true)
        )

        let task1 = ErxTask(identifier: "task_id_1", status: .inProgress, flowType: .pharmacyOnly)
        let task2 = ErxTask(identifier: "task_id_2", status: .ready, flowType: .pharmacyOnly)

        mockRepository.loadRemoteAndSavedPublisher = Just([task1, task2])
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        @Dependency(\.uiDateFormatter) var uiDateFormatter

        let prescription1 = Prescription(erxTask: task1, date: now, dateFormatter: uiDateFormatter)

        var callsCount = 0
        mockRepository.redeemClosure = { erxTaskOrder in
            callsCount += 1
            return Just(erxTaskOrder)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }

        withDependencies { dependencies in
            dependencies.date = .constant(now)
        } operation: {
            sut.redeem([order1, order2])
                .test(failure: { error in
                    expect(error).to(equal(RedeemServiceError.prescriptionAlreadyRedeemed([prescription1])))
                }, expectations: { _ in
                    fail("not expected to receive any response")
                })
        }

        expect(callsCount).to(equal(0))
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

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponse = orderResponses
            })

        expect(receivedResponse.count).toEventually(equal(3))

        expect(receivedResponse.inProgress).to(beFalse())
        expect(receivedResponse.areFailing).to(beTrue())
        expect(receivedResponse.areSuccessful).to(beFalse())
        expect(receivedResponse.arePartiallySuccessful).to(beFalse())
        expect(receivedResponse.progress).to(equal(1.0))
        expect(receivedResponse.count) == 3
        expect(receivedResponse[id: self.order1.taskID]?.isFailure).to(beTrue())
        expect(receivedResponse[id: self.order1.taskID]?.requested).to(equal(order1))
        expect(receivedResponse[id: self.order2.taskID]?.isFailure).to(beTrue())
        expect(receivedResponse[id: self.order2.taskID]?.requested).to(equal(order2))
        expect(receivedResponse[id: self.order3.taskID]?.isFailure).to(beTrue())
        expect(receivedResponse[id: self.order3.taskID]?.requested).to(equal(order3))
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
            flowType: "160",
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
