// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
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
















// MARK: - MockTrustStoreSession -

final class MockTrustStoreSession: TrustStoreSession {
    
   // MARK: - loadVauCertificate

    var loadVauCertificateCallsCount = 0
    var loadVauCertificateCalled: Bool {
        loadVauCertificateCallsCount > 0
    }
    var loadVauCertificateReturnValue: AnyPublisher<X509, TrustStoreError>!
    var loadVauCertificateClosure: (() -> AnyPublisher<X509, TrustStoreError>)?

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        loadVauCertificateCallsCount += 1
        return loadVauCertificateClosure.map({ $0() }) ?? loadVauCertificateReturnValue
    }
    
   // MARK: - validate

    var validateCertificateCallsCount = 0
    var validateCertificateCalled: Bool {
        validateCertificateCallsCount > 0
    }
    var validateCertificateReceivedCertificate: X509?
    var validateCertificateReceivedInvocations: [X509] = []
    var validateCertificateReturnValue: AnyPublisher<Bool, TrustStoreError>!
    var validateCertificateClosure: ((X509) -> AnyPublisher<Bool, TrustStoreError>)?

    func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        validateCertificateCallsCount += 1
        validateCertificateReceivedCertificate = certificate
        validateCertificateReceivedInvocations.append(certificate)
        return validateCertificateClosure.map({ $0(certificate) }) ?? validateCertificateReturnValue
    }
    
   // MARK: - reset

    var resetCallsCount = 0
    var resetCalled: Bool {
        resetCallsCount > 0
    }
    var resetClosure: (() -> Void)?

    func reset() {
        resetCallsCount += 1
        resetClosure?()
    }
}


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
