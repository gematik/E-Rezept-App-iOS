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

import BundleKit
import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import XCTest

// FHIR KBV tests for all types of medications in Version 1.1.0
final class FHIRMedication_v1_1_0_Tests: XCTestCase {
    func testParsingMedication_PZN() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_PZN.json")

        expect(medication.profileType) == .pzn
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.dose) == "N1"
        expect(medication.medicationText) == "GONAL-f 150 I.E./0,25ml Injektionslösung"
        expect(medication.pzn) == "16332684"
        expect(medication.dosageForm) == "PEN"
        expect(medication.amountRatio(for: .v1_1_0)) == ErxTask.Ratio(
            numerator: ErxTask.Quantity(value: "4", unit: "St"),
            denominator: ErxTask.Quantity(value: "1")
        )
    }

    func testParsingMedication_FreeText() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_FreeText.json")

        expect(medication.profileType) == .freeText
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beTrue())
        expect(medication.medicationText) == "Metformin 850mg Tabletten N3"
        expect(medication.dosageForm) == "Tabletten"
        expect(medication.lot).to(beNil())
        expect(medication.expiresOn).to(beNil())
    }

    func testParsingMedication_Ingredient() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Ingredient.json")

        expect(medication.profileType) == .ingredient
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.dose) == "N2"
        expect(medication.dosageForm) == "Tabletten"
        expect(medication.amountRatio(for: .v1_1_0)) == ErxTask.Ratio(
            numerator: ErxTask.Quantity(value: "100", unit: "Stück"),
            denominator: ErxTask.Quantity(value: "1")
        )
        expect(medication.lot).to(beNil())
        expect(medication.expiresOn).to(beNil())
        expect(medication.erxTaskIngredients.count) == 2
        expect(medication.erxTaskIngredients[0]) == ErxTask.Medication.Ingredient(
            text: "Gabapentin",
            number: "22308",
            form: nil,
            strength: ErxTask.Ratio(
                numerator: ErxTask.Quantity(value: "300", unit: "mg"),
                denominator: ErxTask.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxTask.Medication.Ingredient(
            text: "Gabapentin2",
            number: nil,
            form: nil,
            strength: ErxTask.Ratio(
                numerator: ErxTask.Quantity(value: "300", unit: "mg"),
                denominator: ErxTask.Quantity(value: "1")
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
        expect(medication.amountRatio(for: .v1_1_0)) == ErxTask.Ratio(
            numerator: ErxTask.Quantity(value: "200", unit: "g"),
            denominator: ErxTask.Quantity(value: "1")
        )
        expect(medication.dosageForm) == "Creme"
        expect(medication.dose).to(beNil())
        expect(medication.expiresOn).to(beNil())
        expect(medication.lot).to(beNil())
        expect(medication.erxTaskIngredients.count) == 3
        expect(medication.erxTaskIngredients[0]) == ErxTask.Medication.Ingredient(
            text: "Erythromycin",
            number: nil,
            form: nil,
            strength: ErxTask.Ratio(
                numerator: ErxTask.Quantity(value: "2.5", unit: "%"),
                denominator: ErxTask.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxTask.Medication.Ingredient(
            text: "Oleum Rosae",
            number: nil,
            form: nil,
            strength: ErxTask.Ratio(
                numerator: ErxTask.Quantity(value: "2", unit: "%"),
                denominator: ErxTask.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[2]) == ErxTask.Medication.Ingredient(
            text: "Ungt. Emulsificans aquos.",
            number: nil,
            form: "Salbe",
            strength: nil,
            strengthFreeText: "Ad 200 g"
        )
    }

    private func decode(
        resource file: String,
        from bundle: String = "FHIR_KBV_v1_1_0.bundle"
    ) throws -> ModelsR4.Medication {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle)
            .decode(ModelsR4.Medication.self, from: file)
    }
}
