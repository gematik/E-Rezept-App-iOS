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
import OpenSSL
import TrustStore

@testable import IDP
























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
