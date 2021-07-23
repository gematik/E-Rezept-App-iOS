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

import CryptoKit
import Foundation
import OpenSSL

/// TokenPayload - gemSpec_IDP_Dienst#5.2.2
public struct TokenPayload: Codable {
    public var accessToken: String
    public let expiresIn: Int
    public var idToken: String
    public let ssoToken: String?
    public let tokenType: String

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

    public struct AccesTokenPayload: Claims {
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
        /// Organization name
        public let organizationName: String?
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
            case organizationName
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
	enum Error: Swift.Error {
		case dataEncoding
		case stringConversion
		case decryption(Swift.Error)
	}

	func decrypted(with aesKey: SymmetricKey) throws -> TokenPayload {
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

struct KeyVerifier: Codable {
	/// data string key that is used by the server to encrypt the access token response
	let tokenKey: String
	///  random generated verifier code that was created and sent with the request challenge API call
	let verifierCode: VerifierCode

	init(with key: SymmetricKey, codeVerifier: String) throws {
        guard let keyDataString = key.withUnsafeBytes({ Data(Array($0)) }).encodeBase64urlsafe().utf8string else {
            throw Error.stringConversion
        }
        tokenKey = keyDataString
		verifierCode = codeVerifier
	}

	enum CodingKeys: String, CodingKey {
		case tokenKey = "token_key"
		case verifierCode = "code_verifier"
	}

    enum Error: Swift.Error {
        case stringConversion
    }

    func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
                   using cryptoBox: IDPCrypto) throws -> JWE {
        guard let keyVerifierEncoded = try? KeyVerifier.jsonEncoder.encode(self) else {
           throw IDPError.internalError("constructing key verifier failed")
        }

        let keyExchangeContext = JWE.Algorithm.KeyExchangeContext.bpp256r1(
        	publicKey,
        	keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
        )

        guard let jweHeader = try? JWE.Header(algorithm: JWE.Algorithm.ecdh_es(keyExchangeContext),
                                              encryption: .a256gcm,
                                              contentType: "JWT") else {
            throw IDPError.internalError("constructing jwe header failed")
        }

        guard let jwe = try? JWE(header: jweHeader,
                                 payload: keyVerifierEncoded,
                                 nonceGenerator: cryptoBox.aesNonceGenerator) else {
            throw IDPError.internalError("constructing inner jwe failed")
        }

        return jwe
    }

    private static var jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dataEncodingStrategy = .base64
            return jsonEncoder
    }()
}
