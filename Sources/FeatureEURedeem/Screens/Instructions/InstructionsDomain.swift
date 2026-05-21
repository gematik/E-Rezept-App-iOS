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

/// Domain for displaying instructions in EU prescription redemption
@Reducer
public struct InstructionsDomain {
    /// State for instructions screen
    @ObservableState
    public struct State: Equatable {
        /// First time redeeming shows instructions with redeem button
        public var isRedeeming: Bool
        /// Current country code
        public var countryCode: String?

        public init(
            isRedeeming: Bool = false,
            countryCode: String? = nil
        ) {
            self.isRedeeming = isRedeeming
            self.countryCode = countryCode
        }
    }

    /// Actions for instructions screen
    @CasePathable
    public enum Action: Equatable {
        /// Delegate actions to parent
        case delegate(Delegate)

        /// Delegate actions
        public enum Delegate: Equatable {
            case close
            /// Continue button was tapped
            case continueButtonTapped
        }
    }

    /// Initialize the domain
    public init() {}

    /// Reducer body
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
