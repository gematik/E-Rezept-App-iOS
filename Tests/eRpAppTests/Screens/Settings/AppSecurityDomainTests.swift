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
final class AppSecurityDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<AppSecurityDomain>
    var mockUserDataStore: MockUserDataStore!
    var mockAppSecurityManager: MockAppSecurityManager!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        mockAppSecurityManager = MockAppSecurityManager()
    }

    private func testStore(for availableSecurityOptions: [AppSecurityOption] = [],
                           selectedSecurityOption: AppSecurityOption? = nil) -> TestStore {
        mockAppSecurityManager.underlyingAvailableSecurityOptions = (availableSecurityOptions, nil)
        mockUserDataStore.appSecurityOption = Just(selectedSecurityOption ?? .unsecured).eraseToAnyPublisher()

        return TestStore(initialState: AppSecurityDomain.State(availableSecurityOptions: [.password])) {
            AppSecurityDomain()
        } withDependencies: { dependencies in
            dependencies.userDataStore = mockUserDataStore
            dependencies.appSecurityManager = mockAppSecurityManager
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testLoadingAvailableSecurityOptions_Without_Biometry() async {
        let availableSecurityOptions: [AppSecurityOption] = [.unsecured]

        let store = testStore(for: availableSecurityOptions)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_With_Biometry() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]

        let store = testStore(for: availableSecurityOptions)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_Unspecified_Selected() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]

        let store = testStore(for: availableSecurityOptions)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_Biometry_Selected() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
    }

    func testLoadingAvailableSecurityOptions_Unsecured_Selected() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityOption = .unsecured

        let store = testStore(for: availableSecurityOptions)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
    }

    func testLoadingAvailableSecurityOptions_BiometricAndPassword_Selected() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
    }

    func testLoadingAvailableSecurityOptions_BiometricAndPassword_Selected_And_Biometric_Not_Enrolled() async {
        let availableSecurityOptions: [AppSecurityOption] = [.password, .unsecured]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = .password
        }
    }

    func testSelectingAppSecurityOption_From_Biometry_To_BiometryAndPassword() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)
        let selectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }

        await store.send(.togglePasswordSelected)
        await testScheduler.advance()
        await store.receive(.appPasswordTapped) {
            $0.destination = .appPassword(.init(mode: .create))
        }

        await store.send(.destination(.presented(.appPassword(.delegate(.closeAfterPasswordSaved(mode: .create)))))) {
            $0.destination = nil
        }
        await testScheduler.advance()
        await store.receive(.select(selectedSecurityOption)) {
            $0.selectedSecurityOption = .biometryAndPassword(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_Password_To_BiometryAndPassword() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .password
        let selectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }

        await store.send(.toggleBiometricSelected(.faceID))
        await testScheduler.advance()
        await store.receive(.select(selectedSecurityOption)) {
            $0.selectedSecurityOption = .biometryAndPassword(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_Biometric_To_BiometryAndPassword_Failed() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        await store.send(.togglePasswordSelected)
        await testScheduler.advance()
        await store.receive(.appPasswordTapped) {
            $0.destination = .appPassword(.init(mode: .create))
        }

        await store.send(.resetNavigation) {
            $0.destination = nil
            $0.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_BiometryAndPassword_To_Biometry() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        await store.send(.togglePasswordSelected)
        await testScheduler.advance()
        await store.receive(.select(.biometry(.faceID))) {
            $0.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_BiometryAndPassword_To_Password() async {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        await store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        await testScheduler.advance()
        await store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        await store.send(.toggleBiometricSelected(.faceID))
        await testScheduler.advance()
        await store.receive(.select(.password)) {
            $0.selectedSecurityOption = .password
        }
    }
}
