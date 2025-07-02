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
import SwiftUI
import TestUtils
import XCTest

// FHIRBundle tests with
// - workflow bundle version: 1.4.3
final class FHIR_GEM_Workflow_v1_4_MedicationDispenseTests: XCTestCase {
    func testParseSimpleMedicationDispenseBundle() throws {
        let medicationDispenseBundle = try decode(
            resource: "Bundle-SimpleMedicationDispenseBundle.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Bundle.self
        )

        let medicationDispenses = try medicationDispenseBundle.parseErxMedicationDispenses()

        guard medicationDispenses.count == 1,
              let medicationDispense = medicationDispenses.first else {
            fail("unexpected number of medicationDispenses")
            return
        }

        expect(medicationDispense.identifier) == "160.000.000.000.000.01"
        expect(medicationDispense.medication) == nil

        expect(medicationDispense.epaMedication) != nil
        let epaMedication = medicationDispense.epaMedication!
        let expectedEpaMedication: ErxEpaMedication = .init(
            epaMedicationType: nil,
            drugCategory: nil,
            code: EpaMedicationCodableConcept(
                codings: [
                    EpaMedicationCoding<CodeCodingSystem>(
                        system: .pzn,
                        version: nil,
                        code: "06313728",
                        display: nil,
                        userSelected: nil
                    ),
                ],
                text: nil
            ),
            status: nil,
            isVaccine: nil,
            amount: nil,
            form: nil,
            normSizeCode: nil,
            batch: nil,
            packaging: nil,
            manufacturingInstructions: nil,
            ingredients: []
        )
        expect(epaMedication).to(nodiff(expectedEpaMedication))
        expect(epaMedication.pzn) == "06313728"
        expect(epaMedication.epaMedicationType) == nil
    }

    func testParseKomplexMedicationDispenseBundle() throws {
        let medicationDispenseBundle = try decode(
            resource: "Bundle-KomplexMedicationDispenseBundle.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Bundle.self
        )

        let medicationDispenses = try medicationDispenseBundle.parseErxMedicationDispenses()

        guard medicationDispenses.count == 1,
              let medicationDispense = medicationDispenses.first else {
            fail("unexpected number of medicationDispenses")
            return
        }

        expect(medicationDispense.identifier) == "160.000.000.000.000.03"
        expect(medicationDispense.whenHandedOver) == "2025-09-06"
        expect(medicationDispense.telematikId) == "3-SMC-B-Testkarte-883110000095957"
        expect(medicationDispense.insuranceId) == "X123456789"
        expect(medicationDispense.medication) == nil

        expect(medicationDispense.epaMedication) != nil
        expect(medicationDispense.epaMedication?.epaMedicationType) == .extemporaneousPreparation
        expect(medicationDispense.epaMedication?.ingredients.count) == 2

        let ingredient01 = medicationDispense.epaMedication!.ingredients[0]
        let expectedIngredient01Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .medicinalProductPackage,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .pzn,
                        code: "03424249",
                        display: "Hydrocortison 1% Creme"
                    )],
                    text: "Hydrocortison 1% Creme"
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: nil,
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: []
            )
        )
        expect(ingredient01.item).to(nodiff(expectedIngredient01Item))

        let ingredient02 = medicationDispense.epaMedication!.ingredients[1]
        let expectedIngredient02Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .medicinalProductPackage,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .pzn,
                        code: "16667195",
                        display: "Dexpanthenol 5% Creme"
                    )],
                    text: "Dexpanthenol 5% Creme"
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: nil,
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: []
            )
        )
        expect(ingredient02.item).to(nodiff(expectedIngredient02Item))
    }

    func testParseMultipleMedicationDispenseBundle() throws {
        let medicationDispenseBundle = try decode(
            resource: "Bundle-MultipleMedicationDispenseBundle.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Bundle.self
        )

        let medicationDispenses = try medicationDispenseBundle.parseErxMedicationDispenses()

        guard medicationDispenses.count == 2
        else {
            fail("unexpected number of medicationDispenses")
            return
        }
        let medicationDispense01 = medicationDispenses[0]
        let medicationDispense02 = medicationDispenses[1]

        expect(medicationDispense01.identifier) == "160.000.000.000.000.01"
        expect(medicationDispense01.medication) == nil

        expect(medicationDispense01.epaMedication) != nil
        expect(medicationDispense01.epaMedication?.pzn) == "06313728"
        expect(medicationDispense01.epaMedication?.epaMedicationType) == nil

        expect(medicationDispense02.identifier) == "160.000.000.000.000.02"
        expect(medicationDispense02.medication) == nil

        expect(medicationDispense02.epaMedication) != nil
        expect(medicationDispense02.epaMedication?.pzn) == "06313728"
        expect(medicationDispense02.epaMedication?.epaMedicationType) == nil
    }

    func testParseSearchSetMultipleMedicationDispenseBundle() throws {
        let medicationDispenseBundle = try decode(
            resource: "Bundle-SearchSetMultipleMedicationDispenseBundle.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Bundle.self
        )

        let medicationDispenses = try medicationDispenseBundle.parseErxMedicationDispenses()

        guard medicationDispenses.count == 4
        else {
            fail("unexpected number of medicationDispenses")
            return
        }

        let medicationDispense01 = medicationDispenses[0]
        expect(medicationDispense01.identifier) == "160.000.000.000.000.01"
        expect(medicationDispense01.medication) == nil
        expect(medicationDispense01.epaMedication) != nil
        expect(medicationDispense01.epaMedication?.name) == nil
        expect(medicationDispense01.epaMedication?.pzn) == "06313728"
        expect(medicationDispense01.epaMedication?.epaMedicationType) == nil

        let medicationDispense02 = medicationDispenses[1]
        expect(medicationDispense02.identifier) == "160.000.000.000.000.02"
        expect(medicationDispense02.medication) == nil
        expect(medicationDispense02.epaMedication) != nil
        expect(medicationDispense02.epaMedication?.name) == nil
        expect(medicationDispense02.epaMedication?.pzn) == "06313728"
        expect(medicationDispense02.epaMedication?.epaMedicationType) == nil

        let medicationDispense03 = medicationDispenses[2]
        expect(medicationDispense03.identifier) == "160.000.000.000.000.04"
        expect(medicationDispense03.epaMedication) == nil
        expect(medicationDispense03.medication) != nil
        expect(medicationDispense03.medication?.name) == "Sumatriptan Dura 100mg"
        expect(medicationDispense03.medication?.pzn) == "04866280"
        expect(medicationDispense03.medication?.profile) == .pzn

        let medicationDispense04 = medicationDispenses[3]
        expect(medicationDispense04.identifier) == "160.000.000.000.000.05"
        expect(medicationDispense04.epaMedication) == nil
        expect(medicationDispense04.medication) != nil
        expect(medicationDispense04.medication?.name) == "Sumatriptan Dura 100mg"
        expect(medicationDispense04.medication?.pzn) == "04866280"
        expect(medicationDispense04.medication?.profile) == .pzn
    }

    // MARK: - Medication

    // Sumatripan
    func testParseEpaMedicationSumatripan() throws {
        let modelsR4Medication = try decode(
            resource: "Medication-SumatripanMedication.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Medication.self
        )

        let medication = ErxEpaMedication(medication: modelsR4Medication)

        expect(medication.name) == "Sumatriptan-1a Pharma 100 mg Tabletten"
        expect(medication.pzn) == "06313728"
        expect(medication.isVaccine) == false
        expect(medication.epaMedicationType) == nil
        expect(medication.drugCategory) == .avm
        expect(medication.normSizeCode) == "N1"
        expect(medication.form) == .init(
            codings: [.init(system: .kbvDarreichungsform, code: "TAB", display: nil)],
            text: nil
        )
        expect(medication.status) == nil
        expect(medication.amount) == .init(
            numerator: .init(value: "20", unit: "St"),
            denominator: .init(value: "1")
        )
        expect(medication.batch?.lotNumber) == "1234567890"
    }

    // Rezeptur
    func testParseEpaMedicationExtemporaneousPreparation() throws {
        let modelsR4Medication = try decode(
            resource: "Medication-Medication-Rezeptur.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Medication.self
        )

        guard let medication = modelsR4Medication.parseEpaMedicationPznIngredient
        else { fail("Could not parse medication"); return }

        expect(medication.name) == "Hydrocortison-Dexpanthenol-Salbe"
        expect(medication.epaMedicationType) == .extemporaneousPreparation // == Rezeptur
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine) == false
        expect(medication.status) == nil
        expect(medication.code) == .init(codings: [], text: "Hydrocortison-Dexpanthenol-Salbe")
        expect(medication.form) == .init(
            codings: [.init(system: .kbvDarreichungsform, code: "SAL", display: nil)],
            text: nil
        )
        expect(medication.amount) == .init(
            numerator: .init(value: "20", unit: "ml"),
            denominator: .init(value: "1")
        )
        expect(medication.batch?.lotNumber) == nil
        expect(medication.ingredients).to(haveCount(2))

        // #MedicationHydrocortison
        let ingredient01 = medication.ingredients[0]
        let expectedIngredient01Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .medicinalProductPackage,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .pzn,
                        code: "03424249",
                        display: "Hydrocortison 1% Creme"
                    )],
                    text: nil
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: .init(
                    lotNumber: "56498416854",
                    expiresOn: nil
                ),
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: []
            )
        )
        expect(expectedIngredient01Item).to(nodiff(ingredient01.item))
        guard case let .epaMedication(ingredient01Item) = ingredient01.item
        else { fail("Unexpected item type"); return }
        expect(ingredient01Item.name) == "Hydrocortison 1% Creme"
        expect(ingredient01Item.pzn) == "03424249"
        expect(ingredient01.isActive) == true
        expect(ingredient01.strength) == .init(
            ratio: .init(
                numerator: .init(
                    value: "50",
                    system: "http://unitsofmeasure.org",
                    code: "g"
                ),
                denominator: .init(
                    value: "100",
                    system: "http://unitsofmeasure.org",
                    code: "g"
                )
            ),
            amountText: nil
        )
        expect(ingredient01.darreichungsForm) == nil

        // #MedicationDexpanthenol
        let ingredient02 = medication.ingredients[1]
        let expectedIngredient02Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .medicinalProductPackage,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .pzn,
                        code: "16667195",
                        display: "Dexpanthenol 5% Creme"
                    )],
                    text: nil
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: .init(
                    lotNumber: "0132456",
                    expiresOn: nil
                ),
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: []
            )
        )
        expect(expectedIngredient02Item).to(nodiff(ingredient02.item))
        guard case let .epaMedication(ingredient02Item) = ingredient02.item
        else { fail("Unexpected item type"); return }
        expect(ingredient02Item.name) == "Dexpanthenol 5% Creme"
        expect(ingredient02Item.epaMedicationType) == .medicinalProductPackage
        expect(ingredient02Item.pzn) == "16667195"
        expect(ingredient02Item.batch?.lotNumber) == "0132456"
        expect(ingredient02.isActive) == true
        expect(ingredient02.strength) == .init(
            ratio: .init(
                numerator: .init(
                    value: "50",
                    system: "http://unitsofmeasure.org",
                    code: "g"
                ),
                denominator: .init(
                    value: "100",
                    system: "http://unitsofmeasure.org",
                    code: "g"
                )
            ),
            amountText: nil
        )
        expect(ingredient02.darreichungsForm) == nil
    }

    // Kombipackung
    func testParseEpaMedicationMedicinalProductPackage() throws {
        let modelsR4Medication = try decode(
            resource: "Medication-Medication-Kombipackung.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Medication.self
        )

        guard let medication = modelsR4Medication.parseEpaMedicationPharmaceuticalProduct
        else { fail("Could not parse medication"); return }

        expect(medication.name) == "CROMO-RATIOPHARM Kombipackung"
        expect(medication.epaMedicationType) == .medicinalProductPackage // == Kombipackung
        expect(medication.drugCategory) == .avm
        expect(medication.isVaccine) == false
        expect(medication.status) == .active
        expect(medication.form) == .init(
            codings: [.init(system: .kbvDarreichungsform, code: "KPG", display: nil)],
            text: "Kombipackung"
        )
        expect(medication.batch?.lotNumber) == "56498416854"
        expect(medication.ingredients).to(haveCount(2))

        let ingredient01 = medication.ingredients[0]
        let expectedIngredient01Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .pharmaceuticalBiologicProduct,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .productKey,
                        code: "01746517-2",
                        display: "Nasenspray, Lösung"
                    )],
                    text: nil
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: nil,
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: [
                    EpaMedicationIngredient(
                        item: .codableConcept(
                            .init(
                                codings: [
                                    .init(
                                        system: .atcDe,
                                        code: "R01AC01",
                                        display: "Natriumcromoglicat"
                                    ),
                                ],
                                text: nil
                            )
                        ),
                        isActive: nil,
                        strength: .init(
                            ratio: .init(
                                numerator: .init(
                                    value: "2.8",
                                    unit: "mg",
                                    system: "http://unitsofmeasure.org",
                                    code: "mg"
                                ),
                                denominator: .init(
                                    value: "1",
                                    unit: "Sprühstoß",
                                    system: "http://unitsofmeasure.org",
                                    code: "1"
                                )
                            ),
                            amountText: nil
                        ),
                        darreichungsForm: nil
                    ),
                ]
            )
        )
        expect(expectedIngredient01Item).to(nodiff(ingredient01.item))
        guard case let .epaMedication(ingredient01Item) = ingredient01.item
        else { fail("Unexpected item type"); return }
        expect(ingredient01Item.name) == "Nasenspray, Lösung"

        let ingredient02 = medication.ingredients[1]
        let expectedIngredient02Item: EpaMedicationIngredient.Item = .epaMedication(
            ErxEpaMedication(
                epaMedicationType: .pharmaceuticalBiologicProduct,
                drugCategory: nil,
                code: EpaMedicationCodableConcept(
                    codings: [.init(
                        system: .productKey,
                        code: "01746517-1",
                        display: "Augentropfen"
                    )],
                    text: nil
                ),
                isVaccine: nil,
                amount: nil,
                form: nil,
                normSizeCode: nil,
                batch: nil,
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: [
                    EpaMedicationIngredient(
                        item: .codableConcept(
                            .init(
                                codings: [
                                    .init(
                                        system: .atcDe,
                                        code: "R01AC01",
                                        display: "Natriumcromoglicat"
                                    ),
                                ],
                                text: nil
                            )
                        ),
                        isActive: nil,
                        strength: .init(
                            ratio: .init(
                                numerator: .init(
                                    value: "20",
                                    unit: "mg",
                                    system: "http://unitsofmeasure.org",
                                    code: "mg"
                                ),
                                denominator: .init(
                                    value: "1",
                                    unit: "ml",
                                    system: "http://unitsofmeasure.org",
                                    code: "ml"
                                )
                            ),
                            amountText: nil
                        ),
                        darreichungsForm: nil
                    ),
                ]
            )
        )
        expect(expectedIngredient02Item).to(nodiff(ingredient02.item))
        guard case let .epaMedication(ingredient02Item) = ingredient02.item
        else { fail("Unexpected item type"); return }
        expect(ingredient02Item.name) == "Augentropfen"
    }

    private func decode<T: Codable>(
        resource file: String,
        from bundle: FHIRBundleDirectories,
        expectedType: T.Type
    ) throws -> T {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(expectedType.self, from: data)
    }
}
