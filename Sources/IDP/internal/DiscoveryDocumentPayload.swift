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

import Foundation

/// IDP Discovery document - https://tools.ietf.org/html/rfc8414
public struct DiscoveryDocumentPayload: Claims, Equatable {
    /// IDP Authentication endpoint
    public let authentication: URL
    /// IDP Authentication via paired key (a.k.a. authentication via biometrics) endpoint
    public let authenticationPair: URL
    /// SSO endpoint
    public let sso: URL
    /// IDP Token exchange endpoint
    public let token: URL
    /// Endpoint for the DiscoveryDocument
    public let disc: URL
    /// Endpoint for the pairing of new biometric keys
    public let pairing: URL
    /// Endpoint of the issuer
    public let issuer: URL
    /// Endpoint for all JWKs (incl. pukIdpEnc, pukIdpSig and discKey)
    public let jwks: URL
    /// Expiration UNIX Timestamp
    public let exp: Date
    /// Issued at
    public let iat: Date
    /// Endpoint for the public encryption key
    public let pukIdpEnc: URL
    /// Endpoint for the public signing key
    public let pukIdpSig: URL
    /// Endpoint for retrieving available kk apps for alternative authentication
    public let kkAppList: URL?
    /// Endpoint for alternative authentication request as in `gemSpec_IDP_Sek`
    public let thirdPartyAuth: URL?

    public let subjectTypesSupported: [String]

    public let supportedSigningAlgorithms: [String]

    public let supportedResponseTypes: [String]

    public let supportedScopes: [String]

    public let supportedResponseModes: [String]

    public let supportedGrantTypes: [String]

    public let supportedAcrValues: [String]

    public let supportedTokenEndpointAuthMethods: [String]

    enum CodingKeys: String, CodingKey {
        case authentication = "authorization_endpoint"
        case authenticationPair = "auth_pair_endpoint"
        case sso = "sso_endpoint"
        case token = "token_endpoint"
        case pairing = "uri_pair"
        case disc = "uri_disc"
        case issuer
        case jwks = "jwks_uri"
        case exp
        case iat
        case pukIdpEnc = "uri_puk_idp_enc"
        case pukIdpSig = "uri_puk_idp_sig"
        case kkAppList = "kk_app_list_uri"
        case thirdPartyAuth = "third_party_authorization_endpoint"
        case subjectTypesSupported = "subject_types_supported"
        case supportedSigningAlgorithms = "id_token_signing_alg_values_supported"
        case supportedResponseTypes = "response_types_supported"
        case supportedScopes = "scopes_supported"
        case supportedResponseModes = "response_modes_supported"
        case supportedGrantTypes = "grant_types_supported"
        case supportedAcrValues = "acr_values_supported"
        case supportedTokenEndpointAuthMethods = "token_endpoint_auth_methods_supported"
    }
}
