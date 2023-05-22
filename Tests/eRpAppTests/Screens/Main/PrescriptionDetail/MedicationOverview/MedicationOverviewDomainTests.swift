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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class MedicationOverviewDomainTests: XCTestCase {
    let stateWithIngredientMedication = MedicationOverviewDomain.State(
        subscribed: ErxTask.Fixtures.ingredientMedication,
        dispensed: ErxTask.Fixtures.medicationDispenses
    )

    typealias TestStore = ComposableArchitecture.TestStore<
        MedicationOverviewDomain.State,
        MedicationOverviewDomain.Action,
        MedicationOverviewDomain.State,
        MedicationOverviewDomain.Action,
        Void
    >

    func testStore(_ state: MedicationOverviewDomain.State? = nil) -> TestStore {
        TestStore(
            initialState: state ?? stateWithIngredientMedication,
            reducer: MedicationOverviewDomain()
        )
    }

    func testShowSubscribedMedication() {
        let expectedMedication = MedicationDomain.State(subscribed: stateWithIngredientMedication.subscribed)
        let sut = testStore()

        sut.send(.showSubscribedMedication) {
            $0.destination = .medication(expectedMedication)
        }
    }

    func testShowDispensedMedication() {
        let selectedDispense = stateWithIngredientMedication.dispensed.first!
        let expectedState = MedicationDomain.State(
            dispensed: selectedDispense,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore()

        sut.send(.showDispensedMedication(selectedDispense)) {
            $0.destination = .medication(expectedState)
        }
    }
}
