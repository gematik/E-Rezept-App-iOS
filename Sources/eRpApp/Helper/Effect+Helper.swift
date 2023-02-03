//
//  Copyright (c) 2023 gematik GmbH
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

import ComposableArchitecture
import Foundation

// Source: https://forums.swift.org/t/ifletstore-and-effect-cancellation-on-view-disappear/38272/23
extension Effect {
    static func cancel<T>(token: T.Type) -> Effect<Action, Never> where T: CaseIterable, T: Hashable {
        .merge(token.allCases.map(Effect.cancel(id:)))
    }
}
