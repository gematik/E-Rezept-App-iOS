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
                subdomains: .init(
                    main: Self.Fixtures.mainDomainState,
                    pharmacySearch: Self.Fixtures.pharmacySearchDomainState,
                    orders: Self.Fixtures.ordersDomainState,
                    settingsState: SettingsDomain.State(
                        isDemoMode: false,
                        destination: nil
                    )
                ),
                unreadOrderMessageCount: 0,
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
                subdomains: .init(
                    main: Self.Fixtures.mainDomainState,
                    pharmacySearch: Self.Fixtures.pharmacySearchDomainState,
                    orders: Self.Fixtures.ordersDomainState,
                    settingsState: SettingsDomain.State(
                        isDemoMode: false,
                        destination: .healthCardPasswordForgotPin(.init(mode: .forgotPin))
                    )
                ),
                unreadOrderMessageCount: 0,
                isDemoMode: false
            )
        ) {
            AppDomain()
        }

        await testStore.send(.setNavigation(.settings)) {
            $0.subdomains = .init(
                main: Self.Fixtures.mainDomainState,
                pharmacySearch: Self.Fixtures.pharmacySearchDomainState,
                orders: Self.Fixtures.ordersDomainState,
                settingsState: SettingsDomain.State(
                    isDemoMode: false,
                    destination: nil
                )
            )
        }
    }

    func testTappingOnActiveTabItem_twoLinksDownLeadsToTabViewsRootView() async {
        let testStore = TestStore(
            initialState: .init(
                destination: .settings,
                subdomains: .init(
                    main: Self.Fixtures.mainDomainState,
                    pharmacySearch: Self.Fixtures.pharmacySearchDomainState,
                    orders: Self.Fixtures.ordersDomainState,
                    settingsState: SettingsDomain.State(
                        isDemoMode: false,
                        destination: .healthCardPasswordForgotPin(
                            .init(
                                mode: .forgotPin,
                                destination: .readCard(
                                    .init(mode: .healthCardResetPinCounterNoNewSecret(can: "", puk: ""))
                                )
                            )
                        )
                    )
                ),
                unreadOrderMessageCount: 0,
                isDemoMode: false
            )
        ) {
            AppDomain()
        }

        await testStore.send(.setNavigation(.settings)) {
            $0.subdomains = .init(
                main: Self.Fixtures.mainDomainState,
                pharmacySearch: Self.Fixtures.pharmacySearchDomainState,
                orders: Self.Fixtures.ordersDomainState,
                settingsState: SettingsDomain.State(
                    isDemoMode: false,
                    destination: nil
                )
            )
        }
    }

    enum Fixtures {
        static let mainDomainState = MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
        )

        static let pharmacySearchDomainState = PharmacySearchDomain.State(
            erxTasks: [],
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: [],
            searchState: .searchResultEmpty
        )

        static let ordersDomainState = OrdersDomain.State()
    }
}
