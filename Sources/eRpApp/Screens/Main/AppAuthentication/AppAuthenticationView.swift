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

import ComposableArchitecture
import SwiftUI

struct AppAuthenticationView: View {
    let store: AppAuthenticationDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                IfLetStore(
                    store.scope(
                        state: \.biometrics,
                        action: AppAuthenticationDomain.Action.biometrics(action:)
                    )
                ) {
                    AppAuthenticationWithBiometricsView(store: $0)
                }
            }.onAppear {
                viewStore.send(.loadAppAuthenticationOption)
            }
        }
    }
}

struct AppAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AppAuthenticationView(
            store: AppAuthenticationDomain.Store(
                initialState: AppAuthenticationDomain.State(),
                reducer: AppAuthenticationDomain.reducer,
                environment: AppAuthenticationDomain.Environment(
                    userDataStore: DemoSessionContainer().localUserStore,
                    schedulers: AppContainer.shared.schedulers,
                    appAuthenticationProvider:
                        AppAuthenticationDomain.DefaultAuthenticationProvider(
                            userDataStore: DemoSessionContainer().localUserStore
                        )
                )
            )
        )
    }
}
