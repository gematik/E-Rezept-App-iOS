//
//  Copyright (c) 2022 gematik GmbH
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
    let testScheduler = DispatchQueue.immediate.eraseToAnyScheduler()

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
                      appSecurityPasswordManager: appSecurityPasswordManager,
                      authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true))
                  ))
    }

    func testLoadingBiometricAppAuthenticationWithoutPreviousFailedAuthentications() {
        let store = testStore(for: .biometry(.faceID))
        userDataStore.underlyingFailedAppAuthentications.send(0) // no failed authentications

        store.send(.onAppear)
        store.receive(.failedAppAuthenticationsReceived(0)) {
            $0.biometrics = nil
            $0.password = nil
            $0.failedAuthenticationsCount = 0
            $0.didCompleteAuthentication = false
        }
        store.receive(.loadAppAuthenticationOptionResponse(.biometry(.faceID), 0)) {
            $0.biometrics = AppAuthenticationBiometricsDomain.State(
                biometryType: .faceID,
                startImmediateAuthenticationChallenge: true
            )
            $0.failedAuthenticationsCount = 0
            $0.didCompleteAuthentication = false
            $0.password = nil
        }
        store.send(.removeSubscriptions) // cancel long running effects
    }

    func testLoadingBiometricAppAuthenticationWithPreviousFailedAuthentications() {
        let store = testStore(for: .biometry(.faceID))
        userDataStore.underlyingFailedAppAuthentications.send(1)

        store.send(.onAppear)
        store.receive(.failedAppAuthenticationsReceived(1)) {
            $0.biometrics = nil
            $0.password = nil
            $0.failedAuthenticationsCount = 1
            $0.didCompleteAuthentication = false
        }
        store.receive(.loadAppAuthenticationOptionResponse(.biometry(.faceID), 1)) {
            $0.biometrics = AppAuthenticationBiometricsDomain.State(
                biometryType: .faceID,
                startImmediateAuthenticationChallenge: false
            )
            $0.failedAuthenticationsCount = 1
            $0.didCompleteAuthentication = false
            $0.password = nil
        }
        store.send(.removeSubscriptions)
    }

    func testCloseAppAuthenticationBiometryViewWhenVerified() {
        var didCompleteAuthenticationCalledCount = 0
        var didCompleteAuthenticationCalled: Bool {
            didCompleteAuthenticationCalledCount > 0
        }

        let store = TestStore(
            initialState: AppAuthenticationDomain.State(
                biometrics: AppAuthenticationBiometricsDomain.State(
                    biometryType: .touchID,
                    startImmediateAuthenticationChallenge: false
                ),
                password: nil
            ),
            reducer: AppAuthenticationDomain.reducer,
            environment: AppAuthenticationDomain.Environment(
                userDataStore: MockUserDataStore(),
                schedulers: Schedulers(
                    uiScheduler: testScheduler.eraseToAnyScheduler()
                ),
                appAuthenticationProvider: MockAuthenticationProvider(
                    authenticationOption: .biometry(.touchID)
                ),
                appSecurityPasswordManager: appSecurityPasswordManager,
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true)),
                didCompleteAuthentication: { didCompleteAuthenticationCalledCount += 1 }
            )
        )

        let expectedResponse = Result<Bool, AppAuthenticationBiometricsDomain.Error>.success(true)
        expect(didCompleteAuthenticationCalled).to(beFalse())
        store.send(.biometrics(action: .authenticationChallengeResponse(expectedResponse))) { state in
            state.didCompleteAuthentication = true
            state.password = nil
            state.biometrics = nil
        }
        expect(didCompleteAuthenticationCalled).to(beTrue())
    }

    func testLoadingPasswordAppAuthentication() {
        let testStore = testStore(for: .password)
        userDataStore.appSecurityOption = Just(3).eraseToAnyPublisher()

        testStore.send(.onAppear)
        testStore.receive(.failedAppAuthenticationsReceived(0)) {
            $0.biometrics = nil
            $0.password = nil
            $0.failedAuthenticationsCount = 0
            $0.didCompleteAuthentication = false
        }
        testStore.receive(.loadAppAuthenticationOptionResponse(.password, 0)) { state in
            state.password = AppAuthenticationPasswordDomain.State()
        }
        testStore.send(.removeSubscriptions)
    }

    func testLoadingPasswordAppAuthenticationResponse() {
        let testStore = testStore(for: .password)

        testStore.send(.loadAppAuthenticationOptionResponse(.password, 0)) { state in
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
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true)),
                didCompleteAuthentication: { didCompleteAuthenticationCalledCount += 1 }
            )
        )

        expect(didCompleteAuthenticationCalled).to(beFalse())
        store.send(.password(action: .passwordVerificationReceived(true))) { state in
            state.didCompleteAuthentication = true
            state.password = nil
        }
        expect(didCompleteAuthenticationCalled).to(beTrue())
    }
}
