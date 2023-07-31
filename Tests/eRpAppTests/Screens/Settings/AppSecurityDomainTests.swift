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

import Combine
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class AppSecurityDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppSecurityDomain.State,
        AppSecurityDomain.Action,
        AppSecurityDomain.State,
        AppSecurityDomain.Action,
        Void
    >
    var mockUserDataStore: MockUserDataStore!
    var mockAppSecurityManager: MockAppSecurityManager!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        mockAppSecurityManager = MockAppSecurityManager()
    }

    private func testStore(for availableSecurityOptions: [AppSecurityOption] = [],
                           selectedSecurityOption: AppSecurityOption? = nil) -> TestStore {
        mockAppSecurityManager.availableSecurityOptionsReturnValue = (availableSecurityOptions, nil)
        mockUserDataStore.appSecurityOption = Just(selectedSecurityOption ?? .unsecured).eraseToAnyPublisher()

        return TestStore(
            initialState: AppSecurityDomain.State(availableSecurityOptions: [.password]),
            reducer: AppSecurityDomain()
        ) { dependencies in
            dependencies.userDataStore = mockUserDataStore
            dependencies.appSecurityManager = mockAppSecurityManager
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testLoadingAvailableSecurityOptions_Without_Biometry() {
        let availableSecurityOptions: [AppSecurityOption] = [.unsecured]

        let store = testStore(for: availableSecurityOptions)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_With_Biometry() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]

        let store = testStore(for: availableSecurityOptions)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_Unspecified_Selected() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]

        let store = testStore(for: availableSecurityOptions)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(.unsecured))) {
            $0.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingAvailableSecurityOptions_Biometry_Selected() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
    }

    func testLoadingAvailableSecurityOptions_Unsecured_Selected() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityOption = .unsecured

        let store = testStore(for: availableSecurityOptions)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
    }

    func testSelectingAppSecurityOption_From_Biometry_To_BiometryAndPassword() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)
        let selectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }

        store.send(.togglePasswordSelected)
        testScheduler.advance()
        store.receive(.setNavigation(tag: .appPassword)) {
            $0.destination = .appPassword(.init(mode: .create))
        }

        store.send(.destination(.appPasswordAction(.delegate(.closeAfterPasswordSaved)))) {
            $0.destination = nil
        }
        testScheduler.advance()
        store.receive(.select(selectedSecurityOption)) {
            $0.selectedSecurityOption = .biometryAndPassword(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_Password_To_BiometryAndPassword() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .password
        let selectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }

        store.send(.toggleBiometricSelected(.faceID))
        testScheduler.advance()
        store.receive(.select(selectedSecurityOption)) {
            $0.selectedSecurityOption = .biometryAndPassword(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_Biometric_To_BiometryAndPassword_Failed() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        store.send(.togglePasswordSelected)
        testScheduler.advance()
        store.receive(.setNavigation(tag: .appPassword)) {
            $0.destination = .appPassword(.init(mode: .create))
        }

        store.send(.setNavigation(tag: nil)) {
            $0.destination = nil
            $0.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_BiometryAndPassword_To_Biometry() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured, .password,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        store.send(.togglePasswordSelected)
        testScheduler.advance()
        store.receive(.select(.biometry(.faceID))) {
            $0.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectingAppSecurityOption_From_BiometryAndPassword_To_Password() {
        let availableSecurityOptions: [AppSecurityOption] = [.biometry(.faceID), .unsecured,
                                                             .biometryAndPassword(.faceID)]
        let preSelectedSecurityOption: AppSecurityOption = .biometryAndPassword(.faceID)

        let store = testStore(for: availableSecurityOptions, selectedSecurityOption: preSelectedSecurityOption)

        store.send(.loadSecurityOption) {
            $0.availableSecurityOptions = availableSecurityOptions
        }
        testScheduler.advance()
        store.receive(.response(.loadSecurityOption(preSelectedSecurityOption))) {
            $0.selectedSecurityOption = preSelectedSecurityOption
        }
        store.send(.toggleBiometricSelected(.faceID))
        testScheduler.advance()
        store.receive(.select(.password)) {
            $0.selectedSecurityOption = .password
        }
    }
}
