//
//  Copyright (c) 2024 gematik GmbH
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

import Combine
import IDP

class PersistentExtAuthRequestStorage: ExtAuthRequestStorage {
    private var extAuthRequests: [String: ExtAuthChallengeSession] = [:]

    func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String) {
        extAuthRequests[state] = request
        _pendingExtAuthRequests.send(Array(extAuthRequests.values))
    }

    func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession? {
        extAuthRequests[state]
    }

    func reset() {
        extAuthRequests = [:]
        _pendingExtAuthRequests.send(Array(extAuthRequests.values))
    }

    private var _pendingExtAuthRequests = CurrentValueSubject<[ExtAuthChallengeSession], Never>([])

    var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> {
        _pendingExtAuthRequests
            .eraseToAnyPublisher()
    }
}

class DummyExtAuthRequestStorage: ExtAuthRequestStorage {
    func setExtAuthRequest(_: ExtAuthChallengeSession?, for _: String) {}

    func getExtAuthRequest(for _: String) -> ExtAuthChallengeSession? {
        nil
    }

    func reset() {}

    var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> = Just([]).eraseToAnyPublisher()
}
