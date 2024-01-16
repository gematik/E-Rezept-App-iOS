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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordOldPinView: View {
    let store: HealthCardPasswordDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, HealthCardPasswordDomain.Action>

    init(store: HealthCardPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let oldPin: String
        let oldPinMayAdvance: Bool
        let destinationTag: HealthCardPasswordDomain.Destinations.State.Tag?

        init(state: HealthCardPasswordDomain.State) {
            oldPin = state.oldPin
            oldPinMayAdvance = state.oldPinMayAdvance
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.stgTxtCardResetOldpinHeadline)
                        .foregroundColor(Colors.systemLabel)
                        .font(.headline.bold())
                        .accessibility(identifier: A11y.settings.card.stgTxtCardResetOldpinHeadline)
                        .padding(.bottom)

                    OldPinFieldView(
                        binding: viewStore.binding(
                            get: \.oldPin,
                            send: HealthCardPasswordDomain.Action.oldPinUpdateOldPin
                        )
                    )

                    Text(L10n.stgTxtCardResetOldpinHint)
                        .font(.footnote)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibility(identifier: A11y.settings.card.stgTxtCardResetOldpinHint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()

            Spacer(minLength: 0)

            GreyDivider()

            NavigationLink(
                isActive: .init(
                    get: {
                        viewStore.destinationTag != .introduction &&
                            viewStore.destinationTag != .can &&
                            viewStore.destinationTag != .puk &&
                            viewStore.destinationTag != .oldPin
                    },
                    set: { active in
                        if active {
                            // is handled by button below
                        } else {
                            viewStore.send(.setNavigation(tag: .oldPin))
                        }
                    }
                ),
                destination: {
                    HealthCardPasswordPinView(store: store)
                },
                label: {
                    EmptyView()
                }
            )
            .accessibility(hidden: true)

            Button(
                action: {
                    // workaround: dismiss keyboard to fix safearea bug for iOS 16
                    if #available(iOS 16, *) {
                        UIApplication.shared.dismissKeyboard()
                    }
                    viewStore.send(.advance)
                },
                label: { Text(L10n.stgBtnCardResetAdvance) }
            )
            .disabled(!viewStore.oldPinMayAdvance)
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: viewStore.oldPinMayAdvance, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct OldPinFieldView: View {
        let binding: Binding<String>

        var body: some View {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(
                    titleKey: L10n.stgEdtCardResetOldpinInput,
                    text: binding.animation(),
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
                    .accessibility(identifier: A11y.settings.card.stgEdtCardResetOldpinInput)
            }
        }
    }
}

struct HealthCardPasswordOldPinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthCardPasswordOldPinView(
                store: HealthCardPasswordDomain.Dummies.store
            )
        }
    }
}
