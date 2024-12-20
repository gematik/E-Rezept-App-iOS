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

import Foundation
import Nimble
@testable import TrustStore
import XCTest

final class PKICertificatesTests: XCTestCase {
    func testDecodeValidListJson() throws {
        // given
        guard let url = Bundle.module.url(forResource: "syntactically-valid",
                                          withExtension: "json",
                                          subdirectory: "Resources/CertList.bundle"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }

        // when
        let pkiCertificates = try PKICertificates.from(data: data)
        let pkiCertificatesBase64 = try PKICertificates.Base64.from(data: data)

        // then
        expect(pkiCertificates.addRoots.count) == 0
        expect(pkiCertificates.caCerts.count) == 2

        expect(pkiCertificatesBase64.addRoots.count) == 0
        expect(pkiCertificatesBase64.caCerts.count) == 2
    }

    func testDecodeInvalidListJson() throws {
        // given
        guard let url = Bundle.module
            .url(
                forResource: "invalid-cacerts-missing",
                withExtension: "json",
                subdirectory: "Resources/CertList.bundle"
            ),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }

        // then
        expect(try PKICertificates.from(data: data)).to(throwError(errorType: DecodingError.self))
    }

    func testDecodeAddRootChain() throws {
        // given
        guard let url = Bundle.module.url(
            forResource: "addRoots-chain",
            withExtension: "json",
            subdirectory: "Resources/CertList.bundle"
        ),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }

        // when
        let pkiCertificates = try PKICertificates.from(data: data)
        let pkiCertificatesBase64 = try PKICertificates.Base64.from(data: data)

        // then
        expect(pkiCertificates.addRoots.count) == 2
        expect(pkiCertificates.caCerts.count) == 3

        expect(pkiCertificatesBase64.addRoots.count) == 2
        expect(pkiCertificatesBase64.caCerts.count) == 3
    }

    func testJsonCodable() throws {
        // given
        guard let url = Bundle.module
            .url(forResource: "syntactically-valid", withExtension: "json", subdirectory: "Resources/CertList.bundle"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        let pkiCertificates = try PKICertificates.from(data: data)

        // when
        let encoded = try JSONEncoder().encode(pkiCertificates)
        let decoded = try JSONDecoder().decode(PKICertificates.self, from: encoded)

        // then
        expect(decoded) == pkiCertificates
    }
}
