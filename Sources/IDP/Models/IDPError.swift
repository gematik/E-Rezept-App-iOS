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
import HTTPClient
import TrustStore

// sourcery: CodedError = "100"
/// The specific error types for the IDP module
public enum IDPError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPClientError)
    // sourcery: errorCode = "02"
    /// In case a response (or request) could not be (cryptographically) verified
    case validation(error: Swift.Error)
    // sourcery: errorCode = "03"
    /// When a token is being requested, but none can be found
    case tokenUnavailable
    // sourcery: errorCode = "04"
    /// Other error cases
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "05"
    /// Message failed to decode/parse
    case decoding(error: Swift.Error)
    // sourcery: errorCode = "06"
    /// When failed to extract a X.509 certificate from the DiscoveryDocument
    case noCertificateFound
    // sourcery: errorCode = "07"
    /// When the discovery document has expired or the trust anchors could not be verified
    case invalidDiscoveryDocument
    // sourcery: errorCode = "08"
    /// When the state parameter received from the server is not equal to the one sent
    case invalidStateParameter
    // sourcery: errorCode = "09"
    /// When the nonce received from the server is not equal to the one sent
    case invalidNonce
    // sourcery: errorCode = "10"
    /// When a method/algorithm is unsupported
    case unsupported(String?)
    // sourcery: errorCode = "11"
    /// When encryption fails
    case encryption
    // sourcery: errorCode = "12"
    /// When decryption fails
    case decryption
    // sourcery: errorCode = "13"
    /// Internal error
    case `internal`(error: InternalError)
    // sourcery: errorCode = "14"
    /// Issues related to Building or Verifying the trust store
    case trustStore(error: TrustStoreError)

    // sourcery: errorCode = "15"
    case pairing(Swift.Error)

    // sourcery: errorCode = "16"
    case invalidSignature(String)

    // sourcery: errorCode = "17"
    /// Server responded with an error
    case serverError(ServerResponse)

    // sourcery: errorCode = "18"
    /// Any biometrics related error
    case biometrics(SecureEnclaveSignatureProviderError)

    // sourcery: errorCode = "19"
    /// External authentication failed due to missing or invalid original request
    case extAuthOriginalRequestMissing

    // sourcery: errorCode = "20"
    /// Not implemented as the conforming instance is meant for demo purpose only
    case notAvailableInDemoMode

    public struct ServerResponse: Codable, CustomStringConvertible, Equatable {
        public let error: String
        public let errorText: String
        public let timestamp: Int
        public let uuid: String
        public let code: String

        // [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Error formatting
        public var description: String {
            "\nError: \(code)\n\(error): \(errorText)\nError-ID: \(uuid)"
        }

        enum CodingKeys: String, CodingKey {
            case error
            case errorText = "gematik_error_text"
            case timestamp = "gematik_timestamp"
            case uuid = "gematik_uuid"
            case code = "gematik_code"
        }
    }

    public enum Code: String {
        // 1xxx - General error
        case clientIdMissing = "1002"
        case redirectUriMissing = "1004"
        case scopeMissing = "1005"
        case redirectUriInvalid = "1020"
        case scopeInvalid = "1022"
        case fachdienstUnknown = "1030"
        case generalError = "1500"
        // 2xxx - Authorization-Endpoint
        case pairingAuthorizationFailed = "2000"
        case requestSignatureMissing = "2001"
        case stateMissing = "2002"
        case algorithmInvalid = "2003"
        case responseTypeMissing = "2004"
        case responseTypeNotSupported = "2005"
        case stateInvalid = "2006"
        case nonceInvalid = "2007"
        case codeChallengeMethodInvalid = "2008"
        case codeChallengeMissing = "2009"
        case codeChallengeInvalid = "2010"
        case requestParameterDuplicate = "2011"
        case clientIdInvalid = "2012"
        case requestSignatureInvalid = "2013"
        case requestSignatureFromIdpMissing = "2014"
        case signingAlgorithmInvalid = "2015"
        case requestSignatureFromIdpInvalid = "2016"
        case autCertificateInvalid = "2020"
        case noResponseFromOcspOrTimeout = "2021"
        case challengeInvalid = "2030"
        case authorizationExpMissing = "2031"
        case challengeExpired = "2032"
        case ssoTokenInvalid = "2040"
        case ssoTokenAndChallengeIncompatible = "2041"
        case claimsOfUserConsentIsMissing = "2042"
        case encryptionFailed = "2050"
        case unknownError = "2100"
        // 3xxx - Token-Endpoint
        case codeVerifierAndCodeChallengeIncompatible = "3000"
        case missingClaimsInAuthenticationCode = "3001"
        case codeVerifierMissing = "3004"
        case authorizationCodeMissing = "3005"
        case grantTypeMissing = "3006"
        case tokenClientIdInvalid = "3007"
        case authorizationCodeSignatureInvalid = "3010"
        case authorizationCodeExpired = "3011"
        case tokenExpMissing = "3012"
        case authorizationCodeNotReadable = "3013"
        case grantTypeNotSupported = "3014"
        case codeVerifierInvalid = "3016"
        case keyVerifierMissing = "3020"
        case keyVerifierNotReadable = "3021"
        case tokenKeyMissing = "3022"
        case tokenKeyNotReadable = "3023"
        // 4xxx - Pairing-Endpoint
        case pairingDeactivationFailed = "4000"
        case accessDenied = "4001"
        case deviceInvalid = "4002"
        case keyRegistrationFailed = "4003"
        case duplicateKeyRegistration = "4004"
        case keyRegistrationDataNotReadable = "4005"
    }

    // sourcery: CodedError = "101"
    public enum InternalError: Swift.Error {
        // sourcery: errorCode = "01"
        case loadDiscoveryDocumentUnexpectedNil
        // sourcery: errorCode = "02"
        case requestChallengeUnexpectedNil
        // sourcery: errorCode = "03"
        case constructingChallengeRequestUrl
        // sourcery: errorCode = "04"
        case getAndValidateUnexpectedNil
        // sourcery: errorCode = "05"
        case constructingRefreshWithSSOTokenRequest
        // sourcery: errorCode = "06"
        case refreshResponseMissingHeaderValue
        // sourcery: errorCode = "07"
        case challengeExpired
        // sourcery: errorCode = "08"
        case verifyUnexpectedNil
        // sourcery: errorCode = "09"
        case verifyResponseMissingHeaderValue
        // sourcery: errorCode = "10"
        case verifierCodeCreation
        // sourcery: errorCode = "11"
        case stateNonceCreation
        // sourcery: errorCode = "12"
        case signedChallengeEncoded
        // sourcery: errorCode = "13"
        case signedChallengeEncryption
        // sourcery: errorCode = "14"
        case altVerifyResponseMissingHeaderValue
        // sourcery: errorCode = "15"
        case encryptedSignedChallengeEncoding
        // sourcery: errorCode = "16"
        case exchangeUnexpectedNil
        // sourcery: errorCode = "17"
        case exchangeTokenUnexpectedNil
        // sourcery: errorCode = "18"
        case ssoLoginAndExchangeUnexpectedNil
        // sourcery: errorCode = "19"
        case registrationDataEncryption
        // sourcery: errorCode = "20"
        case keyVerifierEncoding
        // sourcery: errorCode = "21"
        case encryptedKeyVerifierEncoding
        // sourcery: errorCode = "22"
        case keyVerifierJweHeaderEncryption
        // sourcery: errorCode = "23"
        case keyVerifierJwePayloadEncryption
        // sourcery: errorCode = "24"
        case nestJwtInJwePayloadEncryption
        // sourcery: errorCode = "25"
        case invalidByteBuffer
        // sourcery: errorCode = "26"
        case generatingSecureRandom(length: Int)
        // sourcery: errorCode = "27"
        case registeredDeviceEncoding
        // sourcery: errorCode = "28"
        case signedAuthenticationDataEncryption
        // sourcery: errorCode = "29"
        case constructingExtAuthRequestUrl
        // sourcery: errorCode = "30"
        case refreshTokenUnexpectedNil
        // sourcery: errorCode = "31"
        case loadDirectoryKKAppsUnexpectedNil
        // sourcery: errorCode = "32"
        case extAuthVerifyResponseMissingHeaderValue
        // sourcery: errorCode = "33"
        case extAuthVerifierCodeCreation
        // sourcery: errorCode = "34"
        case extAuthStateNonceCreation
        // sourcery: errorCode = "35"
        case extAuthVerifyAndExchangeUnexpectedNil
        // sourcery: errorCode = "36"
        case extAuthVerifyAndExchangeMissingQueryItem
        // sourcery: errorCode = "37"
        case extAuthConstructingRedirectUri
        // sourcery: errorCode = "38"
        case startExtAuthUnexpectedNil
        // sourcery: errorCode = "39"
        case extAuthVerifyUnexpectedNil
        // sourcery: errorCode = "40"
        case pairDeviceUnexpectedNil
        // sourcery: errorCode = "41"
        case unregisterDeviceUnexpectedNil
        // sourcery: errorCode = "42"
        case listDevicesUnexpectedNil
        // sourcery: errorCode = "43"
        case altVerifyUnexpectedNil
        // sourcery: errorCode = "44"
        case notImplemented
    }
}

extension IDPError: Equatable {
    // swiftlint:disable:next cyclomatic_complexity
    public static func ==(lhs: IDPError, rhs: IDPError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.validation(error: lhsError), .validation(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.decoding(error: lhsError), .decoding(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case (.tokenUnavailable, .tokenUnavailable),
             (.noCertificateFound, .noCertificateFound),
             (.invalidDiscoveryDocument, .invalidDiscoveryDocument),
             (.extAuthOriginalRequestMissing, .extAuthOriginalRequestMissing): return true
        case let (.internal(error: lhsError), .internal(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.invalidSignature(lhsText), .invalidSignature(rhsText)): return lhsText == rhsText
        case let (.serverError(lhsError), .serverError(rhsError)): return lhsError == rhsError
        case let (.trustStore(lhsError), .trustStore(rhsError)): return lhsError == rhsError
        case let (.biometrics(lhsError), .biometrics(rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }
}
