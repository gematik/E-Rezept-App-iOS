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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI
import UIKit

struct CardWallPINView: View {
    let store: CardWallPINDomain.Store

    struct ViewState: Equatable {
        let routeTag: CardWallPINDomain.Destinations.State.Tag?
        let enteredPINValid: Bool
        let isDemoModus: Bool
        let transitionMode: CardWallPINDomain.TransitionMode

        init(state: CardWallPINDomain.State) {
            routeTag = state.destination?.tag
            enteredPINValid = state.enteredPINValid
            isDemoModus = state.isDemoModus
            transitionMode = state.transition
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack(alignment: .leading) {
                // [REQ:BSI-eRp-ePA:O.Purp_2#3,O.Data_6#4] PIN is used for eGK Connection
                PINView(store: store).padding()

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnPinDone,
                                  a11y: A11y.cardWall.pinInput.cdwBtnPinDone,
                                  isEnabled: viewStore.state.enteredPINValid) {
                    // workaround: dismiss keyboard to fix safearea bug for iOS 16
                    if #available(iOS 16, *) {
                        UIApplication.shared.dismissKeyboard()
                    }
                    viewStore.send(.advance(viewStore.transitionMode))
                }
                .accessibility(label: Text(L10n.cdwBtnPinDoneLabel))
                .padding(.horizontal)
                .padding(.bottom)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .login && viewStore.transitionMode == .fullScreenCover },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    NavigationView {
                        IfLetStore(
                            store.scope(state: \.$destination, action: CardWallPINDomain.Action.destination),
                            state: /CardWallPINDomain.Destinations.State.login,
                            action: CardWallPINDomain.Destinations.Action.login,
                            then: CardWallLoginOptionView.init(store:)
                        )
                    }
                    .accentColor(Colors.primary700)
                    .navigationViewStyle(StackNavigationViewStyle())
                })

                if viewStore.transitionMode == .push {
                    NavigationLinkStore(
                        store.scope(state: \.$destination, action: CardWallPINDomain.Action.destination),
                        state: /CardWallPINDomain.Destinations.State.login,
                        action: CardWallPINDomain.Destinations.Action.login,
                        onTap: { viewStore.send(.setNavigation(tag: .login)) },
                        destination: CardWallLoginOptionView.init(store:),
                        label: {}
                    )
                    .hidden()
                    .accessibility(hidden: true)
                }
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtPinDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtPinTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.pinInput.cdwBtnPinCancel)
                .accessibility(label: Text(L10n.cdwBtnPinCancelLabel))
            )
        }
    }

    private struct PINView: View {
        let store: CardWallPINDomain.Store

        struct ViewState: Equatable {
            let routeTag: CardWallPINDomain.Destinations.State.Tag?
            let wrongPinEntered: Bool
            let showWarning: Bool
            let warningMessage: String

            init(state: CardWallPINDomain.State) {
                routeTag = state.destination?.tag
                wrongPinEntered = state.wrongPinEntered
                showWarning = state.showWarning
                warningMessage = state.warningMessage
            }
        }

        var body: some View {
            WithViewStore(store, observe: ViewState.init) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    if viewStore.wrongPinEntered {
                        WorngPINEnteredWarningView().padding()
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtPinSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinSubtitle)
                            .padding(.bottom, 16)

                        Text(L10n.cdwTxtPinDescription)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwBtnPinNoPin)
                    }

                    Button(L10n.cdwBtnPinNoPin) {
                        viewStore.send(.setNavigation(tag: .egk))
                    }.fullScreenCover(isPresented: Binding<Bool>(
                        get: { viewStore.state.routeTag == .egk },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationView {
                            IfLetStore(
                                store.scope(state: \.$destination, action: CardWallPINDomain.Action.destination),
                                state: /CardWallPINDomain.Destinations.State.egk,
                                action: CardWallPINDomain.Destinations.Action.egkAction(action:),
                                then: OrderHealthCardListView.init(store:)
                            )
                        }
                        .accentColor(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    })
                        .padding([.bottom, .top], 6)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    PINFieldView(store: store) {
                        viewStore.send(
                            .advance(.none),
                            animation: Animation.default
                        )
                    }.padding([.top, .bottom])

                    if !viewStore.showWarning {
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

                            Text(viewStore.warningMessage)
                                .font(.footnote)
                                .foregroundColor(Colors.alertNegativ)
                                .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinWarning)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private struct PINFieldView: View {
        let store: CardWallPINDomain.Store
        @ObservedObject var viewStore: ViewStoreOf<CardWallPINDomain>

        init(store: CardWallPINDomain.Store, completion: @escaping () -> Void) {
            self.store = store
            viewStore = ViewStore(store) { $0 }
            self.completion = completion
        }

        let completion: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(
                    titleKey: L10n.cdwEdtPinInput,
                    accessibilityLabelKey: L10n.cdwTxtPinInputLabel,
                    text: viewStore.binding(get: \.pin, send: CardWallPINDomain.Action.update(pin:)).animation(),
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
                    .accessibility(identifier: A11y.cardWall.pinInput.cdwEdtPinInput)
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
            NavigationView {
                CardWallPINView(
                    store: CardWallPINDomain.Dummies.store
                )
            }
        }.generateVariations()
    }
}
