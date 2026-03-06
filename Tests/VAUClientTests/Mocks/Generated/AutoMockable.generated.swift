// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Combine
import Foundation
import OpenSSL
import TrustStore

@testable import VAUClient
























public class TrustStoreSessionMock: TrustStoreSession {

    public init() {}



    //MARK: - vauCertificate

    public var vauCertificateX509ThrowableError: (any Error)?
    public var vauCertificateX509CallsCount = 0
    public var vauCertificateX509Called: Bool {
        return vauCertificateX509CallsCount > 0
    }
    public var vauCertificateX509ReturnValue: X509!
    public var vauCertificateX509Closure: (() async throws -> X509)?

    public func vauCertificate() async throws -> X509 {
        vauCertificateX509CallsCount += 1
        if let error = vauCertificateX509ThrowableError {
            throw error
        }
        if let vauCertificateX509Closure = vauCertificateX509Closure {
            return try await vauCertificateX509Closure()
        } else {
            return vauCertificateX509ReturnValue
        }
    }

    //MARK: - validate

    public var validateEeCertificateX509BoolThrowableError: (any Error)?
    public var validateEeCertificateX509BoolCallsCount = 0
    public var validateEeCertificateX509BoolCalled: Bool {
        return validateEeCertificateX509BoolCallsCount > 0
    }
    public var validateEeCertificateX509BoolReceivedEeCertificate: (X509)?
    public var validateEeCertificateX509BoolReceivedInvocations: [(X509)] = []
    public var validateEeCertificateX509BoolReturnValue: Bool!
    public var validateEeCertificateX509BoolClosure: ((X509) async throws -> Bool)?

    public func validate(eeCertificate: X509) async throws -> Bool {
        validateEeCertificateX509BoolCallsCount += 1
        validateEeCertificateX509BoolReceivedEeCertificate = eeCertificate
        validateEeCertificateX509BoolReceivedInvocations.append(eeCertificate)
        if let error = validateEeCertificateX509BoolThrowableError {
            throw error
        }
        if let validateEeCertificateX509BoolClosure = validateEeCertificateX509BoolClosure {
            return try await validateEeCertificateX509BoolClosure(eeCertificate)
        } else {
            return validateEeCertificateX509BoolReturnValue
        }
    }

    //MARK: - reset

    public var resetVoidCallsCount = 0
    public var resetVoidCalled: Bool {
        return resetVoidCallsCount > 0
    }
    public var resetVoidClosure: (() -> Void)?

    public func reset() {
        resetVoidCallsCount += 1
        resetVoidClosure?()
    }


}
public class VAUAccessTokenProviderMock: VAUAccessTokenProvider {

    public init() {}

    public var vauBearerToken: AnyPublisher<BearerToken, VAUError> {
        get { return underlyingVauBearerToken }
        set(value) { underlyingVauBearerToken = value }
    }
    public var underlyingVauBearerToken: (AnyPublisher<BearerToken, VAUError>)!



}
class VAUCryptoMock: VAUCrypto {




    //MARK: - encrypt

    var encryptDataThrowableError: (any Error)?
    var encryptDataCallsCount = 0
    var encryptDataCalled: Bool {
        return encryptDataCallsCount > 0
    }
    var encryptDataReturnValue: Data!
    var encryptDataClosure: (() throws -> Data)?

    func encrypt() throws -> Data {
        encryptDataCallsCount += 1
        if let error = encryptDataThrowableError {
            throw error
        }
        if let encryptDataClosure = encryptDataClosure {
            return try encryptDataClosure()
        } else {
            return encryptDataReturnValue
        }
    }

    //MARK: - decrypt

    var decryptDataDataStringThrowableError: (any Error)?
    var decryptDataDataStringCallsCount = 0
    var decryptDataDataStringCalled: Bool {
        return decryptDataDataStringCallsCount > 0
    }
    var decryptDataDataStringReceivedData: (Data)?
    var decryptDataDataStringReceivedInvocations: [(Data)] = []
    var decryptDataDataStringReturnValue: String!
    var decryptDataDataStringClosure: ((Data) throws -> String)?

    func decrypt(data: Data) throws -> String {
        decryptDataDataStringCallsCount += 1
        decryptDataDataStringReceivedData = data
        decryptDataDataStringReceivedInvocations.append(data)
        if let error = decryptDataDataStringThrowableError {
            throw error
        }
        if let decryptDataDataStringClosure = decryptDataDataStringClosure {
            return try decryptDataDataStringClosure(data)
        } else {
            return decryptDataDataStringReturnValue
        }
    }


}
class VAUCryptoProviderMock: VAUCryptoProvider {




    //MARK: - provide

    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoThrowableError: (any Error)?
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoCallsCount = 0
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoCalled: Bool {
        return provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoCallsCount > 0
    }
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReceivedArguments: (message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken)?
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReceivedInvocations: [(message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken)] = []
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReturnValue: VAUCrypto!
    var provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoClosure: ((String, VAUCertificate, BearerToken) throws -> VAUCrypto)?

    func provide(for message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken) throws -> VAUCrypto {
        provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoCallsCount += 1
        provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReceivedArguments = (message: message, vauCertificate: vauCertificate, bearerToken: bearerToken)
        provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReceivedInvocations.append((message: message, vauCertificate: vauCertificate, bearerToken: bearerToken))
        if let error = provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoThrowableError {
            throw error
        }
        if let provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoClosure = provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoClosure {
            return try provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoClosure(message, vauCertificate, bearerToken)
        } else {
            return provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReturnValue
        }
    }


}
