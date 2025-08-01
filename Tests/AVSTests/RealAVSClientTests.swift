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

@testable import AVS
import Combine
import HTTPClient
import HTTPClientLive
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
import XCTest

final class RealAVSClientTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    let avsURLString = "https://beispielurlversand.de/"

    func testSend() async throws {
        // given
        var counter = 0
        let endPoint = AVSEndpoint(url: URL(string: avsURLString)!)
        stub(
            condition:
            isAbsoluteURLString(avsURLString)
                && isMethodPOST()
                && hasHeaderNamed("Content-Type", value: "application/pkcs7-mime")
        ) { _ in
            counter += 1
            return fixture(filePath: "", headers: nil)
        }

        // when
        let sut = RealAVSClient(
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // then
        let httpResponse = try await sut.send(data: Data(), to: endPoint)
        expect(httpResponse.status) == .ok
        expect(counter) == 1
    }

    func testSend_returnBadAccess() async throws {
        // given
        var counter = 0
        let status = 400
        let endPoint = AVSEndpoint(url: URL(string: avsURLString)!)
        stub(
            condition:
            isAbsoluteURLString(avsURLString)
                && isMethodPOST()
        ) { _ in
            counter += 1
            return fixture(filePath: "", status: Int32(status), headers: nil)
        }

        // when
        let sut = RealAVSClient(
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // then
        let httpResponse = try await sut.send(data: Data(), to: endPoint)
        expect(httpResponse.status) == .badRequest
        expect(counter) == 1
    }
}
