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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordPukView: View {
    let store: HealthCardPasswordDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, HealthCardPasswordDomain.Action>

    init(store: HealthCardPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let withNewPin: Bool
        let pukMayAdvance: Bool
        let routeTag: HealthCardPasswordDomain.Route.Tag

        init(state: HealthCardPasswordDomain.State) {
            withNewPin = state.withNewPin
            pukMayAdvance = state.pukMayAdvance
            routeTag = state.route.tag
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.stgTxtCardResetPukHeadline)
                        .foregroundColor(Colors.systemLabel)
                        .font(.headline.bold())
                        .accessibility(identifier: A11y.settings.card.stgTxtCardResetPukHeadline)
                        .padding(.bottom)

                    PUKFieldView(store: store)

                    Text(L10n.stgTxtCardResetPukHint)
                        .font(.footnote)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibility(identifier: A11y.settings.card.stgTxtCardResetPukHint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()

            Spacer(minLength: 0)

            GreyDivider()

            // TODO: next MR if viewStore.mode == .withNewPin // swiftlint:disable:this todo
//            if viewStore.withNewPin {
//                NavigationLink(
//                    isActive: .init(
//                        get: {
//                            viewStore.state.route != .introduction &&
//                                viewStore.state.route != .can &&
//                                viewStore.state.route != .puk
//                        },
//                        set: { active in
//                            if active {
//                                // is handled by button below
//                            } else {
//                                viewStore.send(.setNavigation(tag: .puk))
//                            }
//                        }
//                    ),
//                    destination: {
//                        HealthCardPasswordPinView(store: store)
//                    },
//                    label: {
//                        EmptyView()
//                    }
//                )
//                .accessibility(hidden: true)
//            }

            Button(
                action: { viewStore.send(.advance) },
                label: { Text(L10n.stgBtnCardResetAdvance) }
            )
            .disabled(!viewStore.pukMayAdvance)
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: viewStore.pukMayAdvance, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct PUKFieldView: View {
        let store: HealthCardPasswordDomain.Store

        var body: some View {
            VStack(alignment: .leading) {
                WithViewStore(store) { viewStore in
                    SecureFieldWithReveal(
                        titleKey: L10n.stgEdtCardResetPukInput,
                        accessibilityLabelKey: L10n.stgEdtCardResetPukInputLabel,
                        text: viewStore.binding(get: \.puk, send: HealthCardPasswordDomain.Action.pukUpdatePuk)
                            .animation(),
                        textContentType: .password,
                        backgroundColor: Colors.systemGray5
                    ) {}
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.numberPad)
                        .padding()
                        .font(Font.title3)
                        .background(Colors.systemGray5)
                        .cornerRadius(8)
                        .textFieldKeepFirstResponder()
                        .accessibility(identifier: A11y.settings.card.stgEdtCardResetPukInput)
                }
            }
        }
    }
}

struct HealthCardPasswordPukView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthCardPasswordPukView(
                store: HealthCardPasswordDomain.Dummies.store
            )
        }
    }
}
