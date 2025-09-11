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
import XCTest

// FHIR GEM ERPCHRG tests for ChargeItem in Version 1.1.0
final class FHIR_GEM_ERPCHRG_v_1_1_0_ChargeItemTests: XCTestCase {
    func testParseChargeItem() throws {
        guard let chargeItem = try decode(resource: "GEM_ERPCHRG_PR_ChargeItem.json")
            .parseErxChargeItem(
                id: "200.000.001.206.112.29",
                with: "fhirData".data(using: .utf8)!
            )
        else {
            fail("Could not parse ModelsR4.Bundle into ChargeItemBundle.")
            return
        }

        expect(chargeItem.taskId) == "200.000.001.206.112.29"
        expect(chargeItem.enteredDate) == "2025-10-01T15:29:00.434+00:00"
        expect(chargeItem.accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"

        // medication
        expect(chargeItem.medication?.name) == "Venlafaxin - 1 A Pharma® 75mg 100 Tabl. N3"
        expect(chargeItem.medication?.dosageForm) == "TAB"
        expect(chargeItem.medication?.normSizeCode) == "N3"
        expect(chargeItem.medication?.pzn) == "05392039"
        expect(chargeItem.medication?.amount?.description).to(beNil())
        expect(chargeItem.medication?.ingredients.first?.text) == "Venlafaxinhydrochlorid"
        expect(chargeItem.medication?.ingredients.first?.strength?.numerator.value) == "84.88"
        // medication request
        expect(chargeItem.medicationRequest.dosageInstructions) == "Dj"
        expect(chargeItem.medicationRequest.hasEmergencyServiceFee) == false
        expect(chargeItem.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(chargeItem.medicationRequest.substitutionAllowed) == true
        expect(chargeItem.medicationRequest.coPaymentStatus) == .noSubjectToCharge
        expect(chargeItem.medicationRequest.ser) == true
        expect(chargeItem.medicationRequest.multiplePrescription?.mark) == false
        expect(chargeItem.medicationRequest.multiplePrescription?.numbering).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.totalNumber).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.startPeriod).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.endPeriod).to(beNil())
        expect(chargeItem.medicationRequest.accidentInfo).to(beNil())
        expect(chargeItem.medicationRequest.quantity).to(equal(.init(value: "1", unit: "Packung")))
        // patient
        expect(chargeItem.patient?.name) == "Sahra Schuhmann"
        expect(chargeItem.patient?.address) == "Berliner Straße 1, 25813 Husum"
        expect(chargeItem.patient?.birthDate) == "1970-12-24"
        expect(chargeItem.patient?.phone).to(beNil())
        expect(chargeItem.patient?.status) == "1"
        expect(chargeItem.patient?.insurance) == "AOK Baden-Württember/BVG"
        expect(chargeItem.patient?.insuranceId) == "K220645122"
        // practitioner
        expect(chargeItem.practitioner?.lanr) == "582369858"
        expect(chargeItem.practitioner?.name) == "Emilia Becker"
        expect(chargeItem.practitioner?.qualification) == "Fachärztin für Psychiatrie und Psychotherapie"
        expect(chargeItem.practitioner?.email).to(beNil())
        expect(chargeItem.practitioner?.address).to(beNil())
        // organization
        expect(chargeItem.organization?.name) == "Praxis für Psychiatrie und Psychotherapie"
        expect(chargeItem.organization?.phone) == "030369258147"
        expect(chargeItem.organization?.address) == "Herbert-Lewin-Platz 2\n10623 Berlin"
        expect(chargeItem.organization?.email).to(beNil())
        expect(chargeItem.organization?.identifier) == "723333300"
        // pharmacy
        expect(chargeItem.pharmacy?.name) == "Adler-Apotheke"
        expect(chargeItem.pharmacy?.address) == "Taunusstraße 89\n63225 Langen"
        expect(chargeItem.pharmacy?.country) == "D"
        expect(chargeItem.pharmacy?.identifier) == "308412345"
        // invoice
        expect(chargeItem.invoice?.currency) == "EUR"
        expect(chargeItem.invoice?.totalGross) == 21.04
        expect(chargeItem.invoice?.totalAdditionalFee) == 0
        expect(chargeItem.invoice?.chargeableItems.count) == 1
        expect(chargeItem.invoice?.chargeableItems.first?.factor) == 1.0
        expect(chargeItem.invoice?.chargeableItems.first?.price) == 21.04
        expect(chargeItem.invoice?.chargeableItems.first?.description) ==
            "Sumatriptan 1A Pharma 100 mg Tabletten, 12 St"
        expect(chargeItem.invoice?.chargeableItems.first?.pzn) == "06313728"
        expect(chargeItem.invoice?.chargeableItems.first?.ta1) == "84256543"
        expect(chargeItem.invoice?.chargeableItems.first?.hmrn) == "85258976"
        // medication dispense
        expect(chargeItem.medicationDispense?.identifier) == "335784b4-3f89-47cc-b32f-bc386a212e11"
        expect(chargeItem.medicationDispense?.whenHandedOver) == "2023-07-24"
        // prescription bundle signature
        expect(chargeItem.prescriptionSignature?.when) == "2023-02-23T15:08:32.983+00:00"
        expect(chargeItem.prescriptionSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.prescriptionSignature?.data?.suffix(10)) == "wNkB1inA=="
        // receipt bundle signature
        expect(chargeItem.receiptSignature?.when) == "2023-02-23T15:08:32.985+00:00"
        expect(chargeItem.receiptSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.receiptSignature?.data?.suffix(10)) == "SWNoW9f9ep"
        // dispense bundle signature
        expect(chargeItem.dispenseSignature?.when) == "2023-02-17T14:07:47.809+00:00"
        expect(chargeItem.dispenseSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.dispenseSignature?.data?.suffix(10)) == "aOEsSfDw=="
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_erpChrg_v1_1_0
    ) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
