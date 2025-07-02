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
import OpenSSL

// sourcery: CodedError = "510"
public enum PharmacyBundleParsingError: Swift.Error {
    // sourcery: errorCode = "01"
    case parseError(String)
}

/// [REQ:BSI-eRp-ePA:O.Source_2#7] Extension containing all FHIR related parsing for Pharmacies
extension ModelsR4.Bundle {
    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    func parsePharmacyLocations() throws -> [PharmacyLocation] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let location = $0.resource?.get(if: ModelsR4.Location.self) else {
                return nil
            }
            return try Self.parse(location: location)
        } ?? []
    }

    /// Parse and extract all found avs certificates from `self`
    ///
    /// - Returns: Array with all found and parsed certificates
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseCertificates() throws -> [X509] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap { anEntry -> X509? in
            guard let binaryResource = anEntry.resource?.get(if: ModelsR4.Binary.self) else {
                return nil
            }
            return try Self.parse(binary: binaryResource)
        }
        // Work around for filtering for the AVS encryption certificates:
        // We test wether the certificate's public key type is brainpoolP256r1.
        // If it is not, for now we assume it to be a RSA-type (the ones we are looking for).
        // (since only brainpoolP256r1 OR RSA-type public keys are used in our context (for now)).
        // TODO: test directly for the subjectpublickey type in OpenSSL-Swift // swiftlint:disable:this todo
        .filter { $0.brainpoolP256r1KeyExchangePublicKey() == nil } ?? []
    }

    static func parse(binary: ModelsR4.Binary) throws -> X509? {
        guard let base64DataString = binary.data?.value?.dataString else {
            return nil
        }
        guard let data = Data(base64Encoded: base64DataString) else { return nil }
        return try? X509(der: data)
    }

    static func parse(location: ModelsR4.Location) throws -> PharmacyLocation {
        guard let id = location.id?.value?.string else {
            throw PharmacyBundleParsingError.parseError("Could not parse id from pharmacy.")
        }

        let status = location.pharmacyLocationStatus

        guard let telematikID = location.telematikID else {
            throw PharmacyBundleParsingError.parseError("Could not parse telematikID from pharmacy.")
        }

        // swiftlint:disable:next todo
        // TODO: In future we need to add the whole HealthCareService object
        //       and e.g. also evaluate the times for emergency open hours.
        //       For now we only evaluate the types and add them to location types.
        let healthCareServices: [HealthcareService] = location.contained?.compactMap { proxy in
            proxy.get(if: HealthcareService.self)
        } ?? []

        let additionalTypesFromHealthCareService =
            evaluateHealthCareServiceForTypes(healthCareServices: healthCareServices)

        let pharmacy = PharmacyLocation(
            id: id,
            status: status,
            telematikID: telematikID,
            name: location.name?.value?.string,
            types: location.locationTypes + additionalTypesFromHealthCareService,
            position: PharmacyLocation.Position(
                latitude: location.position?.latitude.value?.decimal,
                longitude: location.position?.longitude.value?.decimal
            ),
            address: PharmacyLocation.Address(
                street: location.address?.line?.first?.value?.string,
                houseNumber: nil,
                zip: location.address?.postalCode?.value?.string,
                city: location.address?.city?.value?.string
            ),
            telecom: PharmacyLocation.Telecom(
                phone: location.phone,
                fax: location.fax,
                email: location.email,
                web: location.web
            ),
            hoursOfOperation: location.hoursOfOperations,
            avsEndpoints: location.avsEndpoints
        )

        return pharmacy
    }

    func findResource<Resource: ModelsR4.Resource>(with identifier: FHIRPrimitive<FHIRString>,
                                                   type _: Resource.Type) -> Resource? {
        let newIdentifier = identifier.droppingLeadingNumberSign

        return entry?.lazy.compactMap {
            $0.resource?.get(if: Resource.self)
        }
        .first { bundleEntry in
            newIdentifier == bundleEntry.id
        }
    }

    static func evaluateHealthCareServiceForTypes(healthCareServices: [HealthcareService])
        -> [PharmacyLocation.PharmacyType] {
        var pharmacyTypes: [PharmacyLocation.PharmacyType] = []

        healthCareServices.forEach { healthService in
            healthService.type?.forEach { codableConcept in
                codableConcept.coding?.forEach { coding in
                    if coding.system?.value?.url.absoluteString == Terminology.Key.CodeSystem.serviceType {
                        switch coding.code {
                        case "117":
                            pharmacyTypes.append(
                                PharmacyLocation.PharmacyType.emergency
                            )
                        // [[REQ:gemSpec_eRp_APOVZD:A_21779] delivery pharmacy
                        case "498":
                            pharmacyTypes.append(
                                PharmacyLocation.PharmacyType.delivery
                            )
                        default:
                            // do nothing
                            break
                        }
                    }
                }
            }
        }
        return pharmacyTypes
    }
}

extension ModelsR4.FHIRPrimitive where PrimitiveType == ModelsR4.FHIRString {
    var droppingLeadingNumberSign: Self {
        guard let stringValue = value?.string, stringValue.starts(with: "#") else {
            return self
        }

        return FHIRPrimitive(FHIRString(String(stringValue.dropFirst())))
    }
}

extension ModelsR4.Location {
    var pharmacyLocationStatus: PharmacyLocation.Status? {
        if let status = status?.value {
            switch status {
            case .active: return .active
            case .suspended: return .suspended
            case .inactive: return .inactive
            }
        } else {
            return nil
        }
    }

    var telematikID: String? {
        identifier?.first { id in
            Workflow.Key.telematikIdKeys.contains {
                $0.value == id.system?.value?.url.absoluteString
            }
        }?.value?.value?.string
    }

    var locationTypes: [PharmacyLocation.PharmacyType] {
        var pharmacyTypes: [PharmacyLocation.PharmacyType] = []
        type?.forEach { codableConcept in
            codableConcept.coding?.forEach { coding in
                switch coding.code {
                case "PHARM":
                    pharmacyTypes.append(
                        PharmacyLocation.PharmacyType.pharm
                    )
                // [[REQ:gemSpec_eRp_APOVZD:A_21779] Map pickup pharmacy
                case "OUTPHARM":
                    pharmacyTypes.append(
                        PharmacyLocation.PharmacyType.outpharm
                    )
                // [[REQ:gemSpec_eRp_APOVZD:A_21779] Map shipping pharmacy
                case "MOBL":
                    pharmacyTypes.append(
                        PharmacyLocation.PharmacyType.mobl
                    )
                default:
                    // do nothing
                    break
                }
            }
        }
        return pharmacyTypes
    }

    var avsEndpoints: PharmacyLocation.AVSEndpoints? {
        guard let avsSystems = telecom?.filter({ $0.system?.value == ContactPointSystem.other }) else {
            return nil
        }

        var pickupUrl: String?
        var deliveryUrl: String?
        var shipmentUrl: String?
        avsSystems.forEach { system in
            switch system.rank?.value?.integer {
            case ApoVzd.Key.pickupRank:
                pickupUrl = system.value?.value?.string
            case ApoVzd.Key.deliveryRank:
                deliveryUrl = system.value?.value?.string
            case ApoVzd.Key.shipmentRank:
                shipmentUrl = system.value?.value?.string
            default:
                return
            }
        }

        guard pickupUrl != nil || shipmentUrl != nil || deliveryUrl != nil else {
            return nil
        }

        return PharmacyLocation.AVSEndpoints(
            onPremiseUrl: pickupUrl,
            shipmentUrl: shipmentUrl,
            deliveryUrl: deliveryUrl
        )
    }

    var phone: String? {
        telecom?.first {
            $0.system?.value == ContactPointSystem.phone
        }?.value?.value?.string
    }

    var fax: String? {
        telecom?.first {
            $0.system?.value == ContactPointSystem.fax
        }?.value?.value?.string
    }

    var email: String? {
        telecom?.first {
            $0.system?.value == ContactPointSystem.email
        }?.value?.value?.string
    }

    var web: String? {
        telecom?.first {
            $0.system?.value == ContactPointSystem.url
        }?.value?.value?.string
    }

    var hoursOfOperations: [PharmacyLocation.HoursOfOperation] {
        var hours: [PharmacyLocation.HoursOfOperation] = []
        hoursOfOperation?.forEach { hop in
            let pharmacyHop = PharmacyLocation.HoursOfOperation(
                daysOfWeek: hop.daysOfWeek?.compactMap { $0.value?.rawValue } ?? [],
                openingTime: hop.openingTime?.value?.description,
                closingTime: hop.closingTime?.value?.description
            )
            hours.append(pharmacyHop)
        }
        return hours
    }
}

/// https://simplifier.net/vzd-fhir-directory
public enum ApoVzd {
    /// Supported Keys from `gemF_eRp_altern_Zuweisung`
    public enum Key {
        /// Rank for the url of the onPremise service
        public static let pickupRank: Int32 = 100
        /// Rank for the url of the delivery service
        public static let deliveryRank: Int32 = 200
        /// Rank for the url of the shipment service
        public static let shipmentRank: Int32 = 300
    }
}
