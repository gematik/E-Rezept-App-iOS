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
import Dependencies
import eRpKit
import SwiftUI

struct MedicationDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {}

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = prescriptionDetail_medication_ingredients
            case ingredient(IngredientState)
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }

        struct IngredientState: Equatable {
            let text: String?
            let strength: String?
            let form: String?
            let number: String?
        }
    }

    struct State: Equatable {
        let medication: ErxMedication?
        let dispenseState: DispenseState?
        var destination: Destinations.State?

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
        case destination(Destinations.Action)
        case showIngredient(ErxMedication.Ingredient)
        case setNavigation(tag: Destinations.State.Tag?)
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .showIngredient(ingredient):
                let ingredientState = Destinations.IngredientState(
                    text: ingredient.text,
                    strength: ingredient.strengthDescription,
                    form: ingredient.localizedForm,
                    number: ingredient.number
                )
                state.destination = .ingredient(ingredientState)
                return .none
            case .setNavigation(tag: .none):
                state.destination = nil
                return .none
            case .setNavigation,
                 .destination:
                return .none
            }
        }
        .ifLet(\.destination, action: /Action.destination) {
            Destinations()
        }
    }
}

extension ErxMedication {
    var localizedDosageForm: String? {
        guard let dosageFormKey = dosageForm,
              let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[dosageFormKey.lowercased()] else {
            return dosageForm
        }
        return NSLocalizedString(localizedStringKey, comment: "")
    }
}

extension ErxMedication.Ingredient {
    var localizedForm: String? {
        guard let dosageFormKey = form,
              let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[dosageFormKey.lowercased()] else {
            return form
        }
        return NSLocalizedString(localizedStringKey, comment: "")
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
