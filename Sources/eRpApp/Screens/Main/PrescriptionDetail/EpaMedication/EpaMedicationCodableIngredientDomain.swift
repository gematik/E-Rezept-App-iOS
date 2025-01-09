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

import ComposableArchitecture
import eRpKit

@Reducer
struct EpaMedicationCodableIngredientDomain {
    @ObservableState
    struct State: Equatable {
        let item: EpaMedicationCodeCodableConcept
        let isActive: Bool?
        let strength: EpaMedicationIngredient.Strength?
        let darreichungsForm: String?

        var displayName: String {
            item.text ?? item.displayName ?? L10n.prscFdTxtNa.text
        }

        var strengthText: String { strength?.strengthDescription ?? L10n.prscFdTxtNa.text }

        var form: String { darreichungsForm ?? L10n.prscFdTxtNa.text }

        var number: String { item.idCode ?? L10n.prscFdTxtNa.text }
    }

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

extension EpaMedicationCodeCodableConcept {
    var displayName: String? {
        codings.first {
            $0.display != nil
        }?.display
    }

    var idCode: String? {
        codings.first {
            $0.code != nil
        }?.code
    }
}

extension EpaMedicationIngredient.Strength {
    var strengthDescription: String {
        if let amountText {
            return amountText
        }

        guard let denominator = ratio.denominator, denominator.value != "1"
        else {
            return "\(ratio.numerator.description)"
        }
        return "\(ratio.numerator.description) / \(denominator.description)"
    }
}

extension EpaMedicationCodableIngredientDomain {
    enum Dummies {
        static let state = State(
            item: EpaMedicationCodeCodableConcept.Dummies.natriumcromoglicat,
            isActive: nil,
            strength: .init(
                ratio: .init(
                    numerator: .init(value: "2.8", unit: "mg"),
                    denominator: .init(value: "1", unit: "Sprühstoß")
                ),
                amountText: nil
            ),
            darreichungsForm: nil
        )
    }
}

extension EpaMedicationCodeCodableConcept {
    enum Dummies {
        static let natriumcromoglicat =
            EpaMedicationCodeCodableConcept(
                codings: [
                    EpaMedicationCoding<CodeCodingSystem>(
                        system: .atcDe,
                        code: "R01AC01",
                        display: "Natriumcromoglicat"
                    ),
                ],
                text: nil
            )
    }
}
