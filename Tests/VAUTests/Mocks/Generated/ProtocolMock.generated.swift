// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
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




















final class MockTrustStoreSession: TrustStoreSession {


    //MARK: - loadVauCertificate

    var loadVauCertificateCallsCount = 0
    var loadVauCertificateCalled: Bool {
        return loadVauCertificateCallsCount > 0
    }
    var loadVauCertificateReturnValue: AnyPublisher<X509, TrustStoreError>!
    var loadVauCertificateClosure: (() -> AnyPublisher<X509, TrustStoreError>)?

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        loadVauCertificateCallsCount += 1
        if let loadVauCertificateClosure = loadVauCertificateClosure {
            return loadVauCertificateClosure()
        } else {
            return loadVauCertificateReturnValue
        }
    }

    //MARK: - validate

    var validateCertificateCallsCount = 0
    var validateCertificateCalled: Bool {
        return validateCertificateCallsCount > 0
    }
    var validateCertificateReceivedCertificate: X509?
    var validateCertificateReceivedInvocations: [X509] = []
    var validateCertificateReturnValue: AnyPublisher<Bool, TrustStoreError>!
    var validateCertificateClosure: ((X509) -> AnyPublisher<Bool, TrustStoreError>)?

    func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        validateCertificateCallsCount += 1
        validateCertificateReceivedCertificate = certificate
        validateCertificateReceivedInvocations.append(certificate)
        if let validateCertificateClosure = validateCertificateClosure {
            return validateCertificateClosure(certificate)
        } else {
            return validateCertificateReturnValue
        }
    }

    //MARK: - reset

    var resetCallsCount = 0
    var resetCalled: Bool {
        return resetCallsCount > 0
    }
    var resetClosure: (() -> Void)?

    func reset() {
        resetCallsCount += 1
        resetClosure?()
    }

}
final class MockVAUAccessTokenProvider: VAUAccessTokenProvider {

    var vauBearerToken: AnyPublisher<BearerToken, VAUError> {
        get { return underlyingVauBearerToken }
        set(value) { underlyingVauBearerToken = value }
    }
    var underlyingVauBearerToken: AnyPublisher<BearerToken, VAUError>!

}
final class MockVAUCrypto: VAUCrypto {


    //MARK: - encrypt

    var encryptThrowableError: Error?
    var encryptCallsCount = 0
    var encryptCalled: Bool {
        return encryptCallsCount > 0
    }
    var encryptReturnValue: Data!
    var encryptClosure: (() throws -> Data)?

    func encrypt() throws -> Data {
        if let error = encryptThrowableError {
            throw error
        }
        encryptCallsCount += 1
        if let encryptClosure = encryptClosure {
            return try encryptClosure()
        } else {
            return encryptReturnValue
        }
    }

    //MARK: - decrypt

    var decryptDataThrowableError: Error?
    var decryptDataCallsCount = 0
    var decryptDataCalled: Bool {
        return decryptDataCallsCount > 0
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
        if let decryptDataClosure = decryptDataClosure {
            return try decryptDataClosure(data)
        } else {
            return decryptDataReturnValue
        }
    }

}
final class MockVAUCryptoProvider: VAUCryptoProvider {


    //MARK: - provide

    var provideForVauCertificateBearerTokenThrowableError: Error?
    var provideForVauCertificateBearerTokenCallsCount = 0
    var provideForVauCertificateBearerTokenCalled: Bool {
        return provideForVauCertificateBearerTokenCallsCount > 0
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
        if let provideForVauCertificateBearerTokenClosure = provideForVauCertificateBearerTokenClosure {
            return try provideForVauCertificateBearerTokenClosure(message, vauCertificate, bearerToken)
        } else {
            return provideForVauCertificateBearerTokenReturnValue
        }
    }

}
