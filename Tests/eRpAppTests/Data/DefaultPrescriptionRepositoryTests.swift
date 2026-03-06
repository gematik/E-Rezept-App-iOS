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
import Dependencies
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import ErxTaskRepository
import FeatureCardWall
import Nimble
import XCTest

final class DefaultPrescriptionRepositoryTests: XCTestCase {
    var loginHandler: LoginHandlerMock!

    override func setUp() {
        super.setUp()

        loginHandler = LoginHandlerMock()
    }

    func testLoadLocal() {
        let sut = DefaultPrescriptionRepository(
            loginHandler: LoginHandlerMock()
        )

        withDependencies {
            $0.erxTaskRepository.loadLocalAllTasks = { _ in
                Just(Array(ErxTaskRepository.exampleStore.values))
                    .setFailureType(to: ErxRepositoryError.self)
                    .eraseToAnyPublisher()
            }
        } operation: {
            sut.loadLocal(for: UUID())
                .testWait(
                    expectations: { prescriptions in
                        // swiftlint:disable:previous trailing_closure
                        expect(prescriptions.count) == 15

                        // Note: This can only work if we'd inject the refer
                        let notArchivedPrescriptions = prescriptions.filter { !$0.isArchived }
                        expect(notArchivedPrescriptions.count) == 10

                        let archivedPrescriptions = prescriptions.filter(\.isArchived)
                        expect(archivedPrescriptions.count) == 5
                    }
                )
        }
    }

    func testSilentLoadRemote_loggedIn() {
        let sut = DefaultPrescriptionRepository(
            loginHandler: loginHandler
        )

        loginHandler
            .isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(LoginResult.success(true))
            .eraseToAnyPublisher()

        withDependencies { dependencies in
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                Array(ErxTaskRepository.exampleStore.values)
            }
        } operation: {
            sut.silentLoadRemote(for: nil, for: UUID())
                .testWait(
                    expectations: { result in
                        // swiftlint:disable:previous trailing_closure

                        guard case let .prescriptions(prescriptions) = result else {
                            Nimble.fail("expected list of prescriptions")
                            return
                        }
                        expect(prescriptions.count) == 15

                        let notArchivedPrescriptions = prescriptions.filter { !$0.isArchived }
                        expect(notArchivedPrescriptions.count) == 10

                        let archivedPrescriptions = prescriptions.filter(\.isArchived)
                        expect(archivedPrescriptions.count) == 5
                    }
                )
        }
    }

    func testSilentLoadRemote_loggedOut() {
        let sut = DefaultPrescriptionRepository(
            loginHandler: loginHandler
        )

        loginHandler
            .isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(LoginResult.success(false))
            .eraseToAnyPublisher()

        withDependencies { dependencies in
            dependencies.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                Array(ErxTaskRepository.exampleStore.values)
            }
        } operation: {
            sut.silentLoadRemote(for: nil, for: UUID())
                .test(
                    expectations: { result in
                        expect(result) == PrescriptionRepositoryLoadRemoteResult.notAuthenticated
                    }
                )
        }
    }

    func testActivityIndicating() {
        withDependencies {
            $0.date = DateGenerator { Date() }
            $0.erxTaskRepository.loadRemoteAllTasks = { _, _ in
                ErxTask.Fixtures.erxTasks
            }
        } operation: {
            // given
            let sut = DefaultPrescriptionRepository(
                loginHandler: loginHandler
            )

            loginHandler
                .isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(LoginResult
                    .success(true)).eraseToAnyPublisher()

            var isActiveResult: [Bool] = []
            // when
            let isActiveCancelable = sut.isActive.sink { value in
                isActiveResult.append(value)
            }
            expect(isActiveResult) == [false]
            isActiveResult = []

            sut.silentLoadRemote(for: nil, for: UUID())
                .testWait(
                    expectations: { output in
                        expect(output) == .prescriptions(ErxTask.Fixtures.erxTasks.map {
                            Prescription(erxTask: $0)
                        })
                    }
                )

            // then
            expect(isActiveResult) == [true, false]
            isActiveCancelable.cancel()
        }
    }
}
