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

@testable import FHIRClient
import Foundation
import HTTPClient

// swiftlint:disable all
class MockFHIRClientOperation: FHIRClientOperation {
    typealias Value = MockFHIRResponseHandler.Value
    var path: String = ""
    var httpHeaders: [String: String] = ["operation_key": "operation_value"]
    var httpMethod = HTTPMethod.get

    init(path: String) {
        self.path = path
    }

    var handleResponse_Response: MockFHIRResponseHandler.Value = "Mocked Response"
    var handleResponse_ReceivedArgument: FHIRClient.Response?
    var handleResponse_CallsCount = 0
    var handleResponse_Called: Bool {
        handleResponse_CallsCount > 0
    }

    func handle(response: FHIRClient.Response) throws -> MockFHIRResponseHandler.Value {
        handleResponse_CallsCount += 1
        handleResponse_ReceivedArgument = response
        return handleResponse_Response
    }
}

class MockFHIRResponseHandler: FHIRResponseHandler {
    typealias Value = String
    var acceptFormat: FHIRAcceptFormat = .fhirJson

    var handle_Response: String = "Respone"
    var handle_ReceivedArgument: FHIRClient.Response?
    var handle_CallsCount = 0
    var handle_Called: Bool {
        handle_CallsCount > 0
    }

    func handle(response: FHIRClient.Response) throws -> String {
        handle_CallsCount += 1
        handle_ReceivedArgument = response
        return handle_Response
    }
}

// swiftlint:disable all
