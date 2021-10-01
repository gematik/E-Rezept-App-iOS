//
//  Copyright (c) 2021 gematik GmbH
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
import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class AppAuthenticationDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppAuthenticationDomain.State,
        AppAuthenticationDomain.State,
        AppAuthenticationDomain.Action,
        AppAuthenticationDomain.Action,
        AppAuthenticationDomain.Environment
    >

    struct MockAuthenticationProvider: AppAuthenticationProvider {
        var authenticationOption: AppSecurityOption

        func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityOption?, Never> {
            Just(authenticationOption.id)
                .map {
                    AppSecurityOption(fromId: $0)
                }
                .eraseToAnyPublisher()
        }
    }

    var appSecurityPasswordManager: MockAppSecurityManager!
    var userDataStore: MockUserDataStore!

    override func setUp() {
        super.setUp()

        appSecurityPasswordManager = MockAppSecurityManager()
        userDataStore = MockUserDataStore()
    }

    private func testStore(for authenticationOption: AppSecurityOption) -> TestStore {
        TestStore(initialState: AppAuthenticationDomain.State(),
                  reducer: AppAuthenticationDomain.reducer,
                  environment: AppAuthenticationDomain.Environment(
                      userDataStore: userDataStore,
                      schedulers: Schedulers(
                          uiScheduler: testScheduler.eraseToAnyScheduler()
                      ),
                      appAuthenticationProvider: MockAuthenticationProvider(
                          authenticationOption: authenticationOption
                      ),
                      appSecurityPasswordManager: appSecurityPasswordManager
                  ))
    }

    func testLoadingBiometricAppAuthentication() {
        testStore(for: .biometry(.faceID)).assert(
            .send(.loadAppAuthenticationOption) { _ in },
            .do { self.testScheduler.advance() },
            .receive(.loadAppAuthenticationOptionResponse(.biometry(.faceID))) {
                $0.biometrics = AppAuthenticationBiometricsDomain.State(biometryType: .faceID)
            }
        )
    }

    func testLoadingPasswordAppAuthentication() {
        let testStore = testStore(for: .password)

        userDataStore.appSecurityOption = Just(3).eraseToAnyPublisher()

        testStore.send(.loadAppAuthenticationOption)

        testScheduler.run()

        testStore.receive(.loadAppAuthenticationOptionResponse(.password)) { state in
            state.password = AppAuthenticationPasswordDomain.State()
        }
    }

    func testLoadingPasswordAppAuthenticationResponse() {
        let testStore = testStore(for: .password)

        testStore.send(.loadAppAuthenticationOptionResponse(.password)) { state in
            state.password = AppAuthenticationPasswordDomain.State()
        }
    }

    func testCloseAppAuthenticationPasswordViewWhenPasswordVerified() {
        var didCompleteAuthenticationCalledCount = 0
        var didCompleteAuthenticationCalled: Bool {
            didCompleteAuthenticationCalledCount > 0
        }

        let store = TestStore(
            initialState: AppAuthenticationDomain.State(
                biometrics: nil,
                password: AppAuthenticationPasswordDomain.State()
            ),
            reducer: AppAuthenticationDomain.reducer,
            environment: AppAuthenticationDomain.Environment(
                userDataStore: MockUserDataStore(),
                schedulers: Schedulers(
                    uiScheduler: testScheduler.eraseToAnyScheduler()
                ),
                appAuthenticationProvider: MockAuthenticationProvider(
                    authenticationOption: .password
                ),
                appSecurityPasswordManager: appSecurityPasswordManager,
                didCompleteAuthentication: { didCompleteAuthenticationCalledCount += 1 }
            )
        )

        expect(didCompleteAuthenticationCalled).to(beFalse())
        store.send(.password(action: .closeAfterPasswordVerified)) { state in
            state.didCompleteAuthentication = true
            state.password = nil
        }
        expect(didCompleteAuthenticationCalled).to(beTrue())
    }
}
