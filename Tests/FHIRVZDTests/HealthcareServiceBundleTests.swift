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

@Suite
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

    private func bundle(for source: String) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/FHIRVZDExampleData", for: source)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
