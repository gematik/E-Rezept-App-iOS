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

import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import TestUtils
import XCTest

/// FHIR KBV tests for all types of medications in Version 1.3.2
final class FHIR_KBV_v1_3_2_MedicationTests: XCTestCase {
    func testParsingMedication_PZN() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_PZN.json")

        expect(medication.profileType) == .pzn
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N3"
        expect(medication.medicationText) == "Venlafaxin - 1 A Pharma® 75mg 100 Tabl. N3"
        expect(medication.pzn) == "05392039"
        expect(medication.dosageForm) == "TAB"
        expect(medication.erxTaskBatch).to(beNil())
    }

    func testParsingMedication_FreeText() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_FreeText.json")

        expect(medication.profileType) == .freeText
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.medicationText) == "Metformin 850mg Tabletten N3"
    }

    func testParsingMedication_Ingredient() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Ingredient.json")
        let expected = ErxMedication.Ingredient(
            text: "Somatropin",
            number: "22339",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "12", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1", unit: "Stück")
            ),
            strengthFreeText: nil
        )

        expect(medication.profileType) == .ingredient
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N1"
        expect(medication.dosageForm) == "Tabletten"
        expect(medication.amountRatio(for: .v1_3_2)).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 1
        expect(medication.erxTaskIngredients[0]).to(nodiff(expected))
    }

    func testParsingMedication_Compounding() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Compounding.json")

        expect(medication.profileType) == .compounding
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.amountRatio(for: .v1_3_2)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "500", unit: "ml"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medication.dosageForm) == "Infusionslösung"
        expect(medication.normSizeCode).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 2
        expect(medication.erxTaskIngredients[0]) == ErxMedication.Ingredient(
            text: "Etoposid",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "180", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxMedication.Ingredient(
            text: "NaCl 0,9 %",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "500", unit: "ml"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .kbv_v1_3_2
    ) throws -> ModelsR4.Medication {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Medication.self, from: data)
    }
}
