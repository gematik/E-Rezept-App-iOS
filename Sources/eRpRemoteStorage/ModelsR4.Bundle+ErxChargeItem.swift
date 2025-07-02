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
    func parseErxChargeItem( // swiftlint:disable:this function_body_length cyclomatic_complexity
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

        let enteredDate = chargeItem.enteredDate?.value?.description

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

        guard let pharmacyAddress = pharmacy?.twoLineAddress
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization address.")
        }

        guard let pharmacyCountry = pharmacy?.address?.first?.country?.value?.description
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse organization address country.")
        }

        guard let version = dispenseBundle.meta?.profile?.first?.value?.version?.description,
              let fhirPackage = ABDAERezeptAbgabedaten(from: version)
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse version number.")
        }

        let fhirAbgabedatenComposition = fhirPackage.dAV_PKV_PR_ERP_AbgabedatenComposition
        let fhirAbrechnungszeilen = fhirPackage.dAV_EX_ERP_Abrechnungszeilen
        let fhirZusatzdatenHerstellung = fhirPackage.dAV_EX_ERP_ZusatzdatenHerstellung
        let fhirZusatzdatenEinheit = fhirPackage.dAV_EX_ERP_ZusatzdatenEinheit

        let invoice = dispenseBundle.invoice

        let dispenseComposition = dispenseBundle.findResource(
            for: fhirAbgabedatenComposition.meta_profile,
            type: Composition.self
        )

        let bundleEntry: Reference? = dispenseComposition?.section?.first { section in
            section.title?.value?.string == fhirAbgabedatenComposition.dispenseInformationKey
        }?.entry?.first

        var chargeableItems: [DavInvoice.ChargeableItem] = []
        var productionSteps: [DavInvoice.Production] = []

        let medication = prescriptionBundle.parseErxMedication()

        if let reference = bundleEntry?.reference {
            let medicationDispense = dispenseBundle.findResource(with: reference, type: MedicationDispense.self)

            let invoice = medicationDispense?.extensions(for: fhirAbrechnungszeilen.meta_profile)

            if let reference = invoice?.first?.value?.referenceOrNil?.reference {
                let invoice = dispenseBundle.findResource(with: reference, type: Invoice.self)
                chargeableItems += try invoice?.chargeableItems() ?? []
            }

            let ext = medicationDispense?.extensions(for: fhirZusatzdatenHerstellung.meta_profile)

            if medication.profile != .compounding {
                for element in ext ?? [] {
                    guard let reference = element.value?.referenceOrNil?.reference else { continue }

                    let secondMedicationDispense = dispenseBundle.findResource(
                        with: reference,
                        type: MedicationDispense.self
                    )

                    let invoice = secondMedicationDispense?.extensions(for: fhirZusatzdatenEinheit.meta_profile)
                    if let reference = invoice?.first?.value?.referenceOrNil?.reference {
                        let invoice = dispenseBundle.findResource(with: reference, type: Invoice.self)
                        chargeableItems += try invoice?.chargeableItems(separation: true) ?? []
                    }
                }
            } else {
                for element in ext ?? [] {
                    guard let reference = element.value?.referenceOrNil?.reference else { continue }

                    let secondMedicationDispense = dispenseBundle.findResource(
                        with: reference,
                        type: MedicationDispense.self
                    )

                    let invoice = secondMedicationDispense?.extensions(for: fhirZusatzdatenEinheit.meta_profile)
                    if let reference = invoice?.first?.value?.referenceOrNil?.reference {
                        let invoice = dispenseBundle.findResource(with: reference, type: Invoice.self)
                        let ingredients = try invoice?.productionSteps() ?? []

                        let sequence: Int32
                        if let ext = secondMedicationDispense?.extensions(for: fhirZusatzdatenEinheit.extension_counter)
                            .first?.value,
                            case let Extension.ValueX.positiveInt(value) = ext {
                            sequence = value.value?.integer ?? 0
                        } else {
                            sequence = 0
                        }

                        productionSteps.append(
                            DavInvoice.Production(
                                title: "Herstellung \(sequence)",
                                createdOn: secondMedicationDispense?.whenPrepared?.value?.description ?? "",
                                sequence: "1",
                                ingredients: ingredients
                            )
                        )
                    }
                }
            }
        }

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

        let taskId = chargeItem.identifier?.first { identifier in
            Workflow.Key.prescriptionIdKeys.contains { $0.value == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string

        return ErxChargeItem(
            identifier: chargeItemIdentifier,
            fhirData: fhirData,
            taskId: taskId,
            enteredDate: enteredDate,
            accessCode: chargeItem.accessCode,
            medication: medication,
            medicationRequest: prescriptionBundle.parseErxMedicationRequest(),
            patient: ErxPatient(
                title: patient?.title,
                name: patient?.fullName,
                address: patient?.singleLineAddress,
                birthDate: patient?.birthDate?.value?.description,
                phone: patient?.phone,
                status: prescriptionBundle.coverageStatus,
                insurance: prescriptionBundle.coverage?.payor.first?.display?.value?.string,
                insuranceId: patient?.insuranceId,
                coverageType: ErxPatient.CoverageType(rawValue: prescriptionBundle.coverageType)
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
                address: organization?.twoLineAddress
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
                chargeableItems: chargeableItems,
                productionSteps: productionSteps
            ),
            medicationDispense: medicationDispense,
            prescriptionSignature: prescriptionBundle.parseErxSignature,
            receiptSignature: receiptBundle.parseErxSignature,
            dispenseSignature: dispenseBundle.parseErxSignature
        )
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

extension ModelsR4.ChargeItem {
    var accessCode: String? {
        identifier?.first { identifier in
            Workflow.Key.accessCodeKeys.contains { $0.value == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
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

    func productionSteps(special _: Bool = false) throws -> [DavInvoice.Production.Ingredient] {
        try lineItem?.map {
            let factor = $0.priceComponent?.first?.factor?.value?.decimal

            guard let price = $0.priceComponent?.first?.amount?.value?.value?.decimal
            else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse invoice priceComponent amount value.")
            }

            let mark: String?

            if let value = $0.priceComponent?.first?.extensions( // swiftlint:disable:next line_length
                for: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenFaktorkennzeichen"
            ).first?.value,
                case let Extension.ValueX.codeableConcept(codeable) = value {
                mark = codeable.coding?.first?.code?.value?.string
            } else {
                mark = nil
            }

            return DavInvoice.Production.Ingredient(
                pzn: $0.pzn ?? $0.ta1 ?? "NA",
                factorMark: mark,
                factor: factor.map { $0 / 1000 },
                price: price
            )
        } ?? []
    }

    func chargeableItems(separation: Bool = false) throws -> [DavInvoice.ChargeableItem] {
        try lineItem?.map {
            guard let factor = $0.priceComponent?.first?.factor?.value?.decimal
            else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse invoice priceComponent factor.")
            }

            guard let price = $0.priceComponent?.first?.amount?.value?.value?.decimal
            else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse invoice priceComponent amount value.")
            }

            let zusatzAttribute = try parseZusatzAttribute(lineItem: $0)

            if separation {
                return DavInvoice.ChargeableItem(
                    factor: factor / 1000,
                    price: nil,
                    description: $0.chargeItem.chargeItemCodeableConcept?.text?.value?.string,
                    pzn: $0.pzn,
                    ta1: $0.ta1,
                    hmrn: $0.hmrn,
                    zusatzattribut: zusatzAttribute
                )
            }
            return DavInvoice.ChargeableItem(
                factor: factor,
                price: price,
                description: $0.chargeItem.chargeItemCodeableConcept?.text?.value?.string,
                pzn: $0.pzn,
                ta1: $0.ta1,
                hmrn: $0.hmrn,
                zusatzattribut: zusatzAttribute
            )
        } ?? []
    }

    // swiftlint:disable:next cyclomatic_complexity
    func parseZusatzAttribute(lineItem: InvoiceLineItem) throws -> DavInvoice.ChargeableItem.Zusatzattribut? {
        guard let zusatzAttributeExtension = lineItem
            .extensions(
                for: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Zusatzattribute"
            )
            .first?.extension?.first?.extension else { return nil }

        // get DAV-CS-ERP-ZusatzattributGruppe value to identify the type
        let groupValueX = zusatzAttributeExtension.first {
            $0.url.value?.url.absoluteString == "Gruppe"
        }?.value

        guard let valueX = groupValueX, case let Extension.ValueX.codeableConcept(string) = valueX,
              let group = string.coding?.first?.code?.value?.string else { return nil }

        // unwrap the value and assign it accordingly to ZusatzattributGruppe
        switch group {
        case "11":
            let dateValueX = zusatzAttributeExtension
                .first(where: { $0.url.value?.url.absoluteString == "DatumUhrzeit" })?.value
            if let valueX = dateValueX, case let Extension.ValueX.dateTime(date) = valueX,
               let date = date.value?.description {
                return .notdienst(date)
            }
        case "12":
            let stringValueX = zusatzAttributeExtension
                .first(where: { $0.url.value?.url.absoluteString == "DokumentationFreitext" })?
                .value
            if let valueX = stringValueX, case let Extension.ValueX.string(string) = valueX,
               let string = string.value?.description {
                return .zusätzlicheAbgabeangaben(string)
            }
        case "16":
            let stringValueX = zusatzAttributeExtension
                .first(where: { $0.url.value?.url.absoluteString == "Spender-PZN" })?.value
            if let valueX = stringValueX, case let Extension.ValueX.codeableConcept(string) = valueX,
               let string = string.coding?.first?.code?.value?.string {
                return .teilmengenabgabe(string)
            }
        case "101":
            let stringValueX = zusatzAttributeExtension
                .first(where: { $0.url.value?.url.absoluteString == "Schluessel" })?.value
            if let valueX = stringValueX, case let Extension.ValueX.codeableConcept(string) = valueX,
               let string = string.coding?.first?.code?.value?.string {
                return .autidem(string)
            }
        default:
            return nil
        }

        return nil
    }
}

extension ModelsR4.InvoiceLineItem {
    var pzn: String? {
        coding(for: Dispense.Key.ChargeItem.pzn)?.code?.value?.string
    }

    var ta1: String? {
        coding(for: Dispense.Key.ChargeItem.ta1)?.code?.value?.string
    }

    var hmrn: String? {
        coding(for: Dispense.Key.ChargeItem.hmnr)?.code?.value?.string
    }

    func coding(for keys: [Dispense.Version: String]) -> ModelsR4.Coding? {
        if case let ChargeItemX.codeableConcept(item) = chargeItem {
            return item.coding?.first { coding in
                keys.contains {
                    $0.value == coding.system?.value?.url.absoluteString
                }
            }
        }
        return nil
    }
}

extension ModelsR4.InvoiceLineItem.ChargeItemX {
    var chargeItemCodeableConcept: CodeableConcept? {
        switch self {
        case let .codeableConcept(codeableConcept):
            return codeableConcept
        default:
            return nil
        }
    }
}
