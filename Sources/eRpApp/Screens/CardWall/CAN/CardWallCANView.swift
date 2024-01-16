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
import CombineSchedulers
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import SwiftUI

struct CardWallCANView: View {
    let store: CardWallCANDomain.Store

    struct ViewState: Equatable {
        let can: String
        let isDemoModus: Bool
        let destinationTag: CardWallCANDomain.Destinations.State.Tag?

        init(state: CardWallCANDomain.State) {
            can = state.can
            destinationTag = state.destination?.tag
            isDemoModus = state.isDemoModus
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                CANView(store: store)

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnCanDone,
                                  a11y: A11y.cardWall.canInput.cdwBtnCanDone,
                                  isEnabled: viewStore.state.can.count == 6) {
                    // workaround: dismiss keyboard to fix safearea bug for iOS 16
                    if #available(iOS 16, *) {
                        UIApplication.shared.dismissKeyboard()
                    }
                    viewStore.send(.advance)
                }.padding(.horizontal)

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: CardWallCANDomain.Action.destination),
                    state: /CardWallCANDomain.Destinations.State.pin,
                    action: CardWallCANDomain.Destinations.Action.pinAction(action:),
                    onTap: { viewStore.send(.setNavigation(tag: .pin)) },
                    destination: CardWallPINView.init(store:),
                    label: {}
                )
                .hidden()
                .accessibility(hidden: true)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtCanDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtCanTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.canInput.cdwBtnCanCancel)
                .accessibility(label: Text(L10n.cdwBtnCanCancelLabel))
            )
        }
    }

    private struct CANView: View {
        var store: CardWallCANDomain.Store
        @State var showAnimation = true
        @State var scannedcan: ScanCAN?

        struct ViewState: Equatable {
            let destinationTag: CardWallCANDomain.Destinations.State.Tag?
            let wrongCANEntered: Bool
            let can: String

            init(state: CardWallCANDomain.State) {
                destinationTag = state.destination?.tag
                wrongCANEntered = state.wrongCANEntered
                can = state.can
            }
        }

        var body: some View {
            WithViewStore(store, observe: ViewState.init) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    if viewStore.state.wrongCANEntered {
                        WorngCANEnteredWarningView()
                            .padding()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        if showAnimation {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(Asset.CardWall.cardwallCard)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 343, maxHeight: 215, alignment: .center)
                                    .accessibility(identifier: A11y.cardWall.canInput.cdwImgCanCard)
                                    .accessibility(label: Text(L10n.cdwImgCanCardLabel))
                                    .padding(.bottom, 24)
                                    .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                            removal: .move(edge: .leading)))

                                Spacer()
                            }
                        }
                        Text(L10n.cdwTxtCanSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title2)
                            .bold()
                            .padding(.top)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwTctCanHeader)

                        Text(L10n.cdwTxtCanDescription)
                            .foregroundColor(Colors.systemLabel)
                            .font(.body)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInstruction)

                        Button(action: {
                            viewStore.send(.setNavigation(tag: .egk))
                            UIApplication.shared.dismissKeyboard()
                        }, label: {
                            Text(L10n.cdwBtnNoCan)
                                .multilineTextAlignment(.trailing)
                        })
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.system(size: 16))
                            .foregroundColor(Colors.primary)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwBtnCanMore)
                            .fullScreenCover(isPresented: Binding<Bool>(
                                get: { viewStore.state.destinationTag == .egk },
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
                                        store.scope(
                                            state: \.$destination,
                                            action: CardWallCANDomain.Action.destination
                                        ),
                                        state: /CardWallCANDomain.Destinations.State.egk,
                                        action: CardWallCANDomain.Destinations.Action.egkAction(action:),
                                        then: OrderHealthCardListView.init(store:)
                                    )
                                    .accentColor(Colors.primary700)
                                    .navigationViewStyle(StackNavigationViewStyle())
                                }
                            })
                    }.padding()

                    // [REQ:BSI-eRp-ePA:O.Purp_2#2,O.Data_6#2] CAN is used for eGK connection
                    CardWallCANInputView(
                        can: viewStore.binding(get: \.can) { .update(can: $0) }
                    ) {
                        viewStore.send(.advance)
                    }.padding(.top)

                    TertiaryListButton(
                        text: L10n.cdwBtnCanScanner,
                        imageName: SFSymbolName.cameraViewfinder,
                        accessibilityIdentifier: A11y.cardWall.canInput.cdwBtnCanScan
                    ) {
                        viewStore.send(.showScannerView)
                    }
                    .padding()
                    .fullScreenCover(isPresented: Binding<Bool>(
                        get: { viewStore.state.destinationTag == .scanner },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationView {
                            CANCameraScanner(canScan: $scannedcan) { canScan in
                                if let canScan = scannedcan {
                                    viewStore.send(.update(can: canScan))
                                }
                                viewStore.send(.setNavigation(tag: .none))
                            }
                        }
                        .accentColor(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    })
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                        withAnimation {
                            showAnimation = false
                        }
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                        UIApplication.shared.dismissKeyboard()
                        withAnimation {
                            showAnimation = true
                        }
                }
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }

    private struct WorngCANEnteredWarningView: View {
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: SFSymbolName.exclamationMark)
                    .foregroundColor(Colors.red900)
                    .font(.title3)
                    .padding(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.cdwTxtCanWarnWrongTitle)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Colors.red900)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.cdwTxtCanWarnWrongDescription)
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

struct CardWallCANView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                CardWallCANView(
                    store: CardWallCANDomain.Dummies.store
                )
            }.generateVariations()
        }
    }
}
