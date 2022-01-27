//
//  Copyright (c) 2022 gematik GmbH
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
import Foundation

// sourcery: StreamWrapped
protocol EventsStore: AnyObject {
    /// Publisher for the `HintState`. Use this interface for read access
    var hintStatePublisher: AnyPublisher<HintState, Never> { get }
    /// Provides write access for hintState. Do not use for read access. Use `hintStatePublisher` instead
    var hintState: HintState { get set }
}

/// Concrete implementation for storing `HintState`
class HintEventsStore: EventsStore {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        store: UserDefaults = UserDefaults.standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        userDefaults = store
        self.encoder = encoder
        self.decoder = decoder
    }

    var hintState: HintState {
        get {
            guard let hintData = userDefaults.hintState,
                  let hintState = HintState.from(hintData, decoder: decoder) else {
                return HintState()
            }
            return hintState
        }
        set {
            guard let data = newValue.asData(encoder: encoder) else { return }
            userDefaults.hintState = data
        }
    }

    var hintStatePublisher: AnyPublisher<HintState, Never> {
        userDefaults.publisher(for: \UserDefaults.hintState)
            .map { [weak self] dataOptional in
                guard let self = self,
                      let data = dataOptional,
                      let hintState = HintState.from(data, decoder: self.decoder) else {
                    return HintState()
                }

                return hintState
            }
            .eraseToAnyPublisher()
    }
}

extension UserDefaults {
    private static let kHintState = "kHintState"

    @objc var hintState: Data? {
        get { data(forKey: Self.kHintState) }
        set { set(newValue, forKey: Self.kHintState) }
    }
}
