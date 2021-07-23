//
//  Copyright (c) 2021 gematik GmbH
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

import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    public enum Error: Swift.Error {
        case parseError(String)
    }

    /// Parse and extract all found Pharmacies from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    func parsePharmacyLocations() throws -> [PharmacyLocation] {
        // Collect and parse all Pharmacies
        try entry?.compactMap {
            guard let location = $0.resource?.get(if: ModelsR4.Location.self) else {
                return nil
            }
            return try Self.parse(location: location, $0.fullUrl, from: self)
        } ?? []
    }

    static func parse(location: ModelsR4.Location,
                      _: FHIRPrimitive<FHIRURI>?,
                      from _: ModelsR4.Bundle) throws -> PharmacyLocation {
        guard let id = location.id?.value?.string else { // swiftlint:disable:this identifier_name
            throw Error.parseError("Could not parse id from pharmacy.")
        }
        guard let telematikID = location.telematikID else {
            throw Error.parseError("Could not parse telematikID from pharmacy.")
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
            telematikID: telematikID,
            name: location.name?.value?.string,
            type: location.locationTypes + additionalTypesFromHealthCareService,
            position: PharmacyLocation.Position(
                latitude: location.position?.latitude.value?.decimal,
                longitude: location.position?.longitude.value?.decimal
            ),
            address: PharmacyLocation.Address(
                street: location.address?.line?.first?.value?.string,
                housenumber: nil,
                zip: location.address?.postalCode?.value?.string,
                city: location.address?.city?.value?.string
            ),
            telecom: PharmacyLocation.Telecom(
                phone: location.phone,
                fax: location.fax,
                email: location.email,
                web: location.web
            ),
            hoursOfOperation: location.hoursOfOperations
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
        var types: [PharmacyLocation.PharmacyType] = []

        healthCareServices.forEach { healthService in
            healthService.type?.forEach { codeableConcept in
                codeableConcept.coding?.forEach { coding in
                    if coding.system?.value?.url.absoluteString == FHIRResponseKeys.serviceTypeIDKey {
                        switch coding.code {
                        case "117":
                            types.append(
                                PharmacyLocation.PharmacyType.emergency
                            )
                        case "498":
                            types.append(
                                PharmacyLocation.PharmacyType.mobl
                            )
                        default:
                            // do nothing
                            break
                        }
                    }
                }
            }
        }
        return types
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
    var telematikID: String? {
        identifier?.first {
            $0.system?.value?.url.absoluteString == FHIRResponseKeys.telematikIDKey
        }?.value?.value?.string
    }

    var locationTypes: [PharmacyLocation.PharmacyType] {
        var types: [PharmacyLocation.PharmacyType] = []
        type?.forEach { codeableConcept in
            codeableConcept.coding?.forEach { coding in
                switch coding.code {
                case "PHARM":
                    types.append(
                        PharmacyLocation.PharmacyType.pharm
                    )
                case "OUTPHARM":
                    types.append(
                        PharmacyLocation.PharmacyType.outpharm
                    )
                case "MOBL":
                    types.append(
                        PharmacyLocation.PharmacyType.outpharm
                    )
                default:
                    // do nothing
                    break
                }
            }
        }
        return types
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

internal enum FHIRResponseKeys {
    static let accessCodeKey = "https://gematik.de/fhir/NamingSystem/AccessCode"
    static let telematikIDKey = "https://gematik.de/fhir/NamingSystem/TelematikID"
    static let typeIDKey = "http://terminology.hl7.org/ValueSet/v3-ServiceDeliveryLocationRoleType"
    static let serviceTypeIDKey = "http://terminology.hl7.org/CodeSystem/service-type"
}
