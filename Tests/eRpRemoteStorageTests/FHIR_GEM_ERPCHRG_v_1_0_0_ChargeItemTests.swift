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

final class FHIR_GEM_ERPCHRG_v_1_0_0_ChargeItemTests: XCTestCase {
    func testParseChargeItemIds() throws {
        let chargeItemIds = try decode(resource: "getChargeItemsResponse.json")
            .parseErxChargeItemIDs()

        expect(chargeItemIds.count) == 2
        expect(chargeItemIds[0]) == "abc825bc-bc30-45f8-b109-1b343fff5c45"
        expect(chargeItemIds[1]) == "der124bc-bc30-45f8-b109-4h474wer2h89"
    }

    func testParseChargeItem() throws {
        guard let chargeItem = try decode(resource: "GEM_ERPCHRG_PR_ChargeItem.json")
            .parseErxChargeItem(
                id: "200.000.001.205.203.40",
                with: "fhirData".data(using: .utf8)!
            )
        else {
            fail("Could not parse ModelsR4.Bundle into ChargeItemBundle.")
            return
        }

        expect(chargeItem.enteredDate) == "2023-02-17T14:07:46.964+00:00"

        // medication
        expect(chargeItem.medication?.name) == "Schmerzmittel"
        expect(chargeItem.medication?.dosageForm) == "TAB"
        expect(chargeItem.medication?.dose) == "NB"
        expect(chargeItem.medication?.pzn) == "17091124"
        expect(chargeItem.medication?.amount?.description) == "1 Stk"
        // medication request
        expect(chargeItem.medicationRequest.dosageInstructions) == "1-0-0-0"
        expect(chargeItem.medicationRequest.hasEmergencyServiceFee) == false
        expect(chargeItem.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(chargeItem.medicationRequest.substitutionAllowed) == true
        expect(chargeItem.medicationRequest.coPaymentStatus) == .subjectToCharge
        expect(chargeItem.medicationRequest.bvg) == false
        expect(chargeItem.medicationRequest.multiplePrescription?.mark) == false
        expect(chargeItem.medicationRequest.multiplePrescription?.numbering).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.totalNumber).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.startPeriod).to(beNil())
        expect(chargeItem.medicationRequest.multiplePrescription?.endPeriod).to(beNil())
        expect(chargeItem.medicationRequest.accidentInfo).to(beNil())
        // patient
        expect(chargeItem.patient?.name) == "Günther Angermänn"
        expect(chargeItem.patient?.address) == "Weiherstr. 74a\n67411 Büttnerdorf"
        expect(chargeItem.patient?.birthDate) == "1976-04-30"
        expect(chargeItem.patient?.phone).to(beNil())
        expect(chargeItem.patient?.status) == "1"
        expect(chargeItem.patient?.insurance) == "Künstler-Krankenkasse Baden-Württemberg"
        expect(chargeItem.patient?.insuranceId) == "X110465770"
        // practitioner
        expect(chargeItem.practitioner?.lanr) == "443236256"
        expect(chargeItem.practitioner?.name) == "Dr. Schraßer"
        expect(chargeItem.practitioner?.qualification) == "Super-Facharzt für alles Mögliche"
        expect(chargeItem.practitioner?.email).to(beNil())
        expect(chargeItem.practitioner?.address).to(beNil())
        // organization
        expect(chargeItem.organization?.name) == "Arztpraxis Schraßer"
        expect(chargeItem.organization?.phone) == "(05808) 9632619"
        expect(chargeItem.organization?.address) == "Halligstr. 98\n85005, Alt Mateo"
        expect(chargeItem.organization?.email) == "andre.teufel@xn--schffer-7wa.name"
        expect(chargeItem.organization?.identifier) == "734374849"
        // pharmacy
        expect(chargeItem.pharmacy?.name) == "Apotheke Crystal Claire Waters"
        expect(chargeItem.pharmacy?.address) == "Görresstr. 789\n48480, Süd Eniefeld"
        expect(chargeItem.pharmacy?.country) == "D"
        expect(chargeItem.pharmacy?.identifier) == "833940499"
        // invoice
        expect(chargeItem.invoice?.currency) == "EUR"
        expect(chargeItem.invoice?.totalGross) == 534.2
        expect(chargeItem.invoice?.totalAdditionalFee) == 217.69
        expect(chargeItem.invoice?.chargeableItems.count) == 2
        expect(chargeItem.invoice?.chargeableItems.first?.factor) == 1.0
        expect(chargeItem.invoice?.chargeableItems.first?.price) == 6.23
        expect(chargeItem.invoice?.chargeableItems.first?.pzn) == "83251256"
        expect(chargeItem.invoice?.chargeableItems.first?.ta1) == "84256543"
        expect(chargeItem.invoice?.chargeableItems.first?.hmrn) == "85258976"
        // medication dispense
        expect(chargeItem.medicationDispense?.identifier) == "e00e96a2-6dae-4036-8e72-42b5c21fdbf3"
        expect(chargeItem.medicationDispense?.whenHandedOver) == "2023-02-17"
        // prescription bundle signature
        expect(chargeItem.prescriptionSignature?.when) == "2023-02-17T14:07:47.806+00:00"
        expect(chargeItem.prescriptionSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.prescriptionSignature?.data?.suffix(10)) == "vDAo+tog=="
        // receipt bundle signature
        expect(chargeItem.receiptSignature?.when) == "2023-02-17T14:07:47.808+00:00"
        expect(chargeItem.receiptSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.receiptSignature?.data?.suffix(10)) == "Mb3ej1h4E="
        // dispense bundle signature
        expect(chargeItem.dispenseSignature?.when) == "2023-02-17T14:07:47.809+00:00"
        expect(chargeItem.dispenseSignature?.sigFormat) == "application/pkcs7-mime"
        expect(chargeItem.dispenseSignature?.data?.suffix(10)) == "aOEsSfDw=="
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_erpChrg_v1_0_0
    ) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle.rawValue)
            .decode(ModelsR4.Bundle.self, from: file)
    }
}
