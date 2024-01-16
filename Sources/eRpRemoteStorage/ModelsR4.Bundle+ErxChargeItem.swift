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
import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    /// Parse and extract all found ErxChargeItem IDs from `Self`
    ///
    /// - Returns: Array with all found charge item ID's
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxChargeItemIDs() throws -> [String] {
        // Collect and parse all ErxTask id's
        try entry?.compactMap {
            guard let chargeItem = $0.resource?.get(if: ModelsR4.ChargeItem.self) else {
                return nil
            }
            guard let identifier = chargeItem.id?.value?.string else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse id from charge item.")
            }
            return identifier
        } ?? []
    }

    /// Parse and extract a ErxChargeItem from `Self`
    ///
    /// - Returns: A ErxChargeItem or nil
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxChargeItem( // swiftlint:disable:this function_body_length
        id: ErxChargeItem.ID,
        with fhirData: Data
    ) throws -> ErxChargeItem? {
        // Collect and parse ErxChargeItem
        guard let entry = entry?.first, // for now we assume that there is only one charge item
              let chargeItem = entry.resource?.get(if: ModelsR4.ChargeItem.self),
              let chargeItemIdentifier = chargeItem.id?.value?.string,
              id == chargeItemIdentifier
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse the charge item.")
        }

        // MARK: - KBV_PR_ERP_Bundle

        let prescriptionBundle = try parseSupportingInformationBundle(
            from: chargeItem,
            with: ErpCharge.Key.ChargeItem.prescriptionBundle
        )
        let patient = prescriptionBundle.patient
        let practitioner = prescriptionBundle.practitioner
        let organization = prescriptionBundle.organization

        // MARK: - GEM_ERP_PR_Bundle

        let receiptBundle = try parseSupportingInformationBundle(
            from: chargeItem,
            with: ErpCharge.Key.ChargeItem.receiptBundle
        )

        // MARK: - DAV-PKV-PR-ERP-AbgabedatenBundle

        let dispenseBundle = try parseSupportingInformationBundle(
            from: chargeItem,
            with: ErpCharge.Key.ChargeItem.dispenseBundle
        )
        let pharmacy = dispenseBundle.organization

        guard let pharmacyId = pharmacy?.davOrganizationIdentifier
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization identifier.")
        }

        guard let pharmacyName = pharmacy?.name?.value?.string
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization name.")
        }

        guard let pharmacyAddress = pharmacy?.completeAddress
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization address.")
        }

        guard let pharmacyCountry = pharmacy?.address?.first?.country?.value?.description
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization address country.")
        }

        let invoice = dispenseBundle.invoice
        let chargableItems = try invoice?.chargeableItems() ?? []

        guard let totalAdditionalFee = invoice?.totalAdditionalFee
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse invoice totalGross additionalFee.")
        }

        guard let totalGross = invoice?.totalGross?.value?.value?.decimal
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse invoice totalGross value.")
        }

        guard let currency = invoice?.totalGross?.currency?.value?.string
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse invoice totalGross currency.")
        }

        // The current dispense bundle v1.3.0 only specifies a single medicationDispense
        let medicationDispense = try dispenseBundle.parseDavMedicationDispenses().first
        let productionSteps: [DavInvoice.Production] = []

        return ErxChargeItem(
            identifier: chargeItemIdentifier,
            fhirData: fhirData,
            taskId: chargeItem.taskId,
            enteredDate: chargeItem.enteredDate?.value?.description,
            accessCode: chargeItem.accessCode,
            medication: prescriptionBundle.parseErxMedication(),
            medicationRequest: prescriptionBundle.parseErxMedicationRequest(),
            patient: ErxPatient(
                title: patient?.title,
                name: patient?.fullName,
                address: patient?.completeAddress,
                birthDate: patient?.birthDate?.value?.description,
                phone: patient?.phone,
                status: prescriptionBundle.coverageStatus,
                insurance: prescriptionBundle.coverage?.payor.first?.display?.value?.string,
                insuranceId: patient?.insuranceId
            ),
            practitioner: ErxPractitioner(
                title: practitioner?.title,
                lanr: practitioner?.lanr,
                name: practitioner?.fullName,
                qualification: practitioner?.qualificationText,
                email: practitioner?.email,
                address: practitioner?.completeAddress
            ),
            organization: ErxOrganization(
                identifier: organization?.erxOrganizationIdentifier,
                name: organization?.name?.value?.string,
                phone: organization?.phone,
                email: organization?.email,
                address: organization?.completeAddress
            ),
            pharmacy: DavOrganization(
                identifier: pharmacyId,
                name: pharmacyName,
                address: pharmacyAddress,
                country: pharmacyCountry
            ),
            invoice: DavInvoice(
                totalAdditionalFee: totalAdditionalFee,
                totalGross: totalGross,
                currency: currency,
                chargeableItems: chargableItems,
                productionSteps: productionSteps
            ),
            medicationDispense: medicationDispense,
            prescriptionSignature: prescriptionBundle.parseErxSignature,
            receiptSignature: receiptBundle.parseErxSignature,
            dispenseSignature: dispenseBundle.parseErxSignature
        )
    }
}

extension ModelsR4.ChargeItem {
    var taskId: String? {
        identifier?.first { identifier in
            Workflow.Key.prescriptionIdKeys.contains {
                $0.value == identifier.system?.value?.url.absoluteString
            }
        }?.value?.value?.string
    }

    var accessCode: String? {
        identifier?.first { identifier in
            Workflow.Key.accessCodeKeys.contains {
                $0.value == identifier.system?.value?.url.absoluteString
            }
        }?.value?.value?.string
    }
}

extension ModelsR4.Bundle {
    var parseErxSignature: ErxSignature? {
        guard let whenDate = signature?.when.value?.description
        else { return nil }

        return .init(
            when: whenDate,
            sigFormat: signature?.sigFormat?.value?.string,
            data: signature?.data?.value?.dataString
        )
    }

    func parseSupportingInformationBundle(
        from chargeItem: ModelsR4.ChargeItem,
        with bundleKey: [ErpCharge.Version: String]
    ) throws -> ModelsR4.Bundle {
        guard let reference = chargeItem.supportingInformation?
            .first(where: { information in
                bundleKey.contains {
                    $0.value == information.display?.value?.string
                }
            })?.reference
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse bundle reference with key: \(bundleKey).")
        }

        guard let bundle = findResource(with: reference, type: ModelsR4.Bundle.self)
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse bundle with key: \(bundleKey).")
        }

        return bundle
    }
}

extension ModelsR4.Invoice {
    var totalAdditionalFee: Decimal? {
        totalGross?.extension?.first { total in
            Dispense.Key.totalAdditionalFee.contains { key in
                key.value == total.url.value?.url.absoluteString
            }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.money(money) = valueX {
                return money.value?.value?.decimal
            }
            return nil
        }
    }

    func chargeableItems() throws -> [DavInvoice.ChargeableItem] {
        try lineItem?.map {
            guard let factor = $0.priceComponent?.first?.factor?.value?.decimal
            else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse invoice priceComponent factor.")
            }

            guard let price = $0.priceComponent?.first?.amount?.value?.value?.decimal
            else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse invoice priceComponent amount value.")
            }

            return DavInvoice.ChargeableItem(
                factor: factor,
                price: price,
                description: $0.description,
                pzn: $0.pzn,
                ta1: $0.ta1,
                hmrn: $0.hmrn
            )
        } ?? []
    }
}

extension ModelsR4.InvoiceLineItem {
    var description: String? {
        chargeItemCodableConcept?.text?.value?.string
    }

    var pzn: String? {
        coding(for: Dispense.Key.ChargeItem.pzn)?.code?.value?.string
    }

    var ta1: String? {
        coding(for: Dispense.Key.ChargeItem.ta1)?.code?.value?.string
    }

    var hmrn: String? {
        coding(for: Dispense.Key.ChargeItem.hmnr)?.code?.value?.string
    }

//    var packagingSize: String? {
//        self.chargeItemCodableConcept?.
//    }

    var chargeItemCodableConcept: CodeableConcept? {
        if case let ChargeItemX.codeableConcept(item) = chargeItem {
            return item
        }
        return nil
    }

    func coding(for keys: [Dispense.Version: String]) -> ModelsR4.Coding? {
        chargeItemCodableConcept?.coding?.first { coding in
            keys.contains {
                $0.value == coding.system?.value?.url.absoluteString
            }
        }
    }
}
