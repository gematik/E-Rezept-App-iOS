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
@testable import eRpFeatures
import eRpKit
import ErxTaskRepository
import FeatureCardWall
import Foundation
import IdentifiedCollections
import Nimble
import OpenSSL
import Pharmacy
import TestUtils
import XCTest

final class ErxTaskRepositoryRedeemServiceTests: XCTestCase {
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

    func testRedeemResponses_Success() {
        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: true)
        )

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        withDependencies { dependencies in
            dependencies.erxTaskRepository.redeem = { erxTaskOrder in
                erxTaskOrder
            }
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                []
            }
        } operation: {
            sut.redeem([order1, order2, order3], profileId: UUID())
                .testWait(failure: { error in
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
    }

    func testRedeemResponses_PartialSuccess() {
        let callsCount = LockIsolated(0)

        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: true)
        )

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        withDependencies { dependency in
            dependency.erxTaskRepository.redeem = { erxTaskOrder in
                callsCount.withValue { $0 += 1 }
                if self.order1.taskID == erxTaskOrder.erxTaskId {
                    throw ErxRepositoryError.remote(.notImplemented)
                } else {
                    return erxTaskOrder
                }
            }
            dependency.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                []
            }
            dependency.schedulers = Schedulers(uiScheduler: .immediate,
                                               networkScheduler: .immediate,
                                               ioScheduler: .immediate,
                                               computeScheduler: .immediate)
        } operation: {
            sut.redeem([order1, order2, order3], profileId: UUID())
                .testWait(failure: { error in
                    print(error)
                    fail("no error expected")
                }, expectations: { orderResponses in
                    receivedResponse = orderResponses
                })

            expect(receivedResponse.count).to(equal(3))

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
    }

    let now = Date()

    func testRedeemFailsDueToOutdatedPrescriptions() {
        let task1 = ErxTask(identifier: "task_id_1", status: .inProgress, flowType: .pharmacyOnly)
        let task2 = ErxTask(identifier: "task_id_2", status: .ready, flowType: .pharmacyOnly)

        let callsCount = LockIsolated(0)

        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: true)
        )

        let prescription1 = Prescription(erxTask: task1, date: now)

        withDependencies { dependencies in
            dependencies.date = .constant(now)
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                [task1, task2]
            }
            dependencies.erxTaskRepository.redeem = { order in
                callsCount.withValue { $0 += 1 }
                return order
            }
        } operation: {
            sut.redeem([order1, order2], profileId: UUID())
                .testWait(failure: { error in
                    expect(error).to(equal(RedeemServiceError.prescriptionAlreadyRedeemed([prescription1])))
                }, expectations: { _ in
                    fail("not expected to receive any response")
                })
        }

        expect(callsCount.withValue { $0 }).to(equal(0))
    }

    func testRedeemResponses_All_Fail() {
        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: true)
        )

        var receivedResponse: IdentifiedArrayOf<OrderResponse> = []
        withDependencies { dependencies in
            dependencies.erxTaskRepository.redeem = { _ in
                throw ErxRepositoryError.remote(.notImplemented)
            }
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                []
            }
        } operation: {
            sut.redeem([order1, order2, order3], profileId: UUID())
                .testWait(failure: { error in
                    print(error)
                    fail("no error expected")
                }, expectations: { orderResponses in
                    receivedResponse = orderResponses
                })
        }

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

    func testRedeemResponses_InputFailure() {
        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: true)
        )

        let orderWithMissingTelematikId = OrderRequest(
            redeemType: .shipment,
            flowType: "160",
            taskID: "task_id_3",
            accessCode: "access_code_3"
        )

        withDependencies { dependencies in
            dependencies.erxTaskRepository.redeem = { order in
                order
            }
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                []
            }
        } operation: {
            sut.redeem([order1, order2, orderWithMissingTelematikId], profileId: UUID())
                .testWait(failure: { error in
                    expect(error).to(equal(RedeemServiceError.internalError(.missingTelematikId)))
                }, expectations: { _ in
                    fail("not expected to receive any response")
                })
        }
    }

    func testRedeemResponses_When_Not_Authenticated() {
        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock(authenticated: false)
        )

        withDependencies { dependencies in
            dependencies.erxTaskRepository.redeem = { order in
                order
            }
        } operation: {
            sut.redeem([order1, order2], profileId: UUID())
                .test(failure: { error in
                    expect(error).to(equal(RedeemServiceError.noTokenAvailable))
                }, expectations: { _ in
                    fail("not expected to receive any response")
                })
        }
    }

    func testRedeemResponses_With_Error_From_LoginHandler() {
        let loginHandlerMock = LoginHandlerMock()
        let expectedError = LoginHandlerError.idpError(.biometrics(.packagingAuthCertificate))
        loginHandlerMock
            .isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(LoginResult
                .failure(expectedError))
            .eraseToAnyPublisher()
        let sut = ErxTaskRepositoryRedeemService(
            loginHandler: loginHandlerMock
        )

        withDependencies { dependencies in
            dependencies.erxTaskRepository.redeem = { order in
                order
            }
        } operation: {
            sut.redeem([order1, order2], profileId: UUID())
                .test(failure: { error in
                    expect(error).to(equal(RedeemServiceError.loginHandler(error: expectedError)))
                }, expectations: { _ in
                    fail("not expected to receive any response")
                })
        }
    }

    private func loginHandlerMock(authenticated: Bool) -> LoginHandlerMock {
        let loginHandlerMock = LoginHandlerMock()
        loginHandlerMock
            .isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(LoginResult
                .success(authenticated)).eraseToAnyPublisher()
        loginHandlerMock
            .isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue =
            Just(LoginResult.success(authenticated))
                .eraseToAnyPublisher()
        return loginHandlerMock
    }
}
