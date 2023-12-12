//
//  Copyright (c) 2023 gematik GmbH
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

@testable import AVS
import Combine
import HTTPClient
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

    func testSend() {
        // given
        var counter = 0
        let endPoint = AVSEndpoint(url: URL(string: avsURLString)!)
        stub(
            condition: isAbsoluteURLString(avsURLString)
                && isMethodPOST()
                && hasHeaderNamed("Content-Type", value: "application/pkcs7-mime")
        ) { _ in
            counter += 1
            return fixture(filePath: "", headers: nil)
        }

        // when
        let sut = RealAVSClient()

        // then
        await sut.send(data: Data(), to: endPoint)
            .test(
                expectations: { httpResponse in
                    expect(httpResponse.status) == .ok
                }
            )
        expect(counter) == 1
    }

    func testSend_returnBadAccess() {
        // given
        var counter = 0
        let status = 400
        let endPoint = AVSEndpoint(url: URL(string: avsURLString)!)
        stub(condition: isAbsoluteURLString(avsURLString) && isMethodPOST()) { _ in
            counter += 1
            return fixture(filePath: "", status: Int32(status), headers: nil)
        }

        // when
        let sut = RealAVSClient()

        // then
        await sut.send(data: Data(), to: endPoint)
            .test(
                failure: { error in
                    expect(error) == .network(error: HTTPError.httpError(URLError(.init(rawValue: status))))
                },
                expectations: { _ in
                }
            )
        expect(counter) == 1
    }
}
