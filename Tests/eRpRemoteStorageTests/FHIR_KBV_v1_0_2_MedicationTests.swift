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

// FHIR KBV tests for all types of medications in Version 1.0.2
final class FHIR_KBV_v1_0_2_MedicationTests: XCTestCase {
    func testParsingMedication_PZN() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_PZN.json")

        expect(medication.profileType) == .pzn
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N1"
        expect(medication.medicationText) == "Ich bin in Einlösung"
        expect(medication.pzn) == "00427833"
        expect(medication.dosageForm) == "IHP"
        expect(medication.amountRatio(for: .v1_0_2)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "1", unit: "Diskus"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medication.erxTaskBatch) == .init(lotNumber: "1234567890abcde", expiresOn: "2020-02-03T00:00:00+00:00")
    }

    func testParsingMedication_FreeText() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_FreeText.json")

        expect(medication.profileType) == .freeText
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beTrue())
        expect(medication.medicationText) == "Freitext med. Name"
        expect(medication.dosageForm) == "Darreichungsform als Freitext"
        expect(medication.erxTaskBatch) == .init(expiresOn: "2020-02-03T00:00:00+00:00")
    }

    func testParsingMedication_Ingredient() throws {
        let medication = try decode(resource: "KBV_PR_ERP_Medication_Ingredient.json")

        expect(medication.profileType) == .ingredient
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N1"
        expect(medication.dosageForm) == "Flüssigkeiten"
        expect(medication.amountRatio(for: .v1_0_2)).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 1
        expect(medication.erxTaskIngredients.first) == ErxMedication.Ingredient(
            text: "Wirkstoff Paulaner Weissbier",
            number: "37197",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "1", unit: "Maß"),
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
        expect(medication.compoundingInstruction) == "Anweisungen bzgl. der Herstellung der Rezeptur"
        expect(medication.packaging) ==
            "Angabe zur Transportbehältnisse, Verpackungen bzw. Applikationshilfen für eine Rezeptur"
        expect(medication.amountRatio(for: .v1_0_2)) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "100", unit: "ml"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medication.dosageForm) == "Lösung"
        expect(medication.normSizeCode).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 2
        expect(medication.erxTaskIngredients[0]) == ErxMedication.Ingredient(
            text: "1_3 Graf 02.08.2022",
            number: "10206346",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "5", unit: "g"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medication.erxTaskIngredients[1]) == ErxMedication.Ingredient(
            text: "2-propanol 70 %",
            number: nil,
            form: "Pulver",
            strength: nil,
            strengthFreeText: "Ad 100 g"
        )
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .kbv_v1_0_2
    ) throws -> ModelsR4.Medication {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle.rawValue)
            .decode(ModelsR4.Medication.self, from: file)
    }
}
