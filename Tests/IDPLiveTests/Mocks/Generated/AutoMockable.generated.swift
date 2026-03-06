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
























public class ExtAuthRequestStorageMock: ExtAuthRequestStorage {

    public init() {}

    public var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> {
        get { return underlyingPendingExtAuthRequests }
        set(value) { underlyingPendingExtAuthRequests = value }
    }
    public var underlyingPendingExtAuthRequests: (AnyPublisher<[ExtAuthChallengeSession], Never>)!


    //MARK: - setExtAuthRequest

    public var setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidCallsCount = 0
    public var setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidCalled: Bool {
        return setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidCallsCount > 0
    }
    public var setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidReceivedArguments: (request: ExtAuthChallengeSession?, state: String)?
    public var setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidReceivedInvocations: [(request: ExtAuthChallengeSession?, state: String)] = []
    public var setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidClosure: ((ExtAuthChallengeSession?, String) -> Void)?

    public func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String) {
        setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidCallsCount += 1
        setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidReceivedArguments = (request: request, state: state)
        setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidReceivedInvocations.append((request: request, state: state))
        setExtAuthRequestRequestExtAuthChallengeSessionForStateStringVoidClosure?(request, state)
    }

    //MARK: - getExtAuthRequest

    public var getExtAuthRequestForStateStringExtAuthChallengeSessionCallsCount = 0
    public var getExtAuthRequestForStateStringExtAuthChallengeSessionCalled: Bool {
        return getExtAuthRequestForStateStringExtAuthChallengeSessionCallsCount > 0
    }
    public var getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedState: (String)?
    public var getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedInvocations: [(String)] = []
    public var getExtAuthRequestForStateStringExtAuthChallengeSessionReturnValue: ExtAuthChallengeSession?
    public var getExtAuthRequestForStateStringExtAuthChallengeSessionClosure: ((String) -> ExtAuthChallengeSession?)?

    public func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession? {
        getExtAuthRequestForStateStringExtAuthChallengeSessionCallsCount += 1
        getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedState = state
        getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedInvocations.append(state)
        if let getExtAuthRequestForStateStringExtAuthChallengeSessionClosure = getExtAuthRequestForStateStringExtAuthChallengeSessionClosure {
            return getExtAuthRequestForStateStringExtAuthChallengeSessionClosure(state)
        } else {
            return getExtAuthRequestForStateStringExtAuthChallengeSessionReturnValue
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
