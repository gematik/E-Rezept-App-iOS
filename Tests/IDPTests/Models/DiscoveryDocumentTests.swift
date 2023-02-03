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

import Combine
import Foundation
@testable import IDP
import Nimble
import OpenSSL
import XCTest

class DiscoveryDocumentTests: XCTestCase {
    func testMappingDiscoveryDocumentPayload() throws {
        let payload = DiscoveryDocumentPayload(
            authentication: URL(string: "http://localhost:8888/sign_response")!,
            authenticationPair: URL(string: "http://localhost:8888/alt_response")!,
            sso: URL(string: "http://localhost:8888/sso_response")!,
            token: URL(string: "http://localhost:8888/token")!,
            disc: URL(string: "http://localhost:8888/discoveryDocument")!,
            pairing: URL(string: "http://localhost:8888/pairings")!,
            issuer: URL(string: "https://idp.zentral.idp.splitdns.ti-dienste.de")!,
            jwks: URL(string: "http://localhost:8888/jwks")!,
            exp: Date(timeIntervalSince1970: 1_615_909_864),
            iat: Date(timeIntervalSince1970: 1_615_823_464),
            pukIdpEnc: URL(string: "http://localhost:8888/idpEnc/jwks.json")!,
            pukIdpSig: URL(string: "http://localhost:8888/ipdSig/jwks.json")!,
            kkAppList: URL(string: "http://localhost:8888/appList")!,
            thirdPartyAuth: URL(string: "http://localhost:8888/thirdPartyAuth")!,
            subjectTypesSupported: [
                "pairwise",
            ],
            supportedSigningAlgorithms: [
                "BP256R1",
            ],
            supportedResponseTypes: [
                "code",
            ],
            supportedScopes: [
                "openid",
                "e-rezept",
            ],
            supportedResponseModes: [
                "query",
            ],
            supportedGrantTypes: [
                "authorization_code",
            ],
            supportedAcrValues: [
                "urn:eidas:loa:high",
            ],
            supportedTokenEndpointAuthMethods: [
                "none",
            ]
        )

        let jwtData = try Bundle(for: Self.self)
            .path(forResource: "discovery-doc", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents()
        let jwt = try JWT(from: jwtData)
        let jwkData = try Bundle(for: Self.self)
            .path(forResource: "jwk", ofType: "json", inDirectory: "JWT.bundle")!
            .readFileContents()
        let jwk = try JSONDecoder().decode(JWK.self, from: jwkData)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let expirationDate = dateFormatter.date(from: "2021-03-19 08:51:16.0000+0000")!
        let issuedDate = dateFormatter.date(from: "2021-03-18 08:51:16.0000+0000")!

        let document = try DiscoveryDocument(jwt: jwt, encryptPuks: jwk, signingPuks: jwk, createdOn: issuedDate)
        expect(document.expiresOn) == expirationDate
        expect(document.issuedAt) == issuedDate

        expect(document.token.url) == payload.token
        expect(document.authentication.url) == payload.authentication

        // isValid
        expect(document.isValid(on: expirationDate)) == true
        expect(document.isValid(on: issuedDate)) == true
        expect(document.isValid(on: Date(timeInterval: -1.0, since: expirationDate))) == true
        // isInvalid
        expect(document.isValid(on: Date(timeInterval: 1.0, since: expirationDate))) == false
    }
}
