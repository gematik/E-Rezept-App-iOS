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

import CodedError
import eRpKit
import Foundation
import ModelsR4
import OpenSSL

@CodedError("610")
public enum HealthcareServiceBundleParsingError: Swift.Error {
    @ErrorCode("01")
    case parseError(String)
}

extension ModelsR4.Bundle {
    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    public func parsePharmacyLocations() throws -> [PharmacyLocation] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let healthcareService = $0.resource?.get(if: ModelsR4.HealthcareService.self) else {
                return nil
            }
            return try Self.parse(healthcareService: healthcareService, bundle: self)
        } ?? []
    }

    /// Parse and extract a single `PharmacyLocation` from the given `HealthcareService` and `Bundle`
    ///
    /// - Parameters:
    ///   - healthcareService: The `HealthcareService` resource to extract pharmacy location data from
    ///   - bundle: The `Bundle` containing related resources (e.g., Locations, Organizations)
    /// - Returns: A `PharmacyLocation`
    /// - Throws: `ModelsR4.Bundle.Error`
    public static func parse(
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

        let physicalFeatures = healthcareService.physicalFeatures

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
            hoursOfOperation: healthcareService.hoursOfOperations,
            physicalFeatures: physicalFeatures,
            specialities: healthcareService.specialities,
            specialClosingHours: healthcareService.specialClosing,
            emergencyServiceHours: healthcareService.specialOpening
        )
    }

    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    public func parseTelematikId() throws -> Insurance? {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let healthcareService = $0.resource?.get(if: ModelsR4.HealthcareService.self) else {
                return nil
            }
            return try Self.parseString(healthcareService: healthcareService, bundle: self)
        }.first
    }

    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    public func parseInsurance() throws -> [Insurance] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let healthcareService = $0.resource?.get(if: ModelsR4.HealthcareService.self) else {
                return nil
            }
            return try Self.parseString(healthcareService: healthcareService, bundle: self)
        } ?? []
    }

    /// Parse and extract an `Insurance` object from the given `HealthcareService` and `Bundle`
    ///
    /// - Parameters:
    ///   - healthcareService: The `HealthcareService` resource to extract insurance-related data from
    ///   - bundle: The `Bundle` containing related resources
    /// - Returns: An optional `Insurance`
    /// - Throws: `ModelsR4.Bundle.Error`
    public static func parseString(
        healthcareService: ModelsR4.HealthcareService,
        bundle: ModelsR4.Bundle
    ) throws -> Insurance? {
        guard (healthcareService.id?.value?.string) != nil else {
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

        return Insurance(name: organization.name?.value?.string,
                         telematikId: telematikID)
    }

    /// Parse and extract all found Pharmacy Locations from `Self`
    ///
    /// - Returns: Array with all found and parsed pharmacies
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseCountry() throws -> [Country] {
        // Collect and parse all Pharmacy Locations
        try entry?.compactMap {
            guard let healthcareService = $0.resource?.get(if: ModelsR4.HealthcareService.self) else {
                return nil
            }
            return try Self.parseCountry(healthcareService: healthcareService, bundle: self)
        } ?? []
    }

    static func parseCountry(
        healthcareService: ModelsR4.HealthcareService,
        bundle: ModelsR4.Bundle
    ) throws -> Country? {
        guard let id = healthcareService.id?.value?.string else {
            throw HealthcareServiceBundleParsingError.parseError("Could not parse id from healthcare service.")
        }

        guard let organizationReference = healthcareService.providedBy?.reference,
              let organization = bundle.findResource(with: organizationReference, type: ModelsR4.Organization.self)
        else {
            throw HealthcareServiceBundleParsingError
                .parseError("Could not parse organization from healthcare service.")
        }

        guard let valueX = organization.extensions(for: FHIRDirectory.Key.country).first?.value,
              case let Extension.ValueX.coding(value) = valueX
        else {
            throw HealthcareServiceBundleParsingError
                .parseError("Could not parse country code from organization extension.")
        }
        let countryCode = value.code?.value?.string

        guard let countryName = organization.name?.value?.string else {
            throw HealthcareServiceBundleParsingError.parseError("Could not parse countryName from organization.")
        }

        guard let telematikID = organization.telematikID else {
            throw HealthcareServiceBundleParsingError.parseError("Could not parse telematikID from organization.")
        }

        return Country(id: id, countryCode: countryCode, name: countryName, telematikId: telematikID)
    }

    /// Find and return a FHIR `Resource` of the specified type with the given identifier
    ///
    /// - Parameters:
    ///   - identifier: The FHIR identifier used to locate the resource
    ///   - type: The specific `Resource` type to search for
    /// - Returns: A resource of the specified type if found; otherwise, `nil`
    public func findResource<Resource: ModelsR4.Resource>(
        with identifier: FHIRPrimitive<FHIRString>,
        type _: Resource.Type
    ) -> Resource? {
        let newIdentifier = identifier.droppingLeadingNumberSign

        // try finding the resource by fullUrl
        if let bundle = entry?.lazy.first(where: { bundleEntry in
            guard let resourceIdentifier = newIdentifier.value?.string else { return false }
            if let urlString = bundleEntry.fullUrl?.value?.url.absoluteString {
                return urlString.contains(resourceIdentifier)
            }
            if let resourceType = bundleEntry.resource?.resourceType,
               let resource = bundleEntry.resource?.get(if: Resource.self),
               let id = resource.id?.value?.string {
                return "\(resourceType)/\(id)".contains(resourceIdentifier)
            }
            return false
        })?
            .resource?
            .get(if: Resource.self) {
            return bundle
        }
        return nil
    }

    /// Parse and extract all found avs certificates from `self`
    ///
    /// - Returns: Array with all found and parsed certificates
    /// - Throws: `ModelsR4.Bundle.Error`
    public func parseCertificates() throws -> [X509] {
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

    var specialClosing: [PharmacyLocation.SpecialOperationHours] {
        var hours: [PharmacyLocation.SpecialOperationHours] = []
        notAvailable?.forEach { noTime in
            let pharmacyNa = PharmacyLocation.SpecialOperationHours(
                reason: noTime.description_fhir.value?.description,
                startDate: noTime.during?.start?.value?.description.replacingOccurrences(of: "Z", with: "+00:00"),
                endDate: noTime.during?.end?.value?.description.replacingOccurrences(of: "Z", with: "+00:00")
            )
            hours.append(pharmacyNa)
        }
        return hours
    }

    var specialOpening: [PharmacyLocation.SpecialOperationHours] {
        var hours: [PharmacyLocation.SpecialOperationHours] = []
        availableTime?.forEach { availableTime in
            for ext in availableTime.extensions(for: FHIRDirectory.Key.specialOpeningTimes) {
                ext.extension?.forEach { specialClosing in
                    if case let .period(period) = specialClosing.value {
                        let pharmacyEm = PharmacyLocation.SpecialOperationHours(
                            startDate: period.start?.value?.description.replacingOccurrences(
                                of: "Z",
                                with: "+00:00"
                            ),
                            endDate: period.end?.value?.description.replacingOccurrences(of: "Z", with: "+00:00")
                        )
                        hours.append(pharmacyEm)
                    }
                }
            }
        }
        return hours
    }

    var pharmacyTypes: [PharmacyLocation.PharmacyType] {
        guard let specialty else {
            return []
        }
        let allSpecialities = specialty.flatMap {
            $0
                .coding?
                .filter { coding in
                    coding.system?.value?.url.absoluteString == FHIRDirectory.Key.CodeSystem.pharmacyHealthcareSpecialty
                } ?? []
        }
        .compactMap { coding -> PharmacyLocation.PharmacyType? in
            guard let rawValue = coding.code?.value?.string
            else { return nil }
            return Specialty(rawValue: rawValue)?.pharmacyType
        }
        return allSpecialities.reduce(into: []) { partialResult, specialty in
            if !partialResult.contains(specialty) {
                partialResult.append(specialty)
            }
        }
    }

    var specialities: [PharmacyLocation.Speciality] {
        guard let specialty else {
            return []
        }
        let allSpecialities = specialty.flatMap {
            $0
                .coding?
                .filter { coding in
                    let system = coding.system?.value?.url.absoluteString
                    return system == FHIRDirectory.Key.CodeSystem.pharmacyHealthcareSpecialty ||
                        system == FHIRDirectory.Key.CodeSystem.healthcareServiceSpecialty
                } ?? []
        }
        .compactMap { coding -> PharmacyLocation.Speciality? in
            guard let rawValue = coding.code?.value?.string
            else { return nil }
            return PharmacyLocation.Speciality(rawValue: rawValue)
        }
        return allSpecialities.reduce(into: []) { partialResult, speciality in
            if !partialResult.contains(speciality) {
                partialResult.append(speciality)
            }
        }
    }

    var physicalFeatures: [PharmacyLocation.PhysicalFeature] {
        guard let characteristic else {
            return []
        }
        let allFeatures = characteristic.flatMap {
            $0
                .coding?
                .filter { coding in
                    coding.system?.value?.url.absoluteString == FHIRDirectory.Key.CodeSystem.physicalFeatures
                } ?? []
        }
        .compactMap { coding -> PharmacyLocation.PhysicalFeature? in
            guard let rawValue = coding.code?.value?.string
            else { return nil }
            return PharmacyLocation.PhysicalFeature(rawValue: rawValue)
        }
        return allFeatures.reduce(into: []) { partialResult, feature in
            if !partialResult.contains(feature) {
                partialResult.append(feature)
            }
        }
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

extension ModelsR4.DateTime {
    func dateTimeToDate() throws -> Date? {
        guard
            let monthUInt = date.month, let month = Int(exactly: monthUInt),
            let dayUInt = date.day, let day = Int(exactly: dayUInt),
            let hourUInt = time?.hour, let hour = Int(exactly: hourUInt),
            let minuteUInt = time?.minute, let minute = Int(exactly: minuteUInt)
        else {
            return nil
        }

        return DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: timeZone,
            year: date.year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ).date
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
