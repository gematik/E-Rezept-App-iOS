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
@testable import FHIRVZD
import Foundation
import ModelsR4
import Nimble
import OpenSSL
import Testing

@MainActor
struct HealthcareServiceBundleTests {
    @Test
    func parseHealthcareServiceFhirBundle() throws {
        let fhirVZDExampleFhirBundle = try bundle(for: "exampleHealthcareServiceSearchResponse.json")

        guard let parsedLocation = try fhirVZDExampleFhirBundle.parsePharmacyLocations().first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        expect(parsedLocation.id) == "7025fc46-9809-4ee0-abb9-9e248798e5eb"
        expect(parsedLocation.telematikID) == "3-17.2.1024109000.518"
        expect(parsedLocation.name) == "Apotheke im real,-"
        expect(parsedLocation.types) == [.outpharm, .delivery]
        // Address
        expect(parsedLocation.address?.street).to(equal("Gütersloher Str. 122"))
        expect(parsedLocation.address?.houseNumber).to(beNil())
        expect(parsedLocation.address?.zip).to(equal("33649"))
        expect(parsedLocation.address?.city).to(equal("Bielefeld"))
        // Telecom
        expect(parsedLocation.telecom?.phone).to(equal("0521 4002430"))
        expect(parsedLocation.telecom?.fax).to(equal("0521 13 62 525"))
        expect(parsedLocation.telecom?.email).to(equal("info@apoimbrock.de"))
        expect(parsedLocation.telecom?.web).to(equal("http://www.gesundheit-brackwede.de"))
        // Position
        expect(parsedLocation.position?.latitude?.doubleValue).to(beCloseTo(51.987705, within: 0.000001))
        expect(parsedLocation.position?.longitude?.doubleValue).to(beCloseTo(8.485683, within: 0.000001))
        // Open hours
        expect(parsedLocation.hoursOfOperation.first?.daysOfWeek).to(contain("mon"))
        expect(parsedLocation.hoursOfOperation.first?.openingTime).to(equal("08:00:00"))
        expect(parsedLocation.hoursOfOperation.first?.closingTime).to(equal("20:00:00"))
    }

    @Test
    func parse5HealthcareServiceFhirBundle() throws {
        let healthcareServiceFhirBundle = try bundle(for: "example5HealthcareServiceSearchResponse.json")

        let parsedPharmacyLocations = try healthcareServiceFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 5

        let expectedPharmacyIDs = [
            "7025fc46-9809-4ee0-abb9-9e248798e5eb",
            "c5706315-9cac-4f04-b5c5-6e9369b8dfad",
            "93336e26-497c-4c83-ac9a-a25a5ad238dd",
            "a301b8a9-3dbc-4668-af51-23d0c9a3c87b",
            "2f4f38fb-faff-4670-a7d5-5141c692ef4b",
        ]

        let ids = parsedPharmacyLocations.map(\.id)
        expect(ids) == expectedPharmacyIDs
    }

    @Test
    func parseEmergenyPharmaciesFhirBundle() throws {
        let healthcareServiceFhirBundle = try bundle(for: "exampleHealthcareServiceWithEmergency.json")

        let parsedPharmacyLocations = try healthcareServiceFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 1
        expect(parsedPharmacyLocations.first?.id) == "7025fc46-9809-4ee0-abb9-9e248798e5eb"
        expect(parsedPharmacyLocations.first?.types) == [.mobl, .emergency]
    }

    // MARK: - Specialities Tests

    @Test
    func parseSpecialitiesFromBothCodeSystems() throws {
        let healthcareServiceFhirBundle = try bundle(for: "exampleHealthcareServiceWithSpecialities.json")

        let parsedPharmacyLocations = try healthcareServiceFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 1
        guard let parsedLocation = parsedPharmacyLocations.first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        expect(parsedLocation.id) == "specialities-test-id"
        expect(parsedLocation.telematikID) == "3-TEST-SPECIALITIES-001"

        // Should contain specialities from both code systems, deduplicated
        // PharmacyHealthcareSpecialtyCS codes 10, 30 are skipped (handled by PharmacyType)
        // HealthcareServiceSpecialtyCS: "impfung" (vaccination), "koerperwerte" (bodyMeasurements)
        // Duplicates of "impfung" should be removed
        let expectedSpecialities: [PharmacyLocation.Speciality] = [
            .vaccination, // "impfung"
            .bodyMeasurements, // "koerperwerte"
        ]
        expect(parsedLocation.specialities.count) == 2
        expect(parsedLocation.specialities).to(contain(expectedSpecialities))
    }

    @Test
    func parseSpecialitiesDeduplication() throws {
        let healthcareServiceFhirBundle = try bundle(for: "exampleHealthcareServiceWithSpecialities.json")

        guard let parsedLocation = try healthcareServiceFhirBundle.parsePharmacyLocations().first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        // The fixture has duplicate entries for "impfung"
        // Verify that deduplication works correctly
        let countVaccination = parsedLocation.specialities
            .filter { $0 == .vaccination }.count

        expect(countVaccination) == 1
    }

    @Test
    func parseSpecialitiesFromExistingFixture() throws {
        // Test with existing fixture that only has PharmacyHealthcareSpecialtyCS
        let fhirVZDExampleFhirBundle = try bundle(for: "exampleHealthcareServiceSearchResponse.json")

        guard let parsedLocation = try fhirVZDExampleFhirBundle.parsePharmacyLocations().first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        // Existing fixture has: "50", "10", "30", "10" (duplicate)
        // Codes 10, 30 are skipped (handled by PharmacyType)
        // Expected: sterileCompounding only
        expect(parsedLocation.specialities.count) == 1
        expect(parsedLocation.specialities).to(contain([
            .sterileCompounding, // "50"
        ]))
    }

    // MARK: - Physical Features Tests

    @Test
    func parsePhysicalFeaturesFromCharacteristic() throws {
        let healthcareServiceFhirBundle = try bundle(
            for: "exampleHealthcareServiceWithPhysicalFeatures.json"
        )

        let parsedPharmacyLocations = try healthcareServiceFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 2

        // First pharmacy: 3 physical features (parking, publicTransport, barrierFree)
        guard let firstPharmacy = parsedPharmacyLocations.first else {
            fail("Could not parse first pharmacy.")
            return
        }
        expect(firstPharmacy.id) == "2f4f38fb-faff-4670-a7d5-5141c692ef4b"
        expect(firstPharmacy.physicalFeatures.count) == 3
        expect(firstPharmacy.physicalFeatures).to(contain([
            .parking,
            .publicTransport,
            .barrierFree,
        ]))
        expect(firstPharmacy.physicalFeatures).toNot(contain(.pickupAutomat))

        // Second pharmacy: all 4 physical features
        let secondPharmacy = parsedPharmacyLocations[1]
        expect(secondPharmacy.id) == "956a321b-840d-4ed6-bf60-a0f75ac485f5"
        expect(secondPharmacy.physicalFeatures.count) == 4
        expect(secondPharmacy.physicalFeatures).to(contain([
            .parking,
            .publicTransport,
            .barrierFree,
            .pickupAutomat,
        ]))
    }

    @Test
    func parsePhysicalFeaturesEmptyWhenNoCharacteristic() throws {
        // Existing fixture has no characteristic field
        let fhirVZDExampleFhirBundle = try bundle(for: "exampleHealthcareServiceSearchResponse.json")

        guard let parsedLocation = try fhirVZDExampleFhirBundle.parsePharmacyLocations().first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        expect(parsedLocation.physicalFeatures).to(beEmpty())
    }

    @Test
    func parsePhysicalFeaturesAlongsideSpecialities() throws {
        let healthcareServiceFhirBundle = try bundle(
            for: "exampleHealthcareServiceWithPhysicalFeatures.json"
        )

        let parsedPharmacyLocations = try healthcareServiceFhirBundle.parsePharmacyLocations()

        // Second pharmacy has both specialities and physical features
        let secondPharmacy = parsedPharmacyLocations[1]

        // Verify specialities are parsed correctly alongside physical features
        // Codes 10, 30 are skipped (handled by PharmacyType)
        expect(secondPharmacy.specialities.count) == 3
        expect(secondPharmacy.specialities).to(contain([
            .hypertension, // "60"
            .inhalationTechnique, // "70"
            .polymedication, // "80"
        ]))

        // Verify physical features are also present
        expect(secondPharmacy.physicalFeatures.count) == 4
    }

    private func bundle(for source: String) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/FHIRVZDExampleData", for: source)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
