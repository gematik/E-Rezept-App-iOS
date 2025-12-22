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
import HTTPClient
import IDP
import OpenSSL
import TrustStore

@testable import IDPLive
























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
