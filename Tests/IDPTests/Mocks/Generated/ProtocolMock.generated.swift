// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import OpenSSL
import TrustStore

@testable import IDP

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockExtAuthRequestStorage -

final class MockExtAuthRequestStorage: ExtAuthRequestStorage {
    
   // MARK: - pendingExtAuthRequests

    var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> {
        get { underlyingPendingExtAuthRequests }
        set(value) { underlyingPendingExtAuthRequests = value }
    }
    var underlyingPendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never>!
    
   // MARK: - setExtAuthRequest

    var setExtAuthRequestForCallsCount = 0
    var setExtAuthRequestForCalled: Bool {
        setExtAuthRequestForCallsCount > 0
    }
    var setExtAuthRequestForReceivedArguments: (request: ExtAuthChallengeSession?, state: String)?
    var setExtAuthRequestForReceivedInvocations: [(request: ExtAuthChallengeSession?, state: String)] = []
    var setExtAuthRequestForClosure: ((ExtAuthChallengeSession?, String) -> Void)?

    func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String) {
        setExtAuthRequestForCallsCount += 1
        setExtAuthRequestForReceivedArguments = (request: request, state: state)
        setExtAuthRequestForReceivedInvocations.append((request: request, state: state))
        setExtAuthRequestForClosure?(request, state)
    }
    
   // MARK: - getExtAuthRequest

    var getExtAuthRequestForCallsCount = 0
    var getExtAuthRequestForCalled: Bool {
        getExtAuthRequestForCallsCount > 0
    }
    var getExtAuthRequestForReceivedState: String?
    var getExtAuthRequestForReceivedInvocations: [String] = []
    var getExtAuthRequestForReturnValue: ExtAuthChallengeSession?
    var getExtAuthRequestForClosure: ((String) -> ExtAuthChallengeSession?)?

    func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession? {
        getExtAuthRequestForCallsCount += 1
        getExtAuthRequestForReceivedState = state
        getExtAuthRequestForReceivedInvocations.append(state)
        return getExtAuthRequestForClosure.map({ $0(state) }) ?? getExtAuthRequestForReturnValue
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
