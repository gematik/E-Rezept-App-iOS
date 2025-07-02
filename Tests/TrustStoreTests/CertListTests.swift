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

import Foundation
import Nimble
@testable import TrustStore
import XCTest

final class CertListTests: XCTestCase {
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
        let certList = try CertList.from(data: data)
        let certListBase64 = try CertList.Base64.from(data: data)

        // then
        expect(certList.addRoots.count) == 0
        expect(certList.caCerts.count) == 2
        expect(certList.eeCerts.count) == 2

        expect(certListBase64.addRoots.count) == 0
        expect(certListBase64.caCerts.count) == 2
        expect(certListBase64.eeCerts.count) == 2
        expect(certListBase64.eeCerts.first) ==
            "MIICWzCCAgKgAwIBAgIUXcN6K1n5kgykxETzVBv/WoRt01YwCgYIKoZIzj0EAwIwgYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJlcmxpbjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UECwwHZ2VtYXRpazEtMCsGA1UEAwwkRS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVtZW50aWVydW5nMB4XDTIwMDUyMjE2NTgyNFoXDTIxMDUyMjE2NTgyNFowgYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJlcmxpbjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UECwwHZ2VtYXRpazEtMCsGA1UEAwwkRS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVtZW50aWVydW5nMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABIY0ISgw2tRXygUwXmaHE0FmucIaZf/r9VX05137BIiIZuS2hDYky9pDyX6omWi8Qf1TV2+CwD76fWAbn6ysKymjUzBRMB0GA1UdDgQWBBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAfBgNVHSMEGDAWgBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAPBgNVHRMBAf8EBTADAQH/MAoGCCqGSM49BAMCA0cAMEQCIC8jRqHV/dHK+N9Y0NF5MVHS2RvtP3ndzCPhwKBz0UW9AiA6oJnHJ2OP68rqpnbHG1/WWGJEfVT9Fig3zeYwYZKYvg=="
        // swiftlint:disable:previous line_length
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
        expect(try CertList.from(data: data)).to(throwError(errorType: DecodingError.self))
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
        let certList = try CertList.from(data: data)
        let certListBase64 = try CertList.Base64.from(data: data)

        // then
        expect(certList.addRoots.count) == 2
        expect(certList.caCerts.count) == 3
        expect(certList.eeCerts.count) == 2

        expect(certListBase64.addRoots.count) == 2
        expect(certListBase64.caCerts.count) == 3
        expect(certListBase64.eeCerts.count) == 2
    }

    func testJsonCodable() throws {
        // given
        guard let url = Bundle.module
            .url(forResource: "syntactically-valid", withExtension: "json", subdirectory: "Resources/CertList.bundle"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        let certList = try CertList.from(data: data)

        // when
        let encoded = try JSONEncoder().encode(certList)
        let decoded = try JSONDecoder().decode(CertList.self, from: encoded)

        // then
        expect(decoded) == certList
    }
}
