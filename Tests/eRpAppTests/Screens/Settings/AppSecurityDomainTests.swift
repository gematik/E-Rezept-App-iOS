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
import eRpKit
import Nimble
import XCTest

final class AppSecurityDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppSecurityDomain.State,
        AppSecurityDomain.State,
        AppSecurityDomain.Action,
        AppSecurityDomain.Action,
        AppSecurityDomain.Environment
    >
    var mockUserDataStore: MockUserDataStore!
    var mockAppSecurityPasswordManager: MockAppSecurityPasswordManager!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        mockAppSecurityPasswordManager = MockAppSecurityPasswordManager()
    }

    private func testStore(for availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [],
                           selectedSecurityOption: AppSecurityDomain.AppSecurityOption? = nil) -> TestStore {
        var appSecurityEnvironment = AppSecurityDomain.Environment(
            userDataStore: mockUserDataStore,
            appSecurityPasswordManager: mockAppSecurityPasswordManager,
            schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        )
        appSecurityEnvironment.getAvailableSecurityOptions = {
            (availableSecurityOptions, nil)
        }()

        mockUserDataStore.appSecurityOption = Just(selectedSecurityOption?.id ?? 0).eraseToAnyPublisher()

        return TestStore(initialState: AppSecurityDomain.State(),
                         reducer: AppSecurityDomain.reducer,
                         environment: appSecurityEnvironment)
    }

    func testLoadingAvailableSecurityOptions_Without_Biometry() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.unsecured]

        let store = testStore(for: availableSecurityOptions)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(nil)) { _ in }
        )
    }

    func testLoadingAvailableSecurityOptions_With_Biometry() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]

        let store = testStore(for: availableSecurityOptions)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(nil)) { _ in }
        )
    }

    func testLoadingAvailableSecurityOptions_None_Selected() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = nil

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            }
        )
    }

    func testLoadingAvailableSecurityOptions_Biometry_Selected() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            }
        )
    }

    func testLoadingAvailableSecurityOptions_Unsecured_Selected() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = .unsecured

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            }
        )
    }

    func testSelectingAppSecurityOption_From_None_To_Unsecured() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = nil
        let selectedSecurityOption: AppSecurityDomain.AppSecurityOption = .unsecured

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            },
            .send(.select(selectedSecurityOption)) {
                $0.selectedSecurityOption = selectedSecurityOption
            }
        )
    }

    func testSelectingAppSecurityOption_From_None_To_Biometry() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = nil
        let selectedSecurityOption: AppSecurityDomain.AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            },
            .send(.select(selectedSecurityOption)) {
                $0.selectedSecurityOption = selectedSecurityOption
            }
        )
    }

    func testSelectingAppSecurityOption_From_None_To_Password() {
        let state = AppSecurityDomain.State(
            availableSecurityOptions: [.password, .unsecured],
            selectedSecurityOption: nil,
            errorToDisplay: nil,
            createPasswordState: nil
        )

        let store = TestStore(initialState: state,
                              reducer: AppSecurityDomain.reducer,
                              environment: AppSecurityDomain.Environment(
                                  userDataStore: MockUserDataStore(),
                                  appSecurityPasswordManager: mockAppSecurityPasswordManager,
                                  schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
                              ))

        store.send(.select(.password)) { state in
            state.createPasswordState = CreatePasswordDomain.State(mode: .create)
        }
    }

    func testSelectingAppSecurityOption_From_Password_To_Password() {
        let state = AppSecurityDomain.State(
            availableSecurityOptions: [.password, .unsecured],
            selectedSecurityOption: .password,
            errorToDisplay: nil,
            createPasswordState: nil
        )

        let store = TestStore(initialState: state,
                              reducer: AppSecurityDomain.reducer,
                              environment: AppSecurityDomain.Environment(
                                  userDataStore: MockUserDataStore(),
                                  appSecurityPasswordManager: mockAppSecurityPasswordManager,
                                  schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
                              ))

        store.send(.select(.password)) { state in
            state.createPasswordState = CreatePasswordDomain.State(mode: .update)
        }
    }

    func testSelectingAppSecurityOption_From_Unsecured_To_Biometry() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = .unsecured
        let selectedSecurityOption: AppSecurityDomain.AppSecurityOption = .biometry(.faceID)

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            },
            .send(.select(selectedSecurityOption)) {
                $0.selectedSecurityOption = selectedSecurityOption
            }
        )
    }

    func testSelectingAppSecurityOption_From_Biometry_To_Unsecured() {
        let availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [.biometry(.faceID), .unsecured]
        let preSelectedSecurityOption: AppSecurityDomain.AppSecurityOption? = .biometry(.faceID)
        let selectedSecurityOption: AppSecurityDomain.AppSecurityOption = .unsecured

        let store = testStore(for: availableSecurityOptions,
                              selectedSecurityOption: preSelectedSecurityOption)

        store.assert(
            .send(.loadSecurityOption) {
                $0.availableSecurityOptions = availableSecurityOptions
            },
            .do { self.testScheduler.advance() },
            .receive(.loadSecurityOptionResponse(preSelectedSecurityOption)) {
                $0.selectedSecurityOption = preSelectedSecurityOption
            },
            .send(.select(selectedSecurityOption)) {
                $0.selectedSecurityOption = selectedSecurityOption
            }
        )
    }

    func testCloseCreatePasswordViewOnClose() {
        let state = AppSecurityDomain.State(
            availableSecurityOptions: [.password, .unsecured],
            selectedSecurityOption: nil,
            errorToDisplay: nil,
            createPasswordState: CreatePasswordDomain.State(mode: .create)
        )

        let store = TestStore(initialState: state,
                              reducer: AppSecurityDomain.reducer,
                              environment: AppSecurityDomain.Environment(
                                  userDataStore: mockUserDataStore,
                                  appSecurityPasswordManager: mockAppSecurityPasswordManager,
                                  schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
                              ))

        expect(self.mockUserDataStore.setAppSecurityOptionCalled) == false

        store.send(.createPassword(action: .closeAfterPasswordSaved)) { state in
            state.createPasswordState = nil
            state.selectedSecurityOption = .password
        }

        expect(self.mockUserDataStore.setAppSecurityOptionCalled) == true
    }
}
