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
import eRpResources
import Foundation

/// The specific error types for the IDP module
@CodedError("100")
public enum IDPError: Swift.Error {
    /// In case of HTTP/Connection error
    @ErrorCode("01")
    case network(error: Swift.Error)
    /// In case a response (or request) could not be (cryptographically) verified
    @ErrorCode("02")
    case validation(error: Swift.Error)
    /// When a token is being requested, but none can be found
    @ErrorCode("03")
    case tokenUnavailable
    /// Other error cases
    @ErrorCode("04")
    case unspecified(error: Swift.Error)
    /// Message failed to decode/parse
    @ErrorCode("05")
    case decoding(error: Swift.Error)
    /// When failed to extract a X.509 certificate from the DiscoveryDocument
    @ErrorCode("06")
    case noCertificateFound
    /// When the discovery document has expired or the trust anchors could not be verified
    @ErrorCode("07")
    case invalidDiscoveryDocument
    /// When the state parameter received from the server is not equal to the one sent
    @ErrorCode("08")
    case invalidStateParameter
    /// When the nonce received from the server is not equal to the one sent
    @ErrorCode("09")
    case invalidNonce
    /// When a method/algorithm is unsupported
    @ErrorCode("10")
    case unsupported(String?)
    /// When encryption fails
    @ErrorCode("11")
    case encryption
    /// When decryption fails
    @ErrorCode("12")
    case decryption
    /// Internal error
    @ErrorCode("13")
    case `internal`(error: InternalError)
    /// Issues related to Building or Verifying the trust store
    @ErrorCode("14")
    case trustStore(error: Swift.Error)

    @ErrorCode("15")
    case pairing(Swift.Error)

    @ErrorCode("16")
    case invalidSignature(String)

    /// Server responded with an error
    @ErrorCode("17")
    case serverError(ServerResponse)

    /// Any biometrics related error
    @ErrorCode("18")
    case biometrics(SecureEnclaveSignatureProviderError)

    /// External authentication failed due to missing or invalid original request
    @ErrorCode("19")
    case extAuthOriginalRequestMissing

    /// Not implemented as the conforming instance is meant for demo purpose only
    @ErrorCode("20")
    case notAvailableInDemoMode

    public struct ServerResponse: Codable, CustomStringConvertible, Equatable {
        public let error: String
        public let errorText: String
        public let timestamp: Int
        public let uuid: String
        public let code: String

        public init(error: String, errorText: String, timestamp: Int, uuid: String, code: String) {
            self.error = error
            self.errorText = errorText
            self.timestamp = timestamp
            self.uuid = uuid
            self.code = code
        }

        // [REQ:gemSpec_IDP_Frontend:A_19937#3,A_20605,A_20085] Error formatting
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

    @CodedError("101")
    public enum InternalError: Swift.Error {
        @ErrorCode("01")
        case loadDiscoveryDocumentUnexpectedNil
        @ErrorCode("02")
        case requestChallengeUnexpectedNil
        @ErrorCode("03")
        case constructingChallengeRequestUrl
        @ErrorCode("04")
        case getAndValidateUnexpectedNil
        @ErrorCode("05")
        case constructingRefreshWithSSOTokenRequest
        @ErrorCode("06")
        case refreshResponseMissingHeaderValue
        @ErrorCode("07")
        case challengeExpired
        @ErrorCode("08")
        case verifyUnexpectedNil
        @ErrorCode("09")
        case verifyResponseMissingHeaderValue
        @ErrorCode("10")
        case verifierCodeCreation
        @ErrorCode("11")
        case stateNonceCreation
        @ErrorCode("12")
        case signedChallengeEncoded
        @ErrorCode("13")
        case signedChallengeEncryption
        @ErrorCode("14")
        case altVerifyResponseMissingHeaderValue
        @ErrorCode("15")
        case encryptedSignedChallengeEncoding
        @ErrorCode("16")
        case exchangeUnexpectedNil
        @ErrorCode("17")
        case exchangeTokenUnexpectedNil
        @ErrorCode("18")
        case ssoLoginAndExchangeUnexpectedNil
        @ErrorCode("19")
        case registrationDataEncryption
        @ErrorCode("20")
        case keyVerifierEncoding
        @ErrorCode("21")
        case encryptedKeyVerifierEncoding
        @ErrorCode("22")
        case keyVerifierJweHeaderEncryption
        @ErrorCode("23")
        case keyVerifierJwePayloadEncryption
        @ErrorCode("24")
        case nestJwtInJwePayloadEncryption
        @ErrorCode("25")
        case invalidByteBuffer
        @ErrorCode("26")
        case generatingSecureRandom(length: Int)
        @ErrorCode("27")
        case registeredDeviceEncoding
        @ErrorCode("28")
        case signedAuthenticationDataEncryption
        @ErrorCode("29")
        case constructingExtAuthRequestUrl
        @ErrorCode("30")
        case refreshTokenUnexpectedNil
        @ErrorCode("31")
        case loadDirectoryKKAppsUnexpectedNil
        @ErrorCode("32")
        case extAuthVerifyResponseMissingHeaderValue
        @ErrorCode("33")
        case extAuthVerifierCodeCreation
        @ErrorCode("34")
        case extAuthStateNonceCreation
        @ErrorCode("35")
        case extAuthVerifyAndExchangeUnexpectedNil
        @ErrorCode("36")
        case extAuthVerifyAndExchangeMissingQueryItem
        @ErrorCode("37")
        case extAuthConstructingRedirectUri
        @ErrorCode("38")
        case startExtAuthUnexpectedNil
        @ErrorCode("39")
        case extAuthVerifyUnexpectedNil
        @ErrorCode("40")
        case pairDeviceUnexpectedNil
        @ErrorCode("41")
        case unregisterDeviceUnexpectedNil
        @ErrorCode("42")
        case listDevicesUnexpectedNil
        @ErrorCode("43")
        case altVerifyUnexpectedNil
        @ErrorCode("44")
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
        case let (.trustStore(lhsError), .trustStore(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.biometrics(lhsError), .biometrics(rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }
}

extension IDPError: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public enum LoadingError: Swift.Error {
        case message(String?)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let value = try? container.decode(String.self, forKey: .value)
        switch type {
        case "network":
            self = .network(error: LoadingError.message(value))
        case "validation":
            self = .validation(error: LoadingError.message(value))
        case "tokenUnavailable":
            self = .tokenUnavailable
        case "unspecified":
            self = .unspecified(error: LoadingError.message(value))
        case "decoding":
            self = .decoding(error: LoadingError.message(value))
        case "noCertificateFound":
            self = .noCertificateFound
        case "invalidDiscoveryDocument":
            self = .invalidDiscoveryDocument
        case "invalidStateParameter":
            self = .invalidStateParameter
        case "invalidNonce":
            self = .invalidNonce
        case "unsupported":
            self = .unsupported(value)
        case "encryption":
            self = .encryption
        case "decryption":
            self = .decryption
        case "`internal`":
            self = .internal(error: .notImplemented)
        case "trustStore":
            self = .trustStore(error: LoadingError.message(value))
        case "pairing":
            self = .pairing(LoadingError.message(value))
        case "invalidSignature":
            self = .invalidSignature(value ?? "")
        case "serverError":
            if let valueData = value?.data(using: .utf8),
               let response = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: valueData) {
                self = .serverError(response)
            }
            self = .serverError(.init(error: value ?? "", errorText: value ?? "", timestamp: 0, uuid: "", code: ""))
        case "biometrics":
            self = .biometrics(.internal(value ?? "", nil))
        case "extAuthOriginalRequestMissing":
            self = .extAuthOriginalRequestMissing
        case "notAvailableInDemoMode":
            self = .notAvailableInDemoMode
        default:
            self = .unsupported("Error while decoding the error")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .network(error):
            try container.encode("network", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .validation(error):
            try container.encode("validation", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .unspecified(error):
            try container.encode("unspecified", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .decoding(error):
            try container.encode("decoding", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case .tokenUnavailable:
            try container.encode("tokenUnavailable", forKey: .type)
        case .noCertificateFound:
            try container.encode("noCertificateFound", forKey: .type)
        case .invalidDiscoveryDocument:
            try container.encode("invalidDiscoveryDocument", forKey: .type)
        case .extAuthOriginalRequestMissing:
            try container.encode("extAuthOriginalRequestMissing", forKey: .type)
        case let .internal(error):
            try container.encode("internal", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .invalidSignature(text):
            try container.encode("invalidSignature", forKey: .type)
            try container.encode(text, forKey: .value)
        case let .serverError(response):
            try container.encode("serverError", forKey: .type)
            let encodeResponse = try JSONEncoder().encode(response)
            try container.encode(String(data: encodeResponse, encoding: .utf8), forKey: .value)
        case let .trustStore(error):
            try container.encode("trustStore", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .biometrics(error):
            try container.encode("biometrics", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case .invalidStateParameter:
            try container.encode("invalidStateParameter", forKey: .type)
        case .invalidNonce:
            try container.encode("invalidNonce", forKey: .type)
        case let .unsupported(info):
            try container.encode("unsupported", forKey: .type)
            try container.encode(info, forKey: .value)
        case .encryption:
            try container.encode("encryption", forKey: .type)
        case .decryption:
            try container.encode("decryption", forKey: .type)
        case let .pairing(error):
            try container.encode("pairing", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case .notAvailableInDemoMode:
            try container.encode("notAvailableInDemoMode", forKey: .type)
        }
    }
}

extension IDPError: LocalizedError {
    public var errorDescription: String? {
        // [REQ:gemSpec_IDP_Frontend:A_20085] Error localization is not done yet, this is the place to localize
        // accordingly.
        switch self {
        case let .network(error: error): return error.localizedDescription
        case let .validation(error: error): return error.localizedDescription
        case .tokenUnavailable: return "IDPError.tokenUnavailable"
        case let .unspecified(error: error): return error.localizedDescription
        case let .decoding(error: error): return error.localizedDescription
        case .noCertificateFound: return "IDPError.noCertificateFound"
        case .invalidDiscoveryDocument: return "IDPError.invalidDiscoveryDocument"
        case let .unsupported(string): return "IDPError.unsupported method \(String(describing: string))"
        // [REQ:gemSpec_IDP_Frontend:A_19937#1,A_20605,A_20085] Localized description of server errors
        case let .internal(error: error): return error.localizedDescription
        case let .serverError(error): return "IDPError.serverError '\(error)'"
        case .invalidStateParameter:
            return "IDPError.invalidStateParameter"
        case let .invalidSignature(text):
            return "IDPError.invalidSignature \(text)"
        case .invalidNonce:
            return "IDPError.invalidNonce"
        case .encryption:
            return "IDPError.encryption"
        case .decryption:
            return "IDPError.decryption"
        case let .trustStore(error: error):
            return "Trust store error: \(error)"
        case let .pairing(error):
            return "Pairing error: \(error)"
        case .biometrics where contains(PrivateKeyContainer.Error.canceledByUser):
            return L10n.errSpecificI10808Description.text
        case .biometrics:
            return L10n.errSpecificI10018Description.text
        case .extAuthOriginalRequestMissing:
            return "Error while processing external authentication: original request not found."
        case .notAvailableInDemoMode:
            return L10n.idpErrNotAvailableInDemoModeText.text
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notAvailableInDemoMode:
            return L10n.idpErrNotAvailableInDemoModeRecovery.text
        default:
            return "Try again later"
        }
    }
}
