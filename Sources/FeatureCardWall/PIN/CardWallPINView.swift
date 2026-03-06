//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import SwiftUI
import UIKit

public struct CardWallPINView: View {
    @Bindable var store: StoreOf<CardWallPINDomain>

    public init(store: StoreOf<CardWallPINDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading) {
            // [REQ:BSI-eRp-ePA:O.Purp_2#3,O.Data_6#4] PIN is used for eGK Connection
            PINView(store: store)

            Spacer()

            GreyDivider()

            Button {
                // workaround: dismiss keyboard to fix safearea bug for iOS 16
                if #available(iOS 16, *) {
                    UIApplication.shared.dismissKeyboard()
                }
                store.send(.advance(store.transition))
            } label: {
                Text(L10n.cdwBtnPinDone)
                    .accessibilityIdentifier(A11y.cardWall.pinInput.cdwBtnPinNoPin)
                    .accessibilityLabel(Text(L10n.cdwBtnPinDoneLabel))
            }
            .buttonStyle(.primary(isEnabled: store.enteredPINValid, width: .wideHugging))
            .frame(maxWidth: .infinity, alignment: .center)

            if store.transition == .push {
                Rectangle()
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.login, action: \.destination.login)
                    ) { store in
                        CardWallLoginOptionView(store: store)
                    }
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            } else {
                Rectangle()
                    .fullScreenCover(
                        item: $store.scope(state: \.destination?.login, action: \.destination.login)
                    ) { store in
                        CardWallLoginOptionView(store: store)
                    }
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            }
        }
        .demoBanner(isPresented: store.isDemoMode) {
            Text(L10n.cdwTxtPinDemoModeInfo)
        }
        .navigationBarTitle(L10n.cdwTxtPinTitle, displayMode: .inline)
        .navigationBarItems(
            trailing: Button {
                store.send(.delegate(.close))
            } label: {
                Text(L10n.navCancel)
            }
            .accessibility(identifier: A11y.cardWall.pinInput.cdwBtnPinCancel)
            .accessibility(label: Text(L10n.cdwBtnPinCancelLabel))
        )
    }

    private struct PINView: View {
        @Bindable var store: StoreOf<CardWallPINDomain>

        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    if store.wrongPinEntered {
                        WorngPINEnteredWarningView().padding()
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtPinSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinSubtitle)
                            .padding(.bottom, 16)
                            .accessibilityAddTraits(.isHeader)

                        Text(L10n.cdwTxtPinDescription)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwBtnPinNoPin)
                    }

                    Button {
                        store.send(.egkButtonTapped)
                    } label: {
                        Label(L10n.cdwBtnPinNoPin, systemImage: SFSymbolName.arrowForward)
                    }
                    .buttonStyle(.tertiary)
                    .labelStyle(.trailingIcon)
                    .fullScreenCover(item: $store
                        .scope(state: \.destination?.egk, action: \.destination.egk)) { store in
                            NavigationStack {
                                OrderHealthCardListView(store: store)
                            }
                            .tint(Colors.primary700)
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                    .padding([.bottom, .top], 6)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    PINFieldView(store: store) {
                        store.send(
                            .advance(.none),
                            animation: Animation.default
                        )
                    }.padding([.top, .bottom])

                    if !store.showWarning {
                        Text(L10n.cdwTxtPinHint)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinHint)
                            .frame(maxWidth: .infinity, alignment: .leading)

                    } else {
                        // PIN count out-of-bounds warn message // todo styling
                        HStack(spacing: 4) {
                            Image(systemName: SFSymbolName.exclamationMark)
                                .foregroundColor(Colors.alertNegativ)
                                .font(.footnote)

                            Text(store.warningMessage)
                                .font(.footnote)
                                .foregroundColor(Colors.alertNegativ)
                                .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinWarning)

                            Spacer()
                        }
                    }
                }
                .padding()
            }
        }
    }

    private struct PINFieldView: View {
        @Bindable var store: StoreOf<CardWallPINDomain>
        @FocusState private var focused: Bool

        init(store: StoreOf<CardWallPINDomain>, completion: @escaping () -> Void) {
            self.store = store
            self.completion = completion
        }

        let completion: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(
                    titleKey: L10n.cdwEdtPinInput,
                    accessibilityLabelKey: L10n.cdwTxtPinInputLabel,
                    text: $store.pin.sending(\.update),
                    textContentType: .password
                ) {}
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .accessibility(identifier: A11y.cardWall.pinInput.cdwEdtPinInput)
            }
            .onAppear {
                #if DEBUG
                // Disable focus on tests to avoid keyboard pop-up
                focused = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil
                #else
                focused = true
                #endif
            }
        }
    }

    private struct WorngPINEnteredWarningView: View {
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: SFSymbolName.exclamationMark)
                    .foregroundColor(Colors.red900)
                    .font(.title3)
                    .padding(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.cdwTxtPinWarnWrongTitle)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Colors.red900)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.cdwTxtPinWarnWrongDescription)
                        .font(Font.subheadline)
                        .foregroundColor(Colors.red900)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 16).fill(Colors.red100))
            .border(Colors.red300, width: 0.5, cornerRadius: 16)
        }
    }
}

struct CardWallPINView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                CardWallPINView(
                    store: CardWallPINDomain.Dummies.store
                )
            }
        }
    }
}
