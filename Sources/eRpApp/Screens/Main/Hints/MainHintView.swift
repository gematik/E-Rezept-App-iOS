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

struct MainHintView: View {
    let store: MainViewHintsDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                if let hint = viewStore.hint {
                    HintView<MainViewHintsDomain.Action>(
                        hint: hint,
                        textAction: {
                            if let action = hint.action {
                                viewStore.send(action)
                            }
                        },
                        closeAction: {
                            if let action = hint.closeAction {
                                viewStore.send(action)
                            }
                        }
                    )
                }
            }
            .onAppear { viewStore.send(.subscribeToHintChanges) }
            .onDisappear { viewStore.send(.removeSubscription) }
        }
    }
}

struct MainHintView_Previews: PreviewProvider {
    static var previews: some View {
        MainHintView(store: MainViewHintsDomain.Dummies.store(with: .neutral))
    }
}
