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
import eRpKit
import HTTPClient
import Nimble
import XCTest

@MainActor
final class ChargeItemListDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<ChargeItemListDomain>

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockChargeItemListDomainService: MockChargeItemListDomainService!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockChargeItemListDomainService = MockChargeItemListDomainService()
    }

    private func testStore(for state: ChargeItemListDomain.State) -> TestStore {
        TestStore(initialState: state) {
            ChargeItemListDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.chargeItemsDomainService = mockChargeItemListDomainService
        }
    }

    let testProfileId = UUID()

    func testFetchChargeItems_happyPath() async {
        let store = testStore(for: .init(profileId: testProfileId))

        mockChargeItemListDomainService.fetchLocalChargeItemsForReturnValue = Just(.success([])).eraseToAnyPublisher()
        // user enters ChargeItemListView for the first time, not authenticated
        mockChargeItemListDomainService.fetchRemoteChargeItemsAndSaveForReturnValue = Just(.notAuthenticated)
            .eraseToAnyPublisher()
        await store.send(.fetchChargeItems)
        await testScheduler.run()
        await store.receive(.response(.fetchChargeItemsLocal(.success([]))))
        await store.receive(.response(.fetchChargeItemsRemote(.notAuthenticated))) { state in
            state.bottomBannerState = .authenticate
        }

        // user authenticates, consent was not given
        mockChargeItemListDomainService.authenticateForReturnValue = Just(.success).eraseToAnyPublisher()
        mockChargeItemListDomainService.fetchRemoteChargeItemsAndSaveForReturnValue = Just(.consentNotGranted)
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
        await store.receive(.response(.fetchChargeItemsRemote(.consentNotGranted))) { state in
            state.grantConsentState = .notGranted
            state.destination = .alert(ChargeItemListDomain.AlertStates.grantConsentRequest)
        }

        // user grants consent, ok
        mockChargeItemListDomainService.grantChargeItemsConsentForReturnValue = Just(.success).eraseToAnyPublisher()
        let twoChargeItems: [ErxSparseChargeItem] = [
            ErxSparseChargeItem(
                identifier: UUID().uuidString,
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "2022-05-01T11:13:00+00:00"
            ),
            ErxSparseChargeItem(
                identifier: UUID().uuidString,
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "2021-06-01T07:13:00+05:00"
            ),
        ]

        let twoChargeItemsGroups = twoChargeItems.asChargeItemGroups()
        mockChargeItemListDomainService
            .fetchChargeItemsAssumingConsentGrantedForReturnValue = Just(.success(twoChargeItems))
            .eraseToAnyPublisher()
        await store.send(.destination(.presented(.alert(.grantConsent)))) { state in
            state.destination = nil
        }
        await testScheduler.run()
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await store.receive(.response(.grantConsent(.success))) { state in
            state.grantConsentState = .granted
        }
        await store.receive(.response(.fetchChargeItemsRemote(.success(twoChargeItems)))) { state in
            state.chargeItemGroups = twoChargeItemsGroups
        }
    }

    func testFetchChargeItems_userDeniesGrantConsentRequest() async {
        let store = testStore(for: .init(profileId: testProfileId))

        mockChargeItemListDomainService.fetchLocalChargeItemsForReturnValue = Just(.success([])).eraseToAnyPublisher()
        // Try to fetch the ChargeItems, but no consent was given
        mockChargeItemListDomainService.fetchRemoteChargeItemsAndSaveForReturnValue = Just(.consentNotGranted)
            .eraseToAnyPublisher()
        await store.send(.fetchChargeItems)
        await testScheduler.run()
        await store.receive(.response(.fetchChargeItemsLocal(.success([]))))
        await store.receive(.response(.fetchChargeItemsRemote(.consentNotGranted))) { state in
            state.authenticationState = .authenticated
            state.grantConsentState = .notGranted
            state.destination = .alert(ChargeItemListDomain.AlertStates.grantConsentRequest)
        }

        // Deny to grant the consent
        await store.send(.destination(.presented(.alert(.grantConsentDeny)))) { state in
            state.grantConsentState = .userDeniedGrant
            state.bottomBannerState = .grantConsent
            state.destination = nil
        }

        // Give permission through the bottom banner, but an unexpected error occurs
        let error = ChargeItemListDomainServiceGrantResult.Error.unexpected
        mockChargeItemListDomainService.grantChargeItemsConsentForReturnValue = Just(.error(error))
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
            state.authenticationState = .notAuthenticated
            state.bottomBannerState = .authenticate
            state.destination = .alert(ChargeItemListDomain.AlertStates.grantConsentErrorFor(error: error))
        }

        // Retry to give permission through the alert, receive the unexpected error again
        await store.send(.destination(.presented(.alert(.grantConsentErrorRetry)))) { state in
            state.destination = nil
        }
        await testScheduler.run()
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await store.receive(.response(.grantConsent(.error(.unexpected)))) { state in
            state.grantConsentState = .error
            state.destination = .alert(ChargeItemListDomain.AlertStates.grantConsentErrorFor(error: error))
        }

        // Discard the alert
        await store.send(.destination(.presented(.alert(.grantConsentErrorOkay)))) { state in
            state.destination = nil
            state.bottomBannerState = .grantConsent
        }
    }

    func testGrantConsent_conflictConsentAlreadyGranted() async {
        // given
        let store = testStore(
            for: .init(
                profileId: testProfileId,
                authenticationState: .authenticated,
                grantConsentState: .unknown,
                bottomBannerState: .grantConsent
            )
        )

        mockChargeItemListDomainService.grantChargeItemsConsentForReturnValue = Just(.conflict).eraseToAnyPublisher()

        // when user initiates the grant process
        await store.send(.grantConsentBottomBannerButtonTapped) { state in
            state.bottomBannerState = nil
        }

        // then
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await testScheduler.run()
        await store.receive(.response(.grantConsent(.conflict))) { state in
            state.grantConsentState = .granted
            state.destination = .toast(ChargeItemListDomain.ToastStates.conflictToast)
        }
    }

    func testGrantConsent_requestTimeout() async {
        // given
        let store = testStore(
            for: .init(
                profileId: testProfileId,
                authenticationState: .authenticated,
                grantConsentState: .unknown,
                bottomBannerState: .grantConsent
            )
        )

        let httpClientError = HTTPClientError.httpError(.init(URLError.Code(rawValue: 408)))
        let consentServiceError = ChargeItemConsentService.Error
            .erxRepository(.remote(.fhirClient(.http(.init(httpClientError: httpClientError, operationOutcome: nil)))))
        mockChargeItemListDomainService
            .grantChargeItemsConsentForReturnValue =
            Just(.error(.chargeItemConsentService(consentServiceError))).eraseToAnyPublisher()

        // when user initiates the grant process
        await store.send(.grantConsentBottomBannerButtonTapped) { state in
            state.bottomBannerState = nil
        }

        // then
        await store.receive(.grantConsent) { state in
            state.grantConsentState = .loading
        }
        await testScheduler.run()
        await store.receive(.response(.grantConsent(.error(.chargeItemConsentService(consentServiceError))))) { state in
            state.grantConsentState = .error
            state.destination = .alert(consentServiceError.alertState!.chargeItemListDomainErpAlertState)
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
            state.destination = .alert(ChargeItemListDomain.AlertStates.revokeConsentRequest)
        }

        // user confirms
        mockChargeItemListDomainService.revokeChargeItemsConsentForReturnValue = Just(.success(.success))
            .eraseToAnyPublisher()
        await store.send(.destination(.presented(.alert(.revokeConsent)))) { state in
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
