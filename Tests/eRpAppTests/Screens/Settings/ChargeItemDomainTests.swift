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
final class ChargeItemDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<ChargeItemDomain>

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockChargeItemListDomainService: MockChargeItemListDomainService!
    var mockUserSession: MockUserSession!
    var mockUserSessionProvider: MockUserSessionProvider!
    var isDismissInvoked: LockIsolated<Bool>!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockChargeItemListDomainService = MockChargeItemListDomainService()
        mockUserSession = MockUserSession()
        mockUserSessionProvider = MockUserSessionProvider()
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        isDismissInvoked = LockIsolated(false)
    }

    private func testStore(for state: ChargeItemDomain.State) -> TestStore {
        TestStore(initialState: state) {
            ChargeItemDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSessionProvider = mockUserSessionProvider
            dependencies.chargeItemsDomainService = mockChargeItemListDomainService
            dependencies.dismiss = DismissEffect { self.isDismissInvoked.setValue(true) }
        }
    }

    let testProfileId = UUID()

    func testDeleteChargeItem_showsAlert() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))
        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteConfirm)
        }
    }

    func testDeleteConfirmAlertNotAuthenticated_showsAuthenticateAlert() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))
        mockChargeItemListDomainService.deleteChargeItemForReturnValue = Just(.notAuthenticated).eraseToAnyPublisher()
        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteConfirm)
        }
        await store.send(.destination(.presented(.alert(.deleteConfirm)))) {
            $0.destination = nil
        }
        await testScheduler.run()
        await store.receive(.response(.deleteChargeItem(.notAuthenticated))) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteNotAuthenticated)
        }
    }

    func testDeleteConfirmAlert_withSucces() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))
        mockChargeItemListDomainService.deleteChargeItemForReturnValue = Just(.success).eraseToAnyPublisher()
        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteConfirm)
        }
        await store.send(.destination(.presented(.alert(.deleteConfirm)))) {
            $0.destination = nil
        }
        await testScheduler.run()
        await store.receive(.response(.deleteChargeItem(.success))) {
            $0.authenticationState = .authenticated
        }
        expect(self.isDismissInvoked.value) == true
    }

    func testDeleteConfirmAlertWithError_showsErrorAlert() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))
        let error = ChargeItemDomainServiceDeleteResult.Error.unexpected
        mockChargeItemListDomainService.deleteChargeItemForReturnValue = Just(.error(error)).eraseToAnyPublisher()
        await store.send(.response(.deleteChargeItem(.notAuthenticated))) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteNotAuthenticated)
        }
        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteConfirm)
        }
        await store.send(.destination(.presented(.alert(.deleteConfirm)))) {
            $0.destination = nil
        }
        await testScheduler.run()
        await store.receive(.response(.deleteChargeItem(.error(error)))) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteErrorFor(error: error))
        }
    }

    func testDeleteAuthenticateConnect_showsCardWall() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))

        await store.send(.response(.deleteChargeItem(.notAuthenticated))) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteNotAuthenticated)
        }
        await store.send(.destination(.presented(.alert(.deleteAuthenticateConnect))))
    }

    func testAlertAuthenticateRetry_authenticatesWithSuccess() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            chargeItem: ErxChargeItem.Fixtures.chargeItem
        ))
        mockChargeItemListDomainService.authenticateForReturnValue = Just(.success)
            .eraseToAnyPublisher()

        let error = ChargeItemDomainServiceDeleteResult.Error.unexpected
        await store.send(.response(.deleteChargeItem(.error(error)))) {
            $0.destination = .alert(ChargeItemDomain.AlertStates.deleteErrorFor(error: error))
        }
        await store.send(.destination(.presented(.alert(.authenticateRetry)))) {
            $0.destination = nil
        }
        await testScheduler.run()
        await store.receive(.authenticate) {
            $0.authenticationState = .loading
        }
        await store.receive(.response(.authenticate(.success))) {
            $0.authenticationState = .authenticated
        }
    }
}
