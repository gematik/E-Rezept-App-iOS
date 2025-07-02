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

import ComposableArchitecture

extension Reducer
    where Self.Action == AppStartDomain.Action, Self.State == AppStartDomain.State {
    func analytics()
        -> some Reducer<Self.State, Self.Action> {
        AnalyticsReducer(wrapping: self)
    }
}

// [REQ:BSI-eRp-ePA:O.Purp_2#4,O.Purp_4#1,O.Data_6#6] User interaction analytics trigger ...
struct AnalyticsReducer<ContentReducer: Reducer>: Reducer
    where ContentReducer.Action == AppStartDomain.Action, ContentReducer.State == AppStartDomain.State {
    typealias State = ContentReducer.State
    typealias Action = ContentReducer.Action

    var wrapping: ContentReducer

    @Dependency(\.tracker) var tracker: Tracker

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            let route = state.routeName()

            let result = wrapping.reduce(into: &state, action: action)

            if let newRoute = state.routeName(),
               newRoute != route {
                #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
                print("Route tag:", newRoute)
                #endif
                // [REQ:gemSpec_eRp_FdV:A_19093-01#2] Very sparse usage of actual tracking boils down to this call where
                // only displayed screens are tracked
                tracker.track(screen: newRoute)
            }

            return result
        }
    }
}
