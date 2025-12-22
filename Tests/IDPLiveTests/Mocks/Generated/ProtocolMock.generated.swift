// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import HTTPClient
import IDP
import OpenSSL
import TrustStore

@testable import IDPLive

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
