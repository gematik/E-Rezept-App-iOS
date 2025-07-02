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

import Foundation

/// This structure represents a medication derived from the profile `GEM_ERP_PR_Medication`
///  which by itself is derived from `EPA_MEDICATION` https://simplifier.net/epa-medication/epamedication
/// For information on medication and it's profiles go to:
/// https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.4.3/files/2550130
public struct ErxEpaMedication: Hashable, Codable, Sendable {
    public init(
        epaMedicationType: EpaMedicationType? = nil,
        drugCategory: EpaMedicationDrugCategory? = nil,
        code: EpaMedicationCodeCodableConcept? = nil,
        status: EpaMedicationStatus? = nil,
        isVaccine: Bool? = nil,
        amount: EpaMedicationRatio? = nil,
        form: EpaMedicationFormCodableConcept? = nil,
        normSizeCode: String? = nil,
        batch: EpaMedicationBatch? = nil,
        packaging: String? = nil,
        manufacturingInstructions: String? = nil,
        ingredients: [EpaMedicationIngredient] = []
    ) {
        self.epaMedicationType = epaMedicationType
        self.drugCategory = drugCategory
        self.code = code
        self.status = status
        self.amount = amount
        self.form = form
        self.normSizeCode = normSizeCode
        self.batch = batch
        self.isVaccine = isVaccine
        self.packaging = packaging
        self.manufacturingInstructions = manufacturingInstructions
        self.ingredients = ingredients
    }

    /// Category of the drug
    public let drugCategory: EpaMedicationDrugCategory?
    /// EPAMedicationType of the medication
    /// Note: Nil represents one of the former Freitext-, PZN- or  Wirkstoff-Medications types
    public let epaMedicationType: EpaMedicationType?
    /// Coded form of the medication (may contain `medicationText` and IDs like pzn)
    public let code: EpaMedicationCodeCodableConcept?
    /// A code to indicate if the medication is in active use.
    public let status: EpaMedicationStatus?
    /// Specific amount of the drug in the packaged product.
    public let amount: EpaMedicationRatio?
    /// Describes the form of the item. E.g.: Powder, tablets, capsule.
    public let form: EpaMedicationFormCodableConcept?
    /// Describes the therapeutic size for the package (e.g. N1)  /  a.k.a. "Normgroesse"
    public let normSizeCode: String?
    /// True if marked as vaccine, false if not
    public let isVaccine: Bool?
    /// Informations about the packaging (only for .`compounding` profile types)
    public let packaging: String?
    /// Instructions from the manufacturing company  (only for compounding profile types)
    public let manufacturingInstructions: String?
    /// Details about packaged medications (only available with medication dispense)
    public let batch: EpaMedicationBatch?
    /// Ingredients of the medication
    public let ingredients: [EpaMedicationIngredient]

    /// Shortcut for a name of the medication
    /// Note: This checks for the `code.text` field first.
    /// If unavailable, it will return a first found `displayName` in the `code.codings` array
    public var name: String? {
        code?.text ?? code?.codings.first {
            $0.display != nil
        }?.display
    }

    /// Number of the medication ( only for `.pzn` profile types)
    public var pzn: String? {
        code?.codings.first {
            $0.system == .pzn
        }?.code
    }
}
