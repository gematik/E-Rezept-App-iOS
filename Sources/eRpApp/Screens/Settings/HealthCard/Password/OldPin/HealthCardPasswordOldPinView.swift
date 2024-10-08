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
    @Perception.Bindable var store: StoreOf<HealthCardPasswordOldPinDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.stgTxtCardResetOldpinHeadline)
                            .foregroundColor(Colors.systemLabel)
                            .font(.headline.bold())
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetOldpinHeadline)
                            .padding(.bottom)

                        OldPinFieldView(store: store)

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

                Button(
                    action: {
                        // workaround: dismiss keyboard to fix safearea bug for iOS 16
                        if #available(iOS 16, *) {
                            UIApplication.shared.dismissKeyboard()
                        }
                        store.send(.advance)
                    },
                    label: { Text(L10n.stgBtnCardResetAdvance) }
                )
                .disabled(!store.oldPinMayAdvance)
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: store.oldPinMayAdvance, destructive: false))
                .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.pin,
                    action: \.destination.pin
                )
            ) { store in
                HealthCardPasswordPinView(store: store)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct OldPinFieldView: View {
        @Perception.Bindable var store: StoreOf<HealthCardPasswordOldPinDomain>
        @FocusState private var focused: Bool

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading) {
                    SecureFieldWithReveal(
                        titleKey: L10n.stgEdtCardResetOldpinInput,
                        text: $store.oldPin.sending(\.updateOldPin),
                        //                    text: binding.animation(),
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
                        .focused($focused)
                        .accessibility(identifier: A11y.settings.card.stgEdtCardResetOldpinInput)
                }
                .onAppear {
                    focused = true
                }
            }
        }
    }
}

struct HealthCardPasswordOldPinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthCardPasswordOldPinView(
                store: HealthCardPasswordOldPinDomain.Dummies.store
            )
        }
    }
}
