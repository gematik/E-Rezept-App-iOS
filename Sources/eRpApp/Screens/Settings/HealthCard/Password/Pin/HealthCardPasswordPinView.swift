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

struct HealthCardPasswordPinView: View {
    @Perception.Bindable var store: StoreOf<HealthCardPasswordPinDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                PINView(store: store).padding()

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
                .disabled(!store.pinMayAdvance)
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: store.pinMayAdvance, destructive: false))
                .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.destination?.pinAlert, action: \.destination.pinAlert))
        }
    }

    private struct PINView: View {
        @Perception.Bindable var store: StoreOf<HealthCardPasswordPinDomain>

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.stgTxtCardResetPinHeadline)
                            .foregroundColor(Colors.systemLabel)
                            .font(.headline.bold())
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetPinHeadline)
                            .padding(.bottom)

                        PINField1View(store: store)

                        Text(L10n.stgTxtCardResetPinHint)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetPinHint)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        PINField2View(store: store)

                        if store.pinShowWarning {
                            Text(L10n.stgTxtCardResetPinWarning)
                                .font(.footnote)
                                .foregroundColor(Colors.red700)
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetPinWarning)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HintView(
                            hint: Hint<SettingsDomain.Action>(
                                id: A11y.settings.card.stgTxtCardResetPinHintMessage,
                                title: L10n.stgTxtCardResetPinHintTitle.text,
                                message: L10n.stgTxtCardResetPinHintMessage.text,
                                image: .init(name: Asset.Illustrations.infoLogo.name),
                                style: .neutral,
                                buttonStyle: .quaternary,
                                imageStyle: .topAligned
                            ),
                            textAction: nil,
                            closeAction: nil
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                }
                .fullScreenCover(
                    item: $store.scope(
                        state: \.destination?.readCard,
                        action: \.destination.readCard
                    )
                ) { store in
                    HealthCardPasswordReadCardView(store: store)
                }
            }
        }
    }

    private struct PINField1View: View {
        @Perception.Bindable var store: StoreOf<HealthCardPasswordPinDomain>
        @FocusState private var focused: Bool

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading) {
                    SecureFieldWithReveal(
                        titleKey: L10n.stgEdtCardResetPinInputPin1,
                        text: $store.pin1.sending(\.updatePin1),
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
                        .accessibility(identifier: A11y.settings.card.stgEdtCardResetPinInputPin1)
                }
            }
            .onAppear {
                focused = true
            }
        }
    }

    private struct PINField2View: View {
        @Perception.Bindable var store: StoreOf<HealthCardPasswordPinDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading) {
                    SecureFieldWithReveal(
                        titleKey: L10n.stgEdtCardResetPinInputPin2,
                        text: $store.pin2.sending(\.updatePin2),
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
                        .accessibility(identifier: A11y.settings.card.stgEdtCardResetPinInputPin2)
                }
            }
        }
    }
}

struct HealthCardPasswordPinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthCardPasswordPinView(
                store: HealthCardPasswordPinDomain.Dummies.store
            )
        }
    }
}
