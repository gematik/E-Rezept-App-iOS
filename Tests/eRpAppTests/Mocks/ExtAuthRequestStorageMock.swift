//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import IDP

// MARK: - ExtAuthRequestStorageMock -

final class ExtAuthRequestStorageMock: ExtAuthRequestStorage {
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
        return getExtAuthRequestForClosure.map { $0(state) } ?? getExtAuthRequestForReturnValue
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
