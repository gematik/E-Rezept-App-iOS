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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

@MainActor
final class MedicationDomainTests: XCTestCase {
    let stateWithIngredientMedication = MedicationDomain.State(subscribed: ErxTask.Fixtures.ingredientMedication)

    typealias TestStore = TestStoreOf<MedicationDomain>

    func testStore(_ state: MedicationDomain.State? = nil) -> TestStore {
        TestStore(initialState: state ?? stateWithIngredientMedication) {
            MedicationDomain()
        }
    }

    func testShowIngredient() async {
        let expectedIngredient = stateWithIngredientMedication.medication!.ingredients.first!
        let sut = testStore()

        await sut.send(.showIngredient(expectedIngredient)) {
            $0.destination = .ingredient(
                .init(
                    text: expectedIngredient.text,
                    strength: expectedIngredient.strengthFreeText,
                    form: expectedIngredient.localizedForm,
                    number: expectedIngredient.number
                )
            )
        }
    }
}
