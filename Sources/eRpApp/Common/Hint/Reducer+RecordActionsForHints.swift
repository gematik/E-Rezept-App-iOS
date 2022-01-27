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

import ComposableArchitecture

extension Reducer where Action == AppDomain.Action, State == AppDomain.State, Environment == AppDomain.Environment {
    /// Higher order reducer that adds functionality to self. All relevant actions for hints can be handled here
    /// Use `recordActionsBeforeStateChange` for tracking all events before self did run
    /// Use `recordActionsAfterStateChange` for tracking all events after self did run
    /// - Returns: combines self with the HintsState reducer
    func recordActionsForHints() -> Self {
        .combine(
            recordActionsBeforeStateChange(),
            self,
            recordActionsAfterStateChange()
        )
    }

    private func recordActionsBeforeStateChange() -> Self {
        .init { _, _, _ in .none }
    }

    private func recordActionsAfterStateChange() -> Self {
        .init { state, action, environment in
            switch action {
            case let .unreadMessagesReceived(unreadMessageCount):
                if unreadMessageCount > 0 {
                    environment.userSession.hintEventsStore.hintState.hasUnreadMessages = true
                } else {
                    environment.userSession.hintEventsStore.hintState.hasUnreadMessages = false
                }
            case .main(action: .settings(action: .toggleDemoModeSwitch)):
                environment.userSession.hintEventsStore.hintState.hasDemoModeBeenToggledBefore = true
            case .main(action: .scanner(action: .saveAndClose)):
                environment.userSession.hintEventsStore.hintState.hasScannedPrescriptionsBefore = true
            case .main(action: .prescriptionList(action: .loadLocalGroupedPrescriptionsReceived)),
                 .main(action: .prescriptionList(action: .loadRemoteGroupedPrescriptionsAndSaveReceived)):
                if !state.main.prescriptionListState.groupedPrescriptions.isEmpty {
                    environment.userSession.hintEventsStore.hintState.hasTasksInLocalStore = true
                }
            case .main(action: .prescriptionList(action: .refresh)):
                // only set if we are in demo mode
                if environment.userSession.isDemoMode {
                    environment.userSession.hintEventsStore.hintState.hasCardWallBeenPresentedInDemoMode = true
                }
            default: break
            }
            return .none
        }
    }
}
