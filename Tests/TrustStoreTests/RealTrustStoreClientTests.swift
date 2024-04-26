//
//  Copyright (c) 2024 gematik GmbH
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
import HTTPClient
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
@testable import TrustStore
import XCTest

final class RealTrustStoreClientTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    let serviceURL = URL(string: "http://vau.gematik")!
    let certListURL = URL(string: "http://vau.gematik/CertList")!

    var certListPath: String {
        guard let certListPath = Bundle.module
            .path(forResource: "kompca10-vauref-idpsig3", ofType: "json", inDirectory: "Resources/CertList.bundle")
        else {
            fatalError("Could not load  discovery document")
        }
        return certListPath
    }

    func testLoadCertList() throws {
        // given
        var counter = 0
        stub(condition: isAbsoluteURLString(certListURL.absoluteString) && isMethodGET()) { _ in
            counter += 1
            return fixture(filePath: self.certListPath, headers: nil)
        }

        // when
        let sut = RealTrustStoreClient(serverURL: serviceURL)

        // then
        sut.loadCertListFromServer()
            .test(expectations: { certList in
                expect(certList.caCerts.count) == 1
                expect(certList.eeCerts.count) == 2
            })
        expect(counter) == 1
    }
}
