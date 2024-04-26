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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class AppAuthenticationDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate.eraseToAnyScheduler()

    typealias TestStore = TestStoreOf<AppAuthenticationDomain>

    struct MockAuthenticationProvider: AppAuthenticationProvider {
        var authenticationOption: AppSecurityOption

        func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityOption, Never> {
            Just(authenticationOption)
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
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        return TestStore(initialState: AppAuthenticationDomain.State()) {
            AppAuthenticationDomain {}
        } withDependencies: { dependencies in
            dependencies.userDataStore = userDataStore
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.appAuthenticationProvider = MockAuthenticationProvider(
                authenticationOption: authenticationOption
            )
            dependencies.appSecurityManager = appSecurityPasswordManager
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
        }
    }

    func testLoadingBiometricAppAuthenticationWithoutPreviousFailedAuthentications() async {
        let store = testStore(for: .biometry(.faceID))
        userDataStore.underlyingFailedAppAuthentications = Just(0).eraseToAnyPublisher() // no failed authentications

        await store.send(.task)
        await store.receive(.failedAppAuthenticationsReceived(0))
        await store.receive(.loadAppAuthenticationOptionResponse(.biometry(.faceID), 0)) {
            $0.biometrics = AppAuthenticationBiometricsDomain.State(
                biometryType: .faceID,
                startImmediateAuthenticationChallenge: true
            )
            $0.failedAuthenticationsCount = 0
            $0.didCompleteAuthentication = false
            $0.password = nil
        }
    }

    func testLoadingBiometricAppAuthenticationWithPreviousFailedAuthentications() async {
        let store = testStore(for: .biometry(.faceID))
        userDataStore.underlyingFailedAppAuthentications = Just(1).eraseToAnyPublisher()

        await store.send(.task)
        await store.receive(.failedAppAuthenticationsReceived(1)) {
            $0.biometrics = nil
            $0.password = nil
            $0.failedAuthenticationsCount = 1
            $0.didCompleteAuthentication = false
        }
        await store.receive(.loadAppAuthenticationOptionResponse(.biometry(.faceID), 1)) {
            $0.biometrics = AppAuthenticationBiometricsDomain.State(
                biometryType: .faceID,
                startImmediateAuthenticationChallenge: false
            )
            $0.failedAuthenticationsCount = 1
            $0.didCompleteAuthentication = false
            $0.password = nil
        }
    }

    func testCloseAppAuthenticationBiometryViewWhenVerified() async {
        var didCompleteAuthenticationCalledCount = 0
        var didCompleteAuthenticationCalled: Bool {
            didCompleteAuthenticationCalledCount > 0
        }

        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()

        let store = TestStore(
            initialState: AppAuthenticationDomain.State(
                biometrics: AppAuthenticationBiometricsDomain.State(
                    biometryType: .touchID,
                    startImmediateAuthenticationChallenge: false
                ),
                password: nil
            )
        ) {
            AppAuthenticationDomain { didCompleteAuthenticationCalledCount += 1 }
        } withDependencies: { dependencies in
            dependencies.userDataStore = MockUserDataStore()
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.appAuthenticationProvider = MockAuthenticationProvider(
                authenticationOption: .biometry(.touchID)
            )
            dependencies.appSecurityManager = appSecurityPasswordManager
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
        }

        let expectedResponse = AuthenticationChallengeProviderResult.success(true)
        expect(didCompleteAuthenticationCalled).to(beFalse())
        await store.send(.biometrics(action: .authenticationChallengeResponse(expectedResponse))) { state in
            state.didCompleteAuthentication = true
            state.password = nil
            state.biometrics = nil
        }
        expect(didCompleteAuthenticationCalled).to(beTrue())
    }

    func testLoadingPasswordAppAuthentication() async {
        let testStore = testStore(for: .password)

        userDataStore.failedAppAuthentications = Just(0).eraseToAnyPublisher()
        userDataStore.appSecurityOption = Just(.password).eraseToAnyPublisher()

        await testStore.send(.task)
        await testStore.receive(.failedAppAuthenticationsReceived(0))
        await testStore.receive(.loadAppAuthenticationOptionResponse(.password, 0)) { state in
            state.password = AppAuthenticationPasswordDomain.State()
        }
    }

    func testLoadingPasswordAppAuthenticationResponse() async {
        let testStore = testStore(for: .password)

        await testStore.send(.loadAppAuthenticationOptionResponse(.password, 0)) { state in
            state.password = AppAuthenticationPasswordDomain.State()
        }
    }

    func testCloseAppAuthenticationPasswordViewWhenPasswordVerified() async {
        var didCompleteAuthenticationCalledCount = 0
        var didCompleteAuthenticationCalled: Bool {
            didCompleteAuthenticationCalledCount > 0
        }

        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()

        let store = TestStore(
            initialState: AppAuthenticationDomain.State(
                biometrics: nil,
                password: AppAuthenticationPasswordDomain.State()
            )
        ) {
            AppAuthenticationDomain { didCompleteAuthenticationCalledCount += 1 }
        } withDependencies: { dependencies in
            dependencies.userDataStore = MockUserDataStore()
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.appAuthenticationProvider = MockAuthenticationProvider(
                authenticationOption: .password
            )
            dependencies.appSecurityManager = appSecurityPasswordManager
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
        }

        expect(didCompleteAuthenticationCalled).to(beFalse())
        await store.send(.password(action: .passwordVerificationReceived(true))) { state in
            state.didCompleteAuthentication = true
            state.password = nil
        }
        expect(didCompleteAuthenticationCalled).to(beTrue())
    }
}
