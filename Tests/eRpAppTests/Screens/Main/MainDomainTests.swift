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

import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class MainDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        MainDomain.State,
        MainDomain.State,
        MainDomain.Action,
        MainDomain.Action,
        MainDomain.Environment
    >

    func testStore() -> TestStore {
        testStore(for: MainDomain.Dummies.state)
    }

    func testStore(for state: MainDomain.State) -> TestStore {
        TestStore(initialState: state,
                  reducer: MainDomain.reducer,
                  environment: MainDomain.Environment(
                      router: DummyRouter(),
                      userSessionContainer: DummyUserSessionContainer(),
                      userSession: DummySessionContainer(),
                      appSecurityManager: DemoAppSecurityPasswordManager(),
                      serviceLocator: ServiceLocator(),
                      accessibilityAnnouncementReceiver: { _ in },
                      erxTaskRepository: DummySessionContainer().erxTaskRepository,
                      schedulers: Schedulers(),
                      fhirDateFormatter: globals.fhirDateFormatter,
                      userProfileService: DummyUserProfileService(),
                      secureDataWiper: DummyProfileSecureDataWiper(),
                      signatureProvider: DummySecureEnclaveSignatureProvider(),
                      userSessionProvider: DummyUserSessionProvider(),
                      userDataStore: DemoUserDefaultsStore(),
                      tracker: DummyTracker()
                  ))
    }

    func testDemoModeChange() {
        // givn
        let sut = testStore()

        // when
        sut.send(.demoModeChangeReceived(true)) { sut in
            // then
            sut.isDemoMode = true
        }

        // when
        sut.send(.demoModeChangeReceived(false)) { sut in
            // then
            sut.isDemoMode = false
        }
    }

    func testWhenLoadingProfileWithError() {
        // given
        let sut = testStore()
        let error = UserProfileServiceError.localStoreError(.notImplemented)

        // when
        sut.send(.horizontalProfileSelection(action: .loadReceived(.failure(error)))) { sut in
            // then
            sut.route = .alert(MainDomain.AlertStates.for(error))
        }
    }
}
