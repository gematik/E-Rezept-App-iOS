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
import ComposableArchitecture
@testable import eRpFeatures
import Nimble
import XCTest

@MainActor
final class AppDomainTests: XCTestCase {
    var mockUserDataStore: MockUserDataStore!

    typealias TestStore = TestStoreOf<AppDomain>

    override func setUp() {
        super.setUp()
    }

    func testTappingOnActiveTabItem_rootView() async {
        let testStore = TestStore(
            initialState: .init(
                destination: .settings,
                main: Self.Fixtures.mainDomainState,
                pharmacy: Self.Fixtures.pharmacyContainerState,
                orders: Self.Fixtures.ordersDomainState,
                settings: SettingsDomain.State(
                    isDemoMode: false,
                    destination: nil
                ),
                unreadOrderMessageCount: 0,
                unreadInternalCommunicationCount: 0,
                isDemoMode: false
            )
        ) {
            AppDomain()
        }

        // when already in TabView's root destination, navigation state does not change
        await testStore.send(.setNavigation(.settings))
    }

    func testTappingOnActiveTabItem_oneLinkDownLeadsToTabViewsRootView() async {
        let testStore = TestStore(
            initialState: .init(
                destination: .settings,
                main: Self.Fixtures.mainDomainState,
                pharmacy: Self.Fixtures.pharmacyContainerState,
                orders: Self.Fixtures.ordersDomainState,
                settings: SettingsDomain.State(
                    isDemoMode: false,
                    destination: .healthCardPasswordForgotPin(.init(mode: .forgotPin))
                ),
                unreadOrderMessageCount: 0,
                unreadInternalCommunicationCount: 0,
                isDemoMode: false
            )
        ) {
            AppDomain()
        }

        await testStore.send(.setNavigation(.settings)) {
            $0.settings = SettingsDomain.State(
                isDemoMode: false,
                destination: nil
            )
        }
    }

    func testTappingOnActiveTabItem_twoLinksDownLeadsToTabViewsRootView() async {
        let testStore = TestStore(
            initialState: .init(
                destination: .settings,
                main: Self.Fixtures.mainDomainState,
                pharmacy: Self.Fixtures.pharmacyContainerState,
                orders: Self.Fixtures.ordersDomainState,
                settings: SettingsDomain.State(
                    isDemoMode: false,
                    destination: .healthCardPasswordForgotPin(HealthCardPasswordIntroductionDomain.State(
                        mode: .forgotPin,
                        destination: .can(HealthCardPasswordCanDomain.State(
                            mode: .forgotPin,
                            destination: .puk(HealthCardPasswordPukDomain.State(
                                mode: .forgotPin,
                                destination: .readCard(HealthCardPasswordReadCardDomain.State(
                                    mode: .healthCardResetPinCounterNoNewSecret(can: "", puk: "")
                                ))
                            ))
                        ))
                    ))
                ),
                unreadOrderMessageCount: 0,
                unreadInternalCommunicationCount: 0,
                isDemoMode: false
            )
        ) {
            AppDomain()
        }

        await testStore.send(.setNavigation(.settings)) {
            $0.settings = SettingsDomain.State(
                isDemoMode: false,
                destination: nil
            )
        }
    }

    enum Fixtures {
        static let mainDomainState = MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
        )

        static let pharmacyContainerState = PharmacyContainerDomain.State(
            pharmacySearch: pharmacySearchDomainState
        )

        static let pharmacySearchDomainState = PharmacySearchDomain.State(
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: [],
            pharmacyFilterOptions: Shared(value: []),
            searchState: .searchResultEmpty
        )

        static let ordersDomainState = OrdersDomain.State()
    }
}
