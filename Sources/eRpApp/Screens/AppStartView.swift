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

// import Combine
import ComposableArchitecture
import SwiftUI

struct AppStartView: View {
    let store: AppStartDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            SwitchStore(store) {
                CaseLet(
                    state: /AppStartDomain.State.onboarding,
                    action: AppStartDomain.Action.onboarding(action:)
                ) { onboardingStore in
                    OnboardingContainer(store: onboardingStore)
                }
                CaseLet(
                    state: /AppStartDomain.State.app,
                    action: AppStartDomain.Action.app(action:)
                ) { appStore in
                    TabContainerView(store: appStore)
                }
                Default {
                    EmptyView()
                }
            }
            .onAppear {
                viewStore.send(.shouldHideOnboarding)
            }
        }
    }
}
