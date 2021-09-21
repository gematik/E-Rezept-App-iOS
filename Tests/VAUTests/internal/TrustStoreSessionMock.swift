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

import Combine
import Foundation
import OpenSSL
import TrustStore

struct TrustStoreSessionMock: TrustStoreSession {
    var vauCertificate: X509 = defaultVauCertificate
    var validateCertificate = true

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        Just(vauCertificate).setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()
    }

    func validate(certificate _: X509) -> AnyPublisher<Bool, TrustStoreError> {
        Just(validateCertificate).setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()
    }

    static let defaultVauCertificate: X509 = {
        let pemString = """
        -----BEGIN CERTIFICATE-----
        MIICWzCCAgKgAwIBAgIUXcN6K1n5kgykxETzVBv/WoRt01YwCgYIKoZIzj0EAwIw
        gYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJlcmxp
        bjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UECwwHZ2VtYXRpazEtMCsGA1UEAwwk
        RS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVtZW50aWVydW5nMB4XDTIwMDUyMjE2
        NTgyNFoXDTIxMDUyMjE2NTgyNFowgYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZC
        ZXJsaW4xDzANBgNVBAcMBkJlcmxpbjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UE
        CwwHZ2VtYXRpazEtMCsGA1UEAwwkRS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVt
        ZW50aWVydW5nMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABIY0ISgw2tRXygUw
        XmaHE0FmucIaZf/r9VX05137BIiIZuS2hDYky9pDyX6omWi8Qf1TV2+CwD76fWAb
        n6ysKymjUzBRMB0GA1UdDgQWBBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAfBgNVHSME
        GDAWgBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAPBgNVHRMBAf8EBTADAQH/MAoGCCqG
        SM49BAMCA0cAMEQCIC8jRqHV/dHK+N9Y0NF5MVHS2RvtP3ndzCPhwKBz0UW9AiA6
        oJnHJ2OP68rqpnbHG1/WWGJEfVT9Fig3zeYwYZKYvg==
        -----END CERTIFICATE-----
        """
        let pem = pemString.data(using: .ascii)! // swiftlint:disable:this force_unwrapping
        return try! X509(pem: pem)
    }()

    func reset() {}
}
