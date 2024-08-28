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
import ComposableCoreLocation
@testable import eRpFeatures
import eRpKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacyPrescriptionSelectionDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockUserSession: MockUserSession!

    typealias TestStore = TestStoreOf<PharmacyPrescriptionSelectionDomain>
    var store: TestStore!

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
    }

    func testStore(for state: PharmacyPrescriptionSelectionDomain.State) -> TestStore {
        TestStore(initialState: state) {
            PharmacyPrescriptionSelectionDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
        }
    }

    func testDidSelection() async {
        let prescription1 = Prescription.Dummies.prescriptionReady
        let prescription2 = Prescription.Dummies.prescriptionMVO

        let sut = testStore(for: PharmacyPrescriptionSelectionDomain
            .State(
                prescriptions: Shared([prescription1, prescription2]),
                selectedPrescriptions: Shared([])
            ))

        await sut.send(.didSelect(prescription1.identifier)) { sut in
            sut.selectedPrescriptionsCopy = Set([prescription1])
        }

        await sut.send(.didSelect(prescription1.identifier)) { sut in
            sut.selectedPrescriptionsCopy = Set<Prescription>()
        }
    }
}
