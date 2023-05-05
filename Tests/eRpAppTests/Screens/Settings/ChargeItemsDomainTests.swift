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

@MainActor
final class ChargeItemsDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ChargeItemsDomain.State,
        ChargeItemsDomain.Action,
        ChargeItemsDomain.State,
        ChargeItemsDomain.Action,
        Void
    >

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockChargeItemsDomainService: MockChargeItemsDomainService!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockChargeItemsDomainService = MockChargeItemsDomainService()
    }

    private func testStore(for state: ChargeItemsDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: ChargeItemsDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.chargeItemsDomainService = mockChargeItemsDomainService
        }
    }

    let testProfileId = UUID()

    func testFetchChargeItems_happyPath() async {
        let store = testStore(for: .init(profileId: testProfileId))

        // user enters ChargeItemsView for the first time, not authenticated
        mockChargeItemsDomainService.fetchChargeItemsForReturnValue = Just(.notAuthenticated).eraseToAnyPublisher()
        await store.send(.fetchChargeItems)
        await testScheduler.run()
        await store.receive(.response(.fetchChargeItems(.notAuthenticated))) { state in
            state.bottomBannerState = .authenticate
        }

        // user authenticates, consent was not given
        mockChargeItemsDomainService.authenticateForReturnValue = Just(.success).eraseToAnyPublisher()
        mockChargeItemsDomainService.fetchChargeItemsForReturnValue = Just(.consentNotGranted)
            .eraseToAnyPublisher()
        await store.send(.authenticateBottomBannerButtonTapped) { state in
            state.bottomBannerState = nil
        }
        await testScheduler.run()
        await store.receive(.authenticate) { state in
            state.authenticationState = .loading
        }
        await store.receive(.response(.authenticate(.success))) { state in
            state.authenticationState = .authenticated
        }
        await store.receive(.response(.fetchChargeItems(.consentNotGranted))) { state in
            state.grantConsentState = .notGranted
            state.destination = .alert(ChargeItemsDomain.AlertStates.grantConsentRequest)
        }

        // user grants consent, ok
        mockChargeItemsDomainService.grantChargeItemsConsentForReturnValue = Just(.success).eraseToAnyPublisher()
        let twoChargeItems: [ErxChargeItem] = [
            ErxChargeItem(identifier: UUID().uuidString, fhirData: Data(), enteredDate: "2022-05-01T11:13:00+00:00"),
            ErxChargeItem(identifier: UUID().uuidString, fhirData: Data(), enteredDate: "2021-06-01T07:13:00+05:00"),
        ]

        let twoChargeItemsGroups = twoChargeItems.asChargeItemGroups()
        mockChargeItemsDomainService
            .fetchChargeItemsAssumingConsentGrantedForReturnValue = Just(.success(twoChargeItems))
            .eraseToAnyPublisher()
        await store.send(.grantConsentAlertGrantButtonTapped) { state in
            state.destination = nil
        }
        await testScheduler.run()
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await store.receive(.response(.grantConsent(.success))) { state in
            state.grantConsentState = .granted
        }
        await store.receive(.response(.fetchChargeItems(.success(twoChargeItems)))) { state in
            state.chargeItemGroups = twoChargeItemsGroups
        }
    }

    func testFetchChargeItems_userDeniesGrantConsentRequest() async {
        let store = testStore(for: .init(profileId: testProfileId))

        // Try to fetch the ChargeItems, but no consent was given
        mockChargeItemsDomainService.fetchChargeItemsForReturnValue = Just(.consentNotGranted)
            .eraseToAnyPublisher()
        await store.send(.fetchChargeItems)
        await testScheduler.run()
        await store.receive(.response(.fetchChargeItems(.consentNotGranted))) { state in
            state.authenticationState = .authenticated
            state.grantConsentState = .notGranted
            state.destination = .alert(ChargeItemsDomain.AlertStates.grantConsentRequest)
        }

        // Deny to grant the consent
        await store.send(.grantConsentAlertDenyGrantButtonTapped) { state in
            state.grantConsentState = .userDeniedGrant
            state.bottomBannerState = .grantConsent
            state.destination = nil
        }

        // Give permission through the bottom banner, but an unexpected error occurs
        let error = ChargeItemsDomainServiceGrantResult.Error.unexpected
        mockChargeItemsDomainService.grantChargeItemsConsentForReturnValue = Just(.error(error))
            .eraseToAnyPublisher()
        await store.send(.grantConsentBottomBannerButtonTapped) { state in
            state.bottomBannerState = nil
        }
        await testScheduler.run()
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await store.receive(.response(.grantConsent(.error(.unexpected)))) { state in
            state.grantConsentState = .error
            state.destination = .alert(ChargeItemsDomain.AlertStates.grantConsentErrorFor(error: error))
        }

        // Retry to give permission through the alert, receive the unexpected error again
        await store.send(.grantConsentErrorAlertRetryButtonTapped) { state in
            state.destination = nil
        }
        await testScheduler.run()
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await store.receive(.response(.grantConsent(.error(.unexpected)))) { state in
            state.grantConsentState = .error
            state.destination = .alert(ChargeItemsDomain.AlertStates.grantConsentErrorFor(error: error))
        }

        // Discard the alert
        await store.send(.grantConsentErrorAlertOkayButtonTapped) { state in
            state.destination = nil
            state.bottomBannerState = .grantConsent
        }
    }

    func testRevokeConsent_happyPath() async {
        let store = testStore(
            for: .init(
                profileId: testProfileId,
                authenticationState: .authenticated,
                grantConsentState: .granted
            )
        )

        // user initiates deactivation/revocation of grant
        await store.send(.deactivateMenuButtonTapped) { state in
            state.destination = .alert(ChargeItemsDomain.AlertStates.revokeConsentRequest)
        }

        // user confirms
        mockChargeItemsDomainService.revokeChargeItemsConsentForReturnValue = Just(.success(.success))
            .eraseToAnyPublisher()
        await store.send(.revokeConsentAlertRevokeButtonTapped) { state in
            state.destination = nil
        }
        await testScheduler.run()
        await store.receive(.revokeConsent)
        await store.receive(.response(.revokeConsent(.success(.success)))) { state in
            state.grantConsentState = .notGranted
            state.bottomBannerState = .grantConsent
        }
    }
}
