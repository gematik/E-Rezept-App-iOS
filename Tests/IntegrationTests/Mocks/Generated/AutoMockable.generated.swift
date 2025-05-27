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
import eRpKit
import OpenSSL
import TrustStore

@testable import Pharmacy
























public class TrustStoreSessionMock: TrustStoreSession {

    public init() {}



    //MARK: - loadVauCertificate

    public var loadVauCertificateAnyPublisherX509TrustStoreErrorCallsCount = 0
    public var loadVauCertificateAnyPublisherX509TrustStoreErrorCalled: Bool {
        return loadVauCertificateAnyPublisherX509TrustStoreErrorCallsCount > 0
    }
    public var loadVauCertificateAnyPublisherX509TrustStoreErrorReturnValue: AnyPublisher<X509, TrustStoreError>!
    public var loadVauCertificateAnyPublisherX509TrustStoreErrorClosure: (() -> AnyPublisher<X509, TrustStoreError>)?

    public func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        loadVauCertificateAnyPublisherX509TrustStoreErrorCallsCount += 1
        if let loadVauCertificateAnyPublisherX509TrustStoreErrorClosure = loadVauCertificateAnyPublisherX509TrustStoreErrorClosure {
            return loadVauCertificateAnyPublisherX509TrustStoreErrorClosure()
        } else {
            return loadVauCertificateAnyPublisherX509TrustStoreErrorReturnValue
        }
    }

    //MARK: - validate

    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorCallsCount = 0
    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorCalled: Bool {
        return validateCertificateX509AnyPublisherBoolTrustStoreErrorCallsCount > 0
    }
    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorReceivedCertificate: (X509)?
    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorReceivedInvocations: [(X509)] = []
    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorReturnValue: AnyPublisher<Bool, TrustStoreError>!
    public var validateCertificateX509AnyPublisherBoolTrustStoreErrorClosure: ((X509) -> AnyPublisher<Bool, TrustStoreError>)?

    public func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        validateCertificateX509AnyPublisherBoolTrustStoreErrorCallsCount += 1
        validateCertificateX509AnyPublisherBoolTrustStoreErrorReceivedCertificate = certificate
        validateCertificateX509AnyPublisherBoolTrustStoreErrorReceivedInvocations.append(certificate)
        if let validateCertificateX509AnyPublisherBoolTrustStoreErrorClosure = validateCertificateX509AnyPublisherBoolTrustStoreErrorClosure {
            return validateCertificateX509AnyPublisherBoolTrustStoreErrorClosure(certificate)
        } else {
            return validateCertificateX509AnyPublisherBoolTrustStoreErrorReturnValue
        }
    }

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
