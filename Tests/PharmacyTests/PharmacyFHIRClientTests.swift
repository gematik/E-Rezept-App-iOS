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

import Combine
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import Pharmacy
import TestUtils
import XCTest

final class PharmacyFHIRClientTests: XCTestCase {
    var host: String!
    var service: URL!
    var sut: FHIRClient!

    override func setUpWithError() throws {
        try super.setUpWithError()

        host = "some-fhir-service.com"
        service = URL(string: "http://\(host ?? "")")!
        sut = FHIRClient(
            server: service,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .default),
            receiveQueue: .immediate
        )
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testFetchPharmacyForIdWithSuccess() {
        let responseResource = path(for: "examplePharmacyFetchForIdResponse")

        var counter = 0
        let telematikId = "3-03.2.1010380000.10.703"
        let parameter = "?identifier=\(telematikId)"
        let path = "/Location"
        stub(condition: isAbsoluteURLString(service.absoluteString + path + parameter)) { _ in
            counter += 1
            return fixture(filePath: responseResource, headers: ["Content-Type": "application/fhir+json"])
        }

        sut.fetchPharmacy(by: telematikId)
            .test(failure: { error in
                fail("Test unexpectedly failed with error: \(error)")
            }, expectations: { pharmacy in
                expect(counter) == 1
                expect(pharmacy?.id).to(equal("29cc8022-ed2d-4313-8d74-74196a2b1168"))
                expect(pharmacy?.telematikID).to(equal("3-03.2.1010380000.10.703"))
            })
    }

    func testFetchPharmacyForIdWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)
        var counter = 0
        let telematikId = "3-03.2.1010380000.10.703"
        let parameter = "?identifier=\(telematikId)"
        let path = "/Location"
        stub(condition: isAbsoluteURLString(service.absoluteString + path + parameter) && isMethodGET()) { _ in
            counter += 1
            return HTTPStubsResponse(error: expectedError)
        }

        sut.fetchPharmacy(by: telematikId)
            .test(failure: { error in
                expect(counter) == 1
                expect(error) == .http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil))
            }, expectations: { _ in
                fail("Test should throw an error")
            })
    }

    func testSearchPharmacyWithSuccess() {
        let responseResource = path(for: "example5PharmaciesSearchResponse")

        var counter = 0
        let searchTerm = "Apo"
        let parameter = "?name=\(searchTerm)"
        let path = "/Location"
        stub(condition: isAbsoluteURLString(service.absoluteString + path + parameter)) { _ in
            counter += 1
            return fixture(filePath: responseResource, headers: ["Content-Type": "application/fhir+json"])
        }

        sut.searchPharmacies(by: searchTerm, position: nil, filter: [])
            .test(failure: { error in
                fail("Test unexpectedly failed with error: \(error)")
            }, expectations: { pharmacyLocations in
                expect(counter) == 1
                expect(pharmacyLocations.count) == 5
                expect(pharmacyLocations.first?.id).to(equal("a4d2a2ca-8b79-4792-a2be-3b72e1ccdedb"))
                expect(pharmacyLocations.first?.telematikID).to(equal("3-06.2.ycl.216"))
            })
    }

    func testSearchPharmacyWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)
        var counter = 0
        let searchTerm = "Apo"
        let parameter = "?name=\(searchTerm)"
        let path = "/Location"
        stub(condition: isAbsoluteURLString(service.absoluteString + path + parameter) && isMethodGET()) { _ in
            counter += 1
            return HTTPStubsResponse(error: expectedError)
        }

        sut.searchPharmacies(by: searchTerm, position: nil, filter: [])
            .test(failure: { error in
                expect(counter) == 1
                expect(error) == .http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil))
            }, expectations: { _ in
                fail("Test should throw an error")
            })
    }

    private func path(for resource: String) -> String {
        guard let path = Bundle.module.path(
            forResource: resource,
            ofType: "json",
            inDirectory: "Resources/FHIRPharmaciesExampleData.bundle"
        ) else {
            fail("Bundle could not find resource \(resource)")
            return ""
        }

        return path
    }
}
