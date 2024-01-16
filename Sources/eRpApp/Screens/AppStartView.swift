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

// import Combine
import ComposableArchitecture
import SwiftUI

struct AppStartView: View {
    let store: AppStartDomain.Store

    @ObservedObject var viewStore: ViewStore<AppStartDomain.State, AppStartDomain.Action>

    init(store: AppStartDomain.Store) {
        self.store = store
        viewStore = ViewStore(store) {
            $0
        } removeDuplicates: { old, new in
            switch (old, new) {
            case (.onboarding, .onboarding),
                 (.app, .app):
                return true
            default:
                return false
            }
        }
    }

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .onboarding:
                CaseLet(
                    /AppStartDomain.State.onboarding,
                    action: AppStartDomain.Action.onboarding(action:)
                ) { onboardingStore in
                    OnboardingContainer(store: onboardingStore)
                }
            case .app:
                CaseLet(
                    /AppStartDomain.State.app,
                    action: AppStartDomain.Action.app(action:)
                ) { appStore in
                    TabContainerView(store: appStore)
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            viewStore.send(.refreshOnboardingState)
        }
    }
}
