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

import Combine
import eRpKit
import FHIRClient
@testable import FHIRVZD
import Foundation
import ModelsR4
import Nimble
import OpenSSL
import Pharmacy
import Testing

@Suite
struct HealthcareServiceFHIRDataSourceTests {
    @Test
    func searchPharmaciesTest() async throws {
        let mockFhirClient = MockHealthcareServiceFHIRClient()

        var calledCount = 0
        mockFhirClient.searchPharmaciesCallback = { _, _, _, _ in
            calledCount += 1

            let result: [PharmacyLocation]

            if calledCount == 1 {
                result = [PharmacyLocation.Fixtures.hundredPharmacies.first!]
            } else {
                result = PharmacyLocation.Fixtures.hundredPharmacies
            }
            return Just(result)
                .setFailureType(to: FHIRClient.Error.self)
                .eraseToAnyPublisher()
        }

        let mockSession = MockFHIRVZDSession()
        let sut = HealthcareServiceFHIRDataSource(fhirClient: mockFhirClient, session: mockSession)

        let publisher = sut.searchPharmacies(
            by: "test",
            position: nil,
            filter: [PharmacyRemoteDataStoreFilter(key: "abc", value: "def")]
        )

        for try await value in publisher.values {
            #expect(value.count == 1)
            #expect(value.first == PharmacyLocation.Fixtures.hundredPharmacies.first)
        }

        #expect(calledCount == 1)
    }

    @Test
    func searchPharmaciesWithLocationIsSearchingForMoreTest() async throws {
        let mockFhirClient = MockHealthcareServiceFHIRClient()

        var calledCount = 0
        mockFhirClient.searchPharmaciesCallback = { _, _, _, _ in
            calledCount += 1

            let result: [PharmacyLocation]

            if calledCount == 1 {
                result = [PharmacyLocation.Fixtures.hundredPharmacies.first!]
            } else {
                result = PharmacyLocation.Fixtures.hundredPharmacies
            }
            return Just(result)
                .setFailureType(to: FHIRClient.Error.self)
                .eraseToAnyPublisher()
        }

        let mockSession = MockFHIRVZDSession()
        let sut = HealthcareServiceFHIRDataSource(fhirClient: mockFhirClient, session: mockSession)

        let publisher = sut.searchPharmacies(
            by: "test",
            position: .init(lat: 1.0, lon: 1.0),
            filter: [PharmacyRemoteDataStoreFilter(key: "abc", value: "def")]
        )

        for try await value in publisher.values {
            #expect(value.count == 1)
            #expect(value.first == PharmacyLocation.Fixtures.hundredPharmacies.first)
        }

        #expect(calledCount == 2)
    }

    @Test
    func searchPharmaciesWithLocationIsNotSearchingForMoreIfMoreThan50ResultsTest() async throws {
        let mockFhirClient = MockHealthcareServiceFHIRClient()

        var calledCount = 0
        mockFhirClient.searchPharmaciesCallback = { _, _, _, _ in
            calledCount += 1

            let result: [PharmacyLocation]

            if calledCount == 1 {
                result = PharmacyLocation.Fixtures.fiftyOnePharmacies
            } else {
                result = PharmacyLocation.Fixtures.hundredPharmacies
            }
            return Just(result)
                .setFailureType(to: FHIRClient.Error.self)
                .eraseToAnyPublisher()
        }

        let mockSession = MockFHIRVZDSession()
        let sut = HealthcareServiceFHIRDataSource(fhirClient: mockFhirClient, session: mockSession)

        let publisher = sut.searchPharmacies(
            by: "test",
            position: .init(lat: 1.0, lon: 1.0),
            filter: [PharmacyRemoteDataStoreFilter(key: "abc", value: "def")]
        )

        for try await value in publisher.values {
            #expect(value.count == 51)
            #expect(value == PharmacyLocation.Fixtures.fiftyOnePharmacies)
        }

        #expect(calledCount == 1)
    }
}

extension PharmacyLocation {
    enum Fixtures {
        static let hundredPharmacies: [PharmacyLocation] = {
            (0 ..< 100).map {
                PharmacyLocation(
                    id: "\($0 + 101)",
                    status: .active,
                    telematikID: "3-06.2.ycl.\($0 + 101)",
                    name: "Apotheke am Wäldchen \($0 + 101)",
                    types: [.pharm, .emergency, .mobl, .outpharm, .delivery],
                    position: Position(latitude: 49.2470345, longitude: 8.8668786),
                    address: PharmacyLocation.Address(
                        street: "Hinter der Bahn",
                        houseNumber: "\($0 + 101)",
                        zip: "12\($0 + 101)",
                        city: "Buxtehude"
                    ),
                    telecom: PharmacyLocation.Telecom(
                        phone: "555-\($0 + 101)",
                        fax: "555-123456",
                        email: "info@gematik.de",
                        web: "http://www.gematik.de"
                    ),
                    hoursOfOperation: [
                        PharmacyLocation.HoursOfOperation(
                            daysOfWeek: ["tue", "wed"],
                            openingTime: "08:00:00",
                            closingTime: "18:00:00"
                        ),
                    ]
                )
            }
        }()

        static let fiftyOnePharmacies: [PharmacyLocation] = {
            (0 ..< 51).map {
                PharmacyLocation(
                    id: "\($0 + 201)",
                    status: .active,
                    telematikID: "3-06.2.ycl.\($0 + 201)",
                    name: "Apotheke am Wäldchen \($0 + 201)",
                    types: [.pharm, .emergency, .mobl, .outpharm, .delivery],
                    position: Position(latitude: 49.2470345, longitude: 8.8668786),
                    address: PharmacyLocation.Address(
                        street: "Hinter der Bahn",
                        houseNumber: "\($0 + 201)",
                        zip: "12\($0 + 201)",
                        city: "Buxtehude"
                    ),
                    telecom: PharmacyLocation.Telecom(
                        phone: "555-\($0 + 201)",
                        fax: "555-123456",
                        email: "info@gematik.de",
                        web: "http://www.gematik.de"
                    ),
                    hoursOfOperation: [
                        PharmacyLocation.HoursOfOperation(
                            daysOfWeek: ["tue", "wed"],
                            openingTime: "08:00:00",
                            closingTime: "18:00:00"
                        ),
                    ]
                )
            }
        }()
    }
}
