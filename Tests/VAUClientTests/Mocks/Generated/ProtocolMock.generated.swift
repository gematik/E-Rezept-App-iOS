// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import OpenSSL
import TrustStore

@testable import VAUClient

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockVAUAccessTokenProvider -

final class MockVAUAccessTokenProvider: VAUAccessTokenProvider {
    
   // MARK: - vauBearerToken

    var vauBearerToken: AnyPublisher<BearerToken, VAUError> {
        get { underlyingVauBearerToken }
        set(value) { underlyingVauBearerToken = value }
    }
    var underlyingVauBearerToken: AnyPublisher<BearerToken, VAUError>!
}


// MARK: - MockVAUCrypto -

final class MockVAUCrypto: VAUCrypto {
    
   // MARK: - encrypt

    var encryptThrowableError: Error?
    var encryptCallsCount = 0
    var encryptCalled: Bool {
        encryptCallsCount > 0
    }
    var encryptReturnValue: Data!
    var encryptClosure: (() throws -> Data)?

    func encrypt() throws -> Data {
        if let error = encryptThrowableError {
            throw error
        }
        encryptCallsCount += 1
        return try encryptClosure.map({ try $0() }) ?? encryptReturnValue
    }
    
   // MARK: - decrypt

    var decryptDataThrowableError: Error?
    var decryptDataCallsCount = 0
    var decryptDataCalled: Bool {
        decryptDataCallsCount > 0
    }
    var decryptDataReceivedData: Data?
    var decryptDataReceivedInvocations: [Data] = []
    var decryptDataReturnValue: String!
    var decryptDataClosure: ((Data) throws -> String)?

    func decrypt(data: Data) throws -> String {
        if let error = decryptDataThrowableError {
            throw error
        }
        decryptDataCallsCount += 1
        decryptDataReceivedData = data
        decryptDataReceivedInvocations.append(data)
        return try decryptDataClosure.map({ try $0(data) }) ?? decryptDataReturnValue
    }
}


// MARK: - MockVAUCryptoProvider -

final class MockVAUCryptoProvider: VAUCryptoProvider {
    
   // MARK: - provide

    var provideForVauCertificateBearerTokenThrowableError: Error?
    var provideForVauCertificateBearerTokenCallsCount = 0
    var provideForVauCertificateBearerTokenCalled: Bool {
        provideForVauCertificateBearerTokenCallsCount > 0
    }
    var provideForVauCertificateBearerTokenReceivedArguments: (message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken)?
    var provideForVauCertificateBearerTokenReceivedInvocations: [(message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken)] = []
    var provideForVauCertificateBearerTokenReturnValue: VAUCrypto!
    var provideForVauCertificateBearerTokenClosure: ((String, VAUCertificate, BearerToken) throws -> VAUCrypto)?

    func provide(for message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken) throws -> VAUCrypto {
        if let error = provideForVauCertificateBearerTokenThrowableError {
            throw error
        }
        provideForVauCertificateBearerTokenCallsCount += 1
        provideForVauCertificateBearerTokenReceivedArguments = (message: message, vauCertificate: vauCertificate, bearerToken: bearerToken)
        provideForVauCertificateBearerTokenReceivedInvocations.append((message: message, vauCertificate: vauCertificate, bearerToken: bearerToken))
        return try provideForVauCertificateBearerTokenClosure.map({ try $0(message, vauCertificate, bearerToken) }) ?? provideForVauCertificateBearerTokenReturnValue
    }
}
