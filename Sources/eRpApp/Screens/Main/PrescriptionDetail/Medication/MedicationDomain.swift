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
import Dependencies
import eRpKit
import SwiftUI

@Reducer
struct MedicationDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail_medication_ingredients
        case ingredient(IngredientDomain)
    }

    @ObservableState
    struct State: Equatable {
        let medication: ErxMedication?
        let dispenseState: DispenseState?
        @Presents var destination: Destination.State?

        init(subscribed: ErxMedication) {
            medication = subscribed
            dispenseState = nil
        }

        init(dispensed: ErxMedicationDispense, dateFormatter: UIDateFormatter) {
            medication = dispensed.medication
            dispenseState = .init(
                lotNumber: medication?.batch?.lotNumber,
                expiresOn: dateFormatter.date(medication?.batch?.expiresOn),
                dosageInstruction: dispensed.dosageInstruction,
                whenHandedOver: dateFormatter.date(dispensed.whenHandedOver),
                quantity: dispensed.quantity,
                noteText: dispensed.noteText
            )
        }

        struct DispenseState: Equatable {
            let lotNumber: String?
            let expiresOn: String?
            let dosageInstruction: String?
            let whenHandedOver: String?
            let quantity: ErxMedication.Quantity?
            let noteText: String?
        }
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case showIngredient(ErxMedication.Ingredient)
        case resetNavigation
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .showIngredient(ingredient):
                let ingredientState = IngredientDomain.State(
                    text: ingredient.text,
                    strength: ingredient.strengthDescription,
                    form: ingredient.localizedForm,
                    number: ingredient.number
                )
                state.destination = .ingredient(ingredientState)
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ErxMedication {
    var localizedDosageForm: String? {
        guard let dosageFormKey = dosageForm,
              let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[dosageFormKey.lowercased()] else {
            return dosageForm
        }
        return NSLocalizedString(localizedStringKey, bundle: .module, comment: "")
    }
}

extension ErxMedication.Ingredient {
    var localizedForm: String? {
        guard let dosageFormKey = form,
              let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[dosageFormKey.lowercased()] else {
            return form
        }
        return NSLocalizedString(localizedStringKey, bundle: .module, comment: "")
    }

    var strengthDescription: String? {
        strength != nil ? strength?.description : strengthFreeText
    }
}

extension MedicationDomain {
    enum Dummies {
        static let state: MedicationDomain.State = .init(subscribed: ErxTask.Demo.medication1)
    }
}
