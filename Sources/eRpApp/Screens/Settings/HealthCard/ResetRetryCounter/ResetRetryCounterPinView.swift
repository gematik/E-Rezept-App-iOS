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

struct ResetRetryCounterPinView: View {
    let store: ResetRetryCounterDomain.Store
    @ObservedObject var viewStore: ViewStore<ResetRetryCounterDomain.State, ResetRetryCounterDomain.Action>

    init(store: ResetRetryCounterDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            PINView(store: store).padding()

            Spacer(minLength: 0)

            GreyDivider()

            Button(
                action: { viewStore.send(.advance) },
                label: { Text(L10n.stgBtnCardResetAdvance) }
            )
            .disabled(!viewStore.pinMayAdvance)
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: viewStore.pinMayAdvance, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private struct PINView: View {
        let store: ResetRetryCounterDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.stgTxtCardResetPinHeadline)
                            .foregroundColor(Colors.systemLabel)
                            .font(.headline.bold())
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetPinHeadline)
                            .padding(.bottom)

                        PINField1View(
                            binding: viewStore.binding(
                                get: \.newPin1,
                                send: ResetRetryCounterDomain.Action.pinUpdateNewPin1
                            )
                        )

                        Text(L10n.stgTxtCardResetPinHint)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetPinHint)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        PINField2View(
                            binding: viewStore.binding(
                                get: \.newPin2,
                                send: ResetRetryCounterDomain.Action.pinUpdateNewPin2
                            )
                        )

                        if viewStore.pinShowWarning {
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
                                image: .init(name: Asset.Illustrations.info.name),
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
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private struct PINField1View: View {
        let binding: Binding<String>

        var body: some View {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(
                    titleKey: L10n.stgEdtCardResetPinInputPin1,
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
                    .accessibility(identifier: A11y.settings.card.stgEdtCardResetPinInputPin1)
            }
        }
    }

    private struct PINField2View: View {
        let binding: Binding<String>

        var body: some View {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(
                    titleKey: L10n.stgEdtCardResetPinInputPin2,
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
                    .accessibility(identifier: A11y.settings.card.stgEdtCardResetPinInputPin2)
            }
        }
    }
}

struct ResetRetryCounterPinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResetRetryCounterPinView(
                store: ResetRetryCounterDomain.Dummies.store
            )
        }
    }
}
