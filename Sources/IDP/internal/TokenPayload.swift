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

import CodedError
import CryptoKit
import Foundation

/// TokenPayload - gemSpec_IDP_Dienst#5.2.2
public struct TokenPayload: Codable {
    public var accessToken: String
    public let expiresIn: Int
    public var idToken: String
    public let ssoToken: String?
    public let tokenType: String

    public init(
        accessToken: String,
        expiresIn: Int,
        idToken: String,
        ssoToken: String? = nil,
        tokenType: String
    ) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.idToken = idToken
        self.ssoToken = ssoToken
        self.tokenType = tokenType
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case idToken = "id_token"
        case ssoToken = "ssotoken"
        case tokenType = "token_type"
    }

    /// Json response for the access token
    struct AccessTokenResponse: Codable {
        /// The actual access token
        let njwt: String
    }

    /// Json response for the id token
    struct IDTokenResponse: Codable {
        /// The actual idToken
        let njwt: String
    }

    public struct AccessTokenPayload: Claims {
        public let exp: Date?
    }

    public struct IDTokenPayload: Claims, Equatable {
        /// IDP Authentication time
        public let authTime: Date
        /// Expiration UNIX Timestamp
        public let exp: Date
        /// Issued at
        public let iat: Date
        /// Same random  used for requesting the challenge
        public let nonce: String
        /// Name of patient (e.g. "Heinz Hillbert")
        public let givenName: String?
        /// Family name of patient (e.g.: "Cördes")
        public let familyName: String?
        /// Full name of patient (e.g.: "Heinz Hilbert Cördes")
        public let displayName: String?
        /// Organization name
        public let organizationName: String?
        /// Organization IK-Number
        public let organizationIK: String?
        /// Profession ID of the user (e.g.: "1.2.276.0.76.4.49")
        public let professionOID: String?
        /// Health card number (e.g.: "X110443874")
        public let idNummer: String?
        /// (e.g.: "eRezeptApp")
        public let azp: String
        /// (e.g.: "gematik-ehealth-loa-high")
        public let acr: String
        /// (e.g.: "mfa","sc","pin")
        public let amr: [String]
        /// (e.g.: "eRezeptApp")
        public let aud: String
        /// (e.g.: "58524f85261195aad1d0bd9d551466e516525a4ce1938883831eff2346839c65")
        public let sub: String
        /// Issuer of token(e.g.: "https://idp-ref.zentral.idp.splitdns.ti-dienste.de")
        public let iss: String
        /// (e.g.: "3dcbd9bc-cccb-449c-9d6f-698d09db6080")
        public let jti: String
        /// (e.g.: "sG1Xs3gu_aZ-5wuLUHUiUw")
        public let atHash: String

        enum CodingKeys: String, CodingKey {
            case authTime = "auth_time"
            case nonce
            case givenName = "given_name"
            case familyName = "family_name"
            case displayName = "display_name"
            case organizationName
            case organizationIK
            case professionOID
            case idNummer
            case azp
            case acr
            case amr
            case aud
            case sub
            case iss
            case iat
            case exp
            case jti
            case atHash = "at_hash"
        }
    }
}

extension TokenPayload {
    @CodedError("106")
    public enum Error: Swift.Error {
        @ErrorCode("01")
        case dataEncoding
        @ErrorCode("02")
        case stringConversion
        @ErrorCode("03")
        case decryption(Swift.Error)
    }

    /// Decrypt the token payload using the provided AES key
    /// - Parameter aesKey: AES symmetric key for decryption
    /// - Returns: Decrypted TokenPayload with access and ID tokens
    /// - Throws: TokenPayload.Error if decryption fails
    public func decrypted(with aesKey: SymmetricKey) throws -> TokenPayload {
        guard let accessTokenData = accessToken.data(using: .utf8),
              let idTokenData = idToken.data(using: .utf8) else {
            throw Error.dataEncoding
        }

        do {
            let accessTokenJWE = try JWE.from(accessTokenData, with: .plain(aesKey))
            let idTokenJWE = try JWE.from(idTokenData, with: .plain(aesKey))

            let accessTokenDecrypted = try JSONDecoder().decode(AccessTokenResponse.self,
                                                                from: accessTokenJWE.payload)
            let idTokenDecrypted = try JSONDecoder().decode(IDTokenResponse.self,
                                                            from: idTokenJWE.payload)
            return TokenPayload(
                accessToken: accessTokenDecrypted.njwt,
                expiresIn: expiresIn,
                idToken: idTokenDecrypted.njwt,
                ssoToken: ssoToken,
                tokenType: tokenType
            )
        } catch {
            throw Error.decryption(error)
        }
    }
}

extension TokenPayload: Equatable {}
