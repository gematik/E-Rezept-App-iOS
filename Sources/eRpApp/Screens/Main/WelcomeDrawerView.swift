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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Introspect
import SwiftUI

struct WelcomeDrawerView: View {
    let store: MainDomain.Store

    @ObservedObject
    var viewStore: ViewStore<Void, MainDomain.Action>

    init(store: MainDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.stateless)
    }

    var body: some View {
        VStack {
            Section(header: HeaderView()) {
                Button(action: {
                    viewStore.send(.setNavigation(tag: .cardWall), animation: .easeInOut)
                }, label: {
                    HStack {
                        Spacer()
                        Text(L10n.wlcdBtnLogin)
                            .foregroundColor(Colors.primary600)
                            .bold()
                            .padding(.horizontal)
                            .padding()
                        Spacer()
                    }
                })
                    .background(Colors.primary100)
                    .cornerRadius(16)
                    .padding([.leading, .trailing])

                Button(action: {
                    viewStore.send(.setNavigation(tag: .none), animation: .easeInOut)
                }, label: {
                    HStack {
                        Spacer()
                        Text(L10n.wlcdBtnDecline)
                            .foregroundColor(Colors.primary600)
                            .bold()
                            .padding()
                            .padding(.horizontal)
                        Spacer()
                    }
                })
                    .cornerRadius(16)
                    .padding([.leading, .trailing])
            }
        }.background(Colors.systemBackground.ignoresSafeArea())
    }

    struct HeaderView: View {
        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Capsule()
                    .foregroundColor(Colors.systemLabelQuarternary)
                    .frame(width: 32, height: 8, alignment: .center)
                    .padding()

                Text(L10n.wlcdTxtHeader)
                    .bold()

                Text(L10n.wlcdTxtFooter)
                    .padding()
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.trailing, .leading])
            }
        }
    }
}

struct WelcomeDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeDrawerView(store: MainDomain.Dummies.store)
        }
    }
}
