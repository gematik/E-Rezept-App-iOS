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

/// FHIR KBV tests for medication in Version 1.4.1
final class FHIR_KBV_v1_4_1_MedicationTests: XCTestCase {
    func testParsingMedication_PZN() throws {
        let outerBundle = try decodeBundle(resource: "Task_and_KBV_Bundle.json")
        let medication = try extractMedication(from: outerBundle)
        let expectedIngredient = ErxMedication.Ingredient(
            text: "Efeublätter, TE mit Ethanol/Ethanol-Wasser",
            number: "11704",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "7", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1", unit: "ml")
            ),
            strengthFreeText: nil
        )

        expect(medication.profileType) == .pzn
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine).to(beFalse())
        expect(medication.normSizeCode) == "N1"
        expect(medication.medicationText) == "Prospan® Hustensaft 100ml N1"
        expect(medication.pzn) == "08585997"
        expect(medication.dosageForm) == "FLE"
        expect(medication.amountRatio(for: .v1_4_1)).to(beNil())
        expect(medication.erxTaskBatch).to(beNil())
        expect(medication.erxTaskIngredients.count) == 1
        expect(medication.erxTaskIngredients[0]).to(nodiff(expectedIngredient))
    }

    func testParsingMedicationDispenseDigaSimpleParseable() throws {
        let digaExpectations: [String] = [
            "MedicationDispense-Example-MedicationDispense-DiGA-DeepLink--17744591.json",
            "MedicationDispense-Example-MedicationDispense-DiGA-Name-And-PZN--25779254.json",
            "MedicationDispense-Example-MedicationDispense-DiGA-NoRedeemCode--34934986.json",
        ]

        for file in digaExpectations {
            expect(try self.decodeMedicationDispense(resource: file))
                .toNot(throwError(), description: "Decoding MedicationDispense should not throw for file: \(file)")
        }
    }

    func testParsingMedicationDispenseExamples() throws {
        let expectations: [String: String?] = [
            "MedicationDispense-Example-MedicationDispense--25037822.json": nil,
            "MedicationDispense-Example-MedicationDispense-2--41084157.json": nil,
            "MedicationDispense-Example-MedicationDispense-Dosage-comb-dayofweek--43875021.json": "montags 1-0-1-0, freitags 1-0-1-0 Stück",
            "MedicationDispense-Example-MedicationDispense-Dosage-comb-interval--63081244.json":
                "alle 2 Tage: 08:00 Uhr — je 1 Stück; 18:00 Uhr — je 2 Stück",
            "MedicationDispense-Example-MedicationDispense-Dosage-interval--40749199.json": "alle 8 Tage: je 1 Stück",
            "MedicationDispense-Example-MedicationDispense-Dosage-tageszeit--14626574.json": "1-0-2-0 Stück",
            "MedicationDispense-Example-MedicationDispense-Dosage-uhrzeit--60453091.json": "täglich: 08:00 Uhr — je 1 Stück",
            "MedicationDispense-Example-MedicationDispense-Dosage-weekday--44117540.json":
                "dienstags — je 2 Stück, donnerstags — je 2 Stück",
            "MedicationDispense-Example-MedicationDispense-Kombipackung--16665627.json": nil,
            "MedicationDispense-Example-MedicationDispense-Rezeptur--27556864.json": nil,
            "MedicationDispense-Example-MedicationDispense-Without-Medication--4742722.json": nil,
        ]

        for (file, expectedDosage) in expectations {
            let medicationDispense = try decodeMedicationDispense(resource: file)
            expect(medicationDispense.medicationReference)
                .toNot(beNil(), description: "Medication reference should not be nil for file: \(file)")
            let dispense = try parseMedicationDispense(from: medicationDispense)
            let actualDosage = dispense.dosageInstruction
            if let expectedDosage {
                expect(actualDosage).to(equal(expectedDosage))
            } else {
                expect(actualDosage).to(beNil())
            }
        }
    }

    private enum TestError: Error {
        case missingKbvBundle
        case missingMedication
    }

    private func decodeBundle(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_6_1_with_kbv_v1_4_1
    ) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }

    private func extractMedication(from outerBundle: ModelsR4.Bundle) throws -> ModelsR4.Medication {
        guard let kbvBundle = outerBundle.entry?.compactMap({
            $0.resource?.get(if: ModelsR4.Bundle.self)
        }).first else {
            throw TestError.missingKbvBundle
        }
        guard let medication = kbvBundle.medication else {
            throw TestError.missingMedication
        }
        return medication
    }

    private func decodeMedicationDispense(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_6_1_with_kbv_v1_4_1
    ) throws -> ModelsR4.MedicationDispense {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.MedicationDispense.self, from: data)
    }

    private func parseMedicationDispense(from medicationDispense: ModelsR4
        .MedicationDispense) throws -> ErxMedicationDispense {
        let bundle = ModelsR4.Bundle(
            entry: [BundleEntry(resource: .medicationDispense(medicationDispense))],
            type: FHIRPrimitive<BundleType>(.searchset)
        )
        return try bundle.parse(medicationDispense)
    }
}
