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
@testable import FHIRClient
import Foundation
import HTTPClient
import ModelsR4
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
import XCTest

final class FHIRClientTests: XCTestCase {
    var host: String!
    var service: URL!
    var fhirClient: FHIRClient!
    var sut: FHIRClient!

    override func setUpWithError() throws {
        try super.setUpWithError()

        host = "some-fhir-service.com"
        service = URL(string: "http://\(host ?? "")")!
        fhirClient = FHIRClient(server: service, httpClient: DefaultHTTPClient(urlSessionConfiguration: .default))
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

    func testFHIRClientWithHTTPError() {
        let mockOperation = MockFHIRClientOperation(relativeUrlString: "/path/to/operation")
        let expectedError = URLError(.notConnectedToInternet)
        var counter = 0
        stub(condition: isHost(host)
            && isPath(mockOperation.relativeUrlString!)
            && isMethodGET()
            && hasHeaderNamed(mockOperation.httpHeaders.first!.key,
                              value: mockOperation.httpHeaders.first!.value)) { _ in
                counter += 1
                let response = HTTPStubsResponse(error: expectedError)
                return response
        }

        sut.execute(operation: mockOperation)
            .test(failure: { error in
                expect(counter) == 1
                expect(mockOperation.handleResponse_Called).to(beFalse())
                expect(error) == FHIRClient.Error
                    .http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil))
            }, expectations: { _ in
                fail()
            })
    }

    func testFHIRClientWithInternalError() {
        let mockOperation = MockFHIRClientOperation(relativeUrlString: "")
        let expectedError = FHIRClient.Error.internalError("Operation endpoint url could not be constructed")

        sut.execute(operation: mockOperation)
            .test(failure: { error in
                expect(mockOperation.handleResponse_Called).to(beFalse())
                expect(error) == expectedError
            }, expectations: { _ in
                fail()
            })
    }

    func testFHIRClientWithSuccess() {
        let mockOperation = MockFHIRClientOperation(relativeUrlString: "/path/to/operation")
        let url = resourceUrl(for: "emptyResponse", type: "json")
        var counter = 0

        stub(condition: isHost(host)
            && isPath(mockOperation.relativeUrlString!)
            && isMethodGET()
            && hasHeaderNamed(mockOperation.httpHeaders.first!.key,
                              value: mockOperation.httpHeaders.first!.value)) { _ in
                counter += 1
                return fixture(filePath: url.path,
                               status: Int32(HTTPStatusCode.ok.rawValue),
                               headers: ["Content-Type": "application/json"])
        }

        sut.execute(operation: mockOperation)
            .test(failure: { _ in
                fail()
            }, expectations: { response in
                expect(counter) == 1
                expect(mockOperation.handleResponse_Called).to(beTrue())
                expect(response) == mockOperation.handleResponse_Response
            })
    }

    func testFHIRClientWithOperationOutcomeResponse() {
        let mockOperation = MockFHIRClientOperation(relativeUrlString: "/path/to/operation")
        let url = resourceUrl(for: "errorFHIRResponse", type: "json")

        let responseData = try! Data(contentsOf: url)
        let outcome = try! JSONDecoder().decode(ModelsR4.OperationOutcome.self, from: responseData)
        let urlError = URLError(.init(rawValue: HTTPStatusCode.badRequest.rawValue))
        let expectedError = FHIRClient.Error
            .http(.init(httpClientError: .httpError(urlError), operationOutcome: outcome))
        var counter = 0
        stub(condition: isHost(host)
            && isPath(mockOperation.relativeUrlString!)
            && isMethodGET()
            && hasHeaderNamed(mockOperation.httpHeaders.first!.key,
                              value: mockOperation.httpHeaders.first!.value)) { _ in
                counter += 1
                return fixture(filePath: url.path,
                               status: Int32(HTTPStatusCode.badRequest.rawValue),
                               headers: ["Content-Type": "application/json"])
        }

        sut.execute(operation: mockOperation)
            .test(failure: { error in
                expect(counter) == 1
                expect(mockOperation.handleResponse_Called).to(beFalse())
                expect(error.localizedDescription) == expectedError.localizedDescription
            }, expectations: { _ in
                fail()
            })
    }

    private func resourceUrl(for file: String, type: String) -> URL {
        guard let url = Bundle.module
            .path(forResource: file, ofType: type, inDirectory: "Resources/FHIRExampleData.bundle")?
            .asURL
        else {
            fail("Could not decode example file.")
            return URL(fileURLWithPath: "")
        }

        return url
    }
}
