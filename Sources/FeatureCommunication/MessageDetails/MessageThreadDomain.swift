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

/// The domain of the message detail view.
@Reducer
public struct MessageThreadDomain {
    /// The state of the message detail view.
    @ObservableState
    public struct State: Equatable {}

    /// The actions that can be performed in the message detail view.
    public enum Action: Equatable {}

    /// The reducer that handles the actions and updates the state of the message detail view.
    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {}
        }
    }
}

//
// extension MessageThreadDomain.Destination.State: Equatable {}
// extension MessageThreadDomain.Destination.Action: Equatable {}
