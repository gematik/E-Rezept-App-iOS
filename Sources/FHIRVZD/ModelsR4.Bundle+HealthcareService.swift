//
//  Copyright (c) 2025 gematik GmbH
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

// sourcery: CodedError = "610"
public enum HealthcareServiceBundleParsingError: Swift.Error {
    // sourcery: errorCode = "01"
    case parseError(String)
}

extension ModelsR4.Bundle {
    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    func parsePharmacyLocations() throws -> [PharmacyLocation] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let healthcareService = $0.resource?.get(if: ModelsR4.HealthcareService.self) else {
                return nil
            }
            return try Self.parse(healthcareService: healthcareService, bundle: self)
        } ?? []
    }

    static func parse(
        healthcareService: ModelsR4.HealthcareService,
        bundle: ModelsR4.Bundle
    ) throws -> PharmacyLocation {
        guard let id = healthcareService.id?.value?.string else {
            throw HealthcareServiceBundleParsingError.parseError("Could not parse id from healthcare service.")
        }

        guard let organizationReference = healthcareService.providedBy?.reference,
              let organization = bundle.findResource(with: organizationReference, type: ModelsR4.Organization.self)
        else {
            throw HealthcareServiceBundleParsingError
                .parseError("Could not parse organization from healthcare service.")
        }

        guard let telematikID = organization.telematikID else {
            throw HealthcareServiceBundleParsingError.parseError("Could not parse telematikID from organization.")
        }

        let telecom = PharmacyLocation.Telecom(
            phone: healthcareService.phone,
            fax: healthcareService.fax,
            email: healthcareService.email,
            web: healthcareService.web
        )

        var address: PharmacyLocation.Address?
        var position: PharmacyLocation.Position?
        if let locationReference = healthcareService.location?.first?.reference,
           let location = bundle.findResource(with: locationReference, type: ModelsR4.Location.self) {
            address = PharmacyLocation.Address(
                street: location.address?.line?.first?.value?.string,
                houseNumber: nil,
                zip: location.address?.postalCode?.value?.string,
                city: location.address?.city?.value?.string
            )
            position = PharmacyLocation.Position(
                latitude: location.position?.latitude.value?.decimal,
                longitude: location.position?.longitude.value?.decimal
            )
        }

        return PharmacyLocation(
            id: id,
            telematikID: telematikID,
            name: organization.name?.value?.string,
            types: healthcareService.pharmacyTypes,
            position: position,
            address: address,
            telecom: telecom,
            hoursOfOperation: healthcareService.hoursOfOperations
        )
    }

    func findResource<Resource: ModelsR4.Resource>(
        with identifier: FHIRPrimitive<FHIRString>,
        type _: Resource.Type
    ) -> Resource? {
        let newIdentifier = identifier.droppingLeadingNumberSign

        // try finding the resource by fullUrl
        if let bundle = entry?.lazy.first(where: { bundleEntry in
            guard let urlString = bundleEntry.fullUrl?.value?.url.absoluteString,
                  let resourceIdentifier = newIdentifier.value?.string
            else { return false }
            return urlString.contains(resourceIdentifier)
        })?
            .resource?
            .get(if: Resource.self) {
            return bundle
        }
        return nil
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

extension ModelsR4.HealthcareService {
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
        availableTime?.forEach { time in
            let pharmacyHop = PharmacyLocation.HoursOfOperation(
                daysOfWeek: time.daysOfWeek?.compactMap { $0.value?.rawValue } ?? [],
                openingTime: time.availableStartTime?.value?.description,
                closingTime: time.availableEndTime?.value?.description
            )
            hours.append(pharmacyHop)
        }
        return hours
    }

    var pharmacyTypes: [PharmacyLocation.PharmacyType] {
        specialty?.first { concept in
            concept.text?.value?.string == FHIRDirectory.Key.specialtyKey
        }?
            .coding?
            .filter { coding in
                coding.system?.value?.url.absoluteString == FHIRDirectory.Key.CodeSystem.pharmacyHealthcareSpecialty
            }
            .compactMap { coding -> PharmacyLocation.PharmacyType? in
                guard let rawValue = coding.code?.value?.string
                else { return nil }
                return Specialty(rawValue: rawValue)?.pharmacyType
            } ?? []
    }
}

extension ModelsR4.Organization {
    var telematikID: String? {
        identifier?.first { id in
            Workflow.Key.telematikIdKeys.contains {
                $0.value == id.system?.value?.url.absoluteString
            }
        }?.value?.value?.string
    }
}

public enum Specialty: String, Equatable, Codable {
    /// specialty key for pickup (Handverkauf)
    case pickup = "10"
    /// specialty key for emergency (Nacht- und Notdienst)
    case emergency = "20"
    /// specialty key for delivery (Botendienst)
    case delivery = "30"
    /// specialty key for shipment (Versand)
    case shipment = "40"
    /// specialty key for sterilization (Sterilherstellung)
    case sterilization = "50"

    var pharmacyType: PharmacyLocation.PharmacyType? {
        switch self {
        case .pickup: return .outpharm
        case .emergency: return .emergency
        case .delivery: return .delivery
        case .shipment: return .mobl
        // no pharmacy type defined
        case .sterilization: return nil
        }
    }
}
