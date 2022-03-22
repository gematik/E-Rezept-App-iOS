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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import Nimble
import XCTest

final class RecordActionsForHintsTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let reducer = Reducer<AppDomain.State, AppDomain.Action, AppDomain.Environment>.empty.recordActionsForHints()

    typealias TestStore = ComposableArchitecture.TestStore<
        AppDomain.State,
        AppDomain.State,
        AppDomain.Action,
        AppDomain.Action,
        AppDomain.Environment
    >

    private func testStore(
        sessionContainer: UsersSessionContainer,
        for groupedPrescriptionListState: GroupedPrescriptionListDomain.State = GroupedPrescriptionListDomain.State()
    ) -> TestStore {
        TestStore(
            initialState: AppDomain.State(
                selectedTab: .main,
                main: MainDomain.State(
                    scannerState: nil,
                    prescriptionListState: groupedPrescriptionListState,
                    isDemoMode: false
                ),
                pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                messages: MessagesDomain.State(communications: []),
                settingsState: .init(isDemoMode: false,
                                     appSecurityState: .init(
                                         availableSecurityOptions: [],
                                         selectedSecurityOption: nil,
                                         errorToDisplay: nil,
                                         createPasswordState: nil
                                     )),
                profileSelection: .init(
                    profile: UserProfile.Fixtures.theo,
                    profileSelectionState: .init()
                ),
                debug: .init(trackingOptOut: true),
                unreadMessagesCount: 0,
                isDemoMode: false
            ),
            reducer: reducer,
            environment: AppDomain.Environment(
                router: MockRouting(),
                userSessionContainer: sessionContainer,
                userSession: sessionContainer.userSession,
                userDataStore: MockUserDataStore(),
                schedulers: Schedulers(),
                fhirDateFormatter: globals.fhirDateFormatter,
                serviceLocator: ServiceLocator(),
                accessibilityAnnouncementReceiver: { _ in },
                tracker: DummyTracker(),
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )
    }

    func testRecordActionsForHintsReducerHappyPath() {
        let mockSessionContainer = MockUserSessionContainer()
        let groupedPrescriptions = GroupedPrescription.Dummies.twoPrescriptions
        let prescriptionLoadingState =
            LoadingState<[GroupedPrescription], ErxRepositoryError>
                .value([groupedPrescriptions])
        let groupedPrescriptionListState = GroupedPrescriptionListDomain.State(
            loadingState: prescriptionLoadingState,
            cardWallState: nil,
            groupedPrescriptions: [groupedPrescriptions],
            redeemState: nil
        )
        let store = testStore(sessionContainer: mockSessionContainer,
                              for: groupedPrescriptionListState)

        expect(mockSessionContainer.userSession.hintEventsStore.hintState.hasDemoModeBeenToggledBefore).to(beFalse())
        expect(mockSessionContainer.userSession.hintEventsStore.hintState.hasTasksInLocalStore).to(beFalse())

        // when toggling the demo mode
        store.send(.settings(action: .toggleDemoModeSwitch)) { _ in
            // than the hint state should be changed from the `recordActionsForHints` reducer
            expect(mockSessionContainer.userSession.hintEventsStore.hintState.hasDemoModeBeenToggledBefore)
                .to(beTrue())
        }
        // when prescriptions were loaded and have results
        store.send(
            .main(
                action: .prescriptionList(action: .loadLocalGroupedPrescriptionsReceived(prescriptionLoadingState))
            )
        ) { _ in
            // than hint state should change from the `recordActionsForHints` reducer
            expect(mockSessionContainer.userSession.hintEventsStore.hintState.hasTasksInLocalStore).to(beTrue())
        }
    }

    func testRecordActionsForHintsReducerWhenThereAreNoTasksInLocalStore() {
        let sessionContainer = MockUserSessionContainer()
        let store = testStore(sessionContainer: sessionContainer)

        expect(sessionContainer.userSession.hintEventsStore.hintState.hasTasksInLocalStore).to(beFalse())
        // when prescriptions were loaded and have no results
        store.send(.main(action: .prescriptionList(action: .loadLocalGroupedPrescriptionsReceived(LoadingState
                .idle)))) { _ in
                // than hint state should not be changed from the `recordActionsForHints` reducer
                expect(sessionContainer.userSession.hintEventsStore.hintState.hasTasksInLocalStore).to(beFalse())
        }
    }
}
