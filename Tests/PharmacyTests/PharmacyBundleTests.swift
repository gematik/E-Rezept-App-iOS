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

import BundleKit
import Foundation
import ModelsR4
import Nimble
@testable import Pharmacy
import XCTest

final class PharmacyBundleTests: XCTestCase {
    func testParsePharmacyFhirBundle() throws {
        let pharmacyExampleFhirBundle = try bundle(for: "examplePharmaciesSearchResponse.json")

        guard let parsedLocation = try pharmacyExampleFhirBundle.parsePharmacyLocations().first else {
            fail("Could not parse ModelsR4.Bundle into Pharmacy.")
            return
        }

        expect(parsedLocation.id) == "c1d8fb25-795c-4b28-8aa7-d2b1e15d886c"
        expect(parsedLocation.telematikID) == "3-10.2.0110216300.940"
        expect(parsedLocation.name) == "APOTHEKE IM HANDELSHOF"
        // Address
        expect(parsedLocation.address?.street).to(equal("Duisburgerstraße 225"))
        expect(parsedLocation.address?.houseNumber).to(beNil())
        expect(parsedLocation.address?.zip).to(equal("47166"))
        expect(parsedLocation.address?.city).to(equal("Duisburg"))
        // Telecom
        expect(parsedLocation.telecom?.phone).to(equal("0203547781"))
        expect(parsedLocation.telecom?.fax).to(equal("020372895032"))
        expect(parsedLocation.telecom?.email).to(equal("verwaltung@apotheke-im-handelshof.net"))
        expect(parsedLocation.telecom?.web).to(equal("https://apotheke-im-handelshof.net/"))
        // Position
        expect(parsedLocation.position?.latitude).to(equal(51.493926))
        expect(parsedLocation.position?.longitude).to(equal(6.772768))
        // Open hours
        expect(parsedLocation.hoursOfOperation.first?.daysOfWeek).to(contain("mon"))
        expect(parsedLocation.hoursOfOperation.first?.openingTime).to(equal("08:00:00"))
        expect(parsedLocation.hoursOfOperation.first?.closingTime).to(equal("18:30:00"))
    }

    func testParse5PharmaciesFhirBundle() throws {
        let pharmacyExampleFhirBundle = try bundle(for: "example5PharmaciesSearchResponse.json")

        let parsedPharmacyLocations = try pharmacyExampleFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 5

        let expectedPharmacyIDs = [
            "a4d2a2ca-8b79-4792-a2be-3b72e1ccdedb",
            "55c5744f-49ad-4e43-92c2-cda9bc478b74",
            "32dd222f-6781-4f80-8802-7ed0335a3116",
            "8dc63705-d337-4dc3-ac97-cc5d5047654c",
            "934524a5-850c-4f61-bd9f-3d2c7798074b",
        ]

        let ids = parsedPharmacyLocations.map(\.id)
        expect(ids) == expectedPharmacyIDs
    }

    func testParseEmergenyPharmaciesFhirBundle() throws {
        let pharmacyExampleFhirBundle = try bundle(for: "examplePharmacyWithEmergency.json")

        let parsedPharmacyLocations = try pharmacyExampleFhirBundle.parsePharmacyLocations()

        expect(parsedPharmacyLocations.count) == 1

        let expectedPharmacyIDs = [
            "4b74c2b2-2275-4153-a94d-3ddc6bfb1362",
        ]

        let ids = parsedPharmacyLocations.map(\.id)
        expect(ids) == expectedPharmacyIDs

        let expectedTypes = [PharmacyLocation.PharmacyType.mobl,
                             PharmacyLocation.PharmacyType.emergency]
        let pharmacyTypes = parsedPharmacyLocations.flatMap(\.types)
        expect(pharmacyTypes) == expectedTypes
    }

    private func bundle(for source: String) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .bundleFromResources(name: "FHIRPharmaciesExampleData.bundle")
            .decode(ModelsR4.Bundle.self, from: source)
    }
}
