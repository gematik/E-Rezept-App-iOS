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
import HTTPClient
import HTTPClientLive
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
    let pkiCertificatesURL = URL(string: "http://vau.gematik/PKICertificates")!
    let vauCertURL = URL(string: "http://vau.gematik/VAUCertificate")!
    let ocspResponseURL = URL(string: "http://vau.gematik/OCSPResponse")!

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
        let sut = RealTrustStoreClient(
            serverURL: serviceURL,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // then
        sut.loadCertListFromServer()
            .test(expectations: { certList in
                expect(certList.caCerts.count) == 1
                expect(certList.eeCerts.count) == 2
            })
        expect(counter) == 1
    }

    func testLoadPKICertificates() async throws {
        // given
        var counter = 0
        let json = """
        {
            "add_roots": ["YWRkX3Jvb3RzXzE="],
            "ca_certs": ["Y2FfY2VydF9zXzE=", "Y2FfY2VydF9zXzI="]
        }
        """
        stub(
            condition: isAbsoluteURLString(pkiCertificatesURL.absoluteString + "?currentRoot=GEM.RCA3")
                && isMethodGET()
        ) { _ in
            counter += 1
            return HTTPStubsResponse(data: Data(json.data(using: .utf8)!), statusCode: 200, headers: nil)
        }

        let sut = RealTrustStoreClient(
            serverURL: serviceURL,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // when
        let pkiCertificates = try await sut.loadPKICertificatesFromServer(rootSubjectCn: "GEM.RCA3")

        // then
        expect(counter) == 1
        expect(pkiCertificates.addRoots.count) == 1
        expect(pkiCertificates.caCerts.count) == 2
    }

    func testLoadVauCertificate() async throws {
        // given
        var counter = 0
        stub(condition: isAbsoluteURLString(vauCertURL.absoluteString) && isMethodGET()) { _ in
            counter += 1
            return HTTPStubsResponse(data: Data([0x0]), statusCode: 200, headers: nil)
        }

        let sut = RealTrustStoreClient(
            serverURL: serviceURL,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // when
        let vauCertificate = try await sut.loadVauCertificateFromServer()

        // then
        expect(counter) == 1
        expect(vauCertificate) == Data([0x0])
    }

    func testLoadOcspResponse() async throws {
        // given
        var counter = 0
        stub(
            condition: isAbsoluteURLString(ocspResponseURL.absoluteString + "?issuer-cn=abcd&serial-nr=9313")
                && isMethodGET()
        ) { _ in
            counter += 1
            return HTTPStubsResponse(data: Data([0x1]), statusCode: 200, headers: nil)
        }

        let sut = RealTrustStoreClient(
            serverURL: serviceURL,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
        )

        // when
        let vauCertificate = try await sut.loadOcspResponseFromServer(issuerCn: "abcd", serialNr: "9313")

        // then
        expect(counter) == 1
        expect(vauCertificate) == Data([0x1])
    }
}
