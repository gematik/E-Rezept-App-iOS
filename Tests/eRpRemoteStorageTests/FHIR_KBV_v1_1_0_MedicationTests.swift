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

import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import XCTest

// FHIR KBV tests for all types of medications in Version 1.1.0
final class FHIR_KBV_v1_1_0_MedicationTests: XCTestCase {
    func testParsingMedication_PZN() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_PZN.json")

        expect(medication.profileType) == .pzn
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N1"
        expect(medication.medicationText) == "GONAL-f 150 I.E./0,25ml Injektionslösung"
        expect(medication.pzn) == "16332684"
        expect(medication.dosageForm) == "PEN"
        expect(medication.erxTaskBatch) == .init(lotNumber: "1234567890abcde", expiresOn: "2020-02-03T00:00:00+00:00")
        expect(medication.amountRatio(for: .v1_1_0)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "4", unit: "St"),
            denominator: ErxMedication.Quantity(value: "1")
        )
    }

    func testParsingMedication_FreeText() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_FreeText.json")

        expect(medication.profileType) == .freeText
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beTrue())
        expect(medication.medicationText) == "Metformin 850mg Tabletten N3"
        expect(medication.dosageForm) == "Tabletten"
        expect(medication.erxTaskBatch) == .init(lotNumber: "1234567890abcde")
    }

    func testParsingMedication_Ingredient() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Ingredient.json")

        expect(medication.profileType) == .ingredient
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N2"
        expect(medication.dosageForm) == "Tabletten"
        expect(medication.amountRatio(for: .v1_1_0)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "100", unit: "Stück"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 2
        expect(medication.erxTaskIngredients[0]) == ErxMedication.Ingredient(
            text: "Gabapentin",
            number: "22308",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "300", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxMedication.Ingredient(
            text: "Gabapentin2",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "300", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
    }

    func testParsingMedication_Compounding() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Compounding.json")

        expect(medication.profileType) == .compounding
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.compoundingInstruction) == "Schwieriger Herstellungsprozess"
        expect(medication.medicationText) == "Viskose Aluminiumchlorid-Hexahydrat-Lösung 20 % (NRF 11.132.)"
        expect(medication.packaging) == "Deo-Roller"
        expect(medication.amountRatio(for: .v1_1_0)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "200", unit: "g"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medication.dosageForm) == "Creme"
        expect(medication.normSizeCode).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 3
        expect(medication.erxTaskIngredients[0]) == ErxMedication.Ingredient(
            text: "Erythromycin",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "2.5", unit: "%"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxMedication.Ingredient(
            text: "Oleum Rosae",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "2", unit: "%"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[2]) == ErxMedication.Ingredient(
            text: "Ungt. Emulsificans aquos.",
            number: nil,
            form: "Salbe",
            strength: nil,
            strengthFreeText: "Ad 200 g"
        )
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .kbv_v1_1_0
    ) throws -> ModelsR4.Medication {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Medication.self, from: data)
    }
}
