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

    class MockUserDataStore: UserDataStore {
        var hideOnboarding: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
        func set(hideOnboarding _: Bool) {
            // Do nothing
        }

        var hideCardWallIntro: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
        func set(hideCardWallIntro _: Bool) {
            // Do nothing
        }

        var serverEnvironmentConfiguration: AnyPublisher<String?, Never> = Just(nil).eraseToAnyPublisher()
        func set(serverEnvironmentConfiguration _: String?) {
            // Do nothing
        }

        private var appSecurityOptionCurrentValue: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)
        var appSecurityOption: AnyPublisher<Int, Never> {
            appSecurityOptionCurrentValue.eraseToAnyPublisher()
        }

        func set(appSecurityOption: Int) {
            appSecurityOptionCurrentValue.send(appSecurityOption)
        }

        var appTrackingAllowed: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
        func set(appTrackingAllowed _: Bool) {
            // Do nothing
        }
    }

    private func testStore(for availableSecurityOptions: [AppSecurityDomain.AppSecurityOption] = [],
                           selectedSecurityOption: AppSecurityDomain.AppSecurityOption? = nil) -> TestStore {
        var appSecurityEnvironment = AppSecurityDomain.Environment(
            userDataStore: MockUserDataStore(),
            schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        )
        appSecurityEnvironment.getAvailableSecurityOptions = {
            (availableSecurityOptions, nil)
        }()

        if let selectedSecurityOption = selectedSecurityOption {
            appSecurityEnvironment.selectedSecurityOption.set(selectedSecurityOption)
        }

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
}
