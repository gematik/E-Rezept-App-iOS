//
//  Copyright (c) 2021 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import IDP

// MARK: - ExtAuthRequestStorageMock -

final class ExtAuthRequestStorageMock: ExtAuthRequestStorage {
    // MARK: - setExtAuthRequest

    var setExtAuthRequestForCallsCount = 0
    var setExtAuthRequestForCalled: Bool {
        setExtAuthRequestForCallsCount > 0
    }

    var setExtAuthRequestForReceivedArguments: (request: ExtAuthChallengeSession, state: String)?
    var setExtAuthRequestForReceivedInvocations: [(request: ExtAuthChallengeSession, state: String)] = []
    var setExtAuthRequestForClosure: ((ExtAuthChallengeSession, String) -> Void)?

    func setExtAuthRequest(_ request: ExtAuthChallengeSession, for state: String) {
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
}
