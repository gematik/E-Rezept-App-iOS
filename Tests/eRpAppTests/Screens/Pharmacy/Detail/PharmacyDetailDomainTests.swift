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

import Combine
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import Nimble
import Pharmacy
import XCTest

class PharmacyDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockUserSession: MockUserSession!
    var mockPharmacyRepository: MockPharmacyRepository!

    typealias TestStore = ComposableArchitecture.TestStore<
        PharmacyDetailDomain.State,
        PharmacyDetailDomain.State,
        PharmacyDetailDomain.Action,
        PharmacyDetailDomain.Action,
        PharmacyDetailDomain.Environment
    >

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockPharmacyRepository = MockPharmacyRepository()
    }

    func testStore(for state: PharmacyDetailDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: PharmacyDetailDomain.reducer,
            environment: PharmacyDetailDomain.Environment(
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                userSession: mockUserSession,
                signatureProvider: MockSecureEnclaveSignatureProvider(),
                accessibilityAnnouncementReceiver: { _ in },
                userSessionProvider: MockUserSessionProvider(),
                pharmacyRepository: mockPharmacyRepository
            )
        )
    }

    func testToggleingFavoriteState_Success() {
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
        ))

        mockPharmacyRepository.savePublisher = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        sut.send(.toggleIsFavorite)
        sut.receive(.toggleIsFavoriteReceived(.success(expectedResult))) {
            $0.pharmacyViewModel = expectedResult
        }

        sut.send(.toggleIsFavorite)
        sut.receive(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA))) {
            $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
        }
    }

    func testToggleingFavoriteState_Failure() {
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
        ))

        let expectedError = PharmacyRepositoryError.local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))
        mockPharmacyRepository
            .savePublisher = Fail(error: PharmacyRepositoryError
                .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))).eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        sut.send(.toggleIsFavorite)
        sut.receive(.toggleIsFavoriteReceived(.failure(expectedError))) {
            $0.route = .alert(.init(for: expectedError))
        }
    }
}
