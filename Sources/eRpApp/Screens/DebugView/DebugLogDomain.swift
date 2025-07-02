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

#if ENABLE_DEBUG_VIEW
@Reducer
struct DebugLogDomain {
    enum Token: CaseIterable, Hashable {}

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail_sharePrescription
        case share(ShareSheetDomain)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?

        var log: DebugLiveLogger.RequestLog
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case share
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .share:
            state.destination = .share(ShareSheetDomain.State(string: state.log.shareText))
            return .none
        default:
            return .none
        }
    }

    var body: some ReducerOf<DebugLogDomain> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }
}
#endif
