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

struct HealthCardPasswordCanView: View {
    let store: HealthCardPasswordDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, HealthCardPasswordDomain.Action>

    init(store: HealthCardPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let mode: HealthCardPasswordDomain.Mode
        let canMayAdvance: Bool
        let routeTag: HealthCardPasswordDomain.Route.Tag

        init(state: HealthCardPasswordDomain.State) {
            mode = state.mode
            canMayAdvance = state.canMayAdvance
            routeTag = state.route.tag
        }
    }

    var body: some View {
        VStack {
            CANView(store: store)

            Spacer(minLength: 0)

            GreyDivider()

            if viewStore.mode == .forgotPin {
                // Unlock card and set new secret
                NavigationLink(
                    isActive: .init(
                        get: {
                            viewStore.routeTag != .introduction &&
                                viewStore.routeTag != .can &&
                                viewStore.routeTag != .scanner
                        },
                        set: { active in
                            if active {
                                // is handled by store
                            } else {
                                viewStore.send(.setNavigation(tag: .can))
                            }
                        }
                    ),
                    destination: {
                        HealthCardPasswordPukView(store: store)
                    },
                    label: {
                        EmptyView()
                    }
                )
                .accessibility(hidden: true)
            }
            if viewStore.mode == .setCustomPin {
                // Set custom PIN
                NavigationLink(
                    isActive: .init(
                        get: {
                            viewStore.routeTag != .introduction &&
                                viewStore.routeTag != .can &&
                                viewStore.routeTag != .scanner
                        },
                        set: { active in
                            if active {
                                // is handled by store
                            } else {
                                viewStore.send(.setNavigation(tag: .can))
                            }
                        }
                    ),
                    destination: {
                        HealthCardPasswordOldPinView(store: store)
                    },
                    label: {
                        EmptyView()
                    }
                )
                .accessibility(hidden: true)
            }
            if viewStore.mode == .unlockCard {
                // Unlock card
                NavigationLink(
                    isActive: .init(
                        get: {
                            viewStore.routeTag != .introduction &&
                                viewStore.routeTag != .can &&
                                viewStore.routeTag != .scanner
                        },
                        set: { active in
                            if active {
                                // is handled by store
                            } else {
                                viewStore.send(.setNavigation(tag: .can))
                            }
                        }
                    ),
                    destination: {
                        HealthCardPasswordPukView(store: store)
                    },
                    label: {
                        EmptyView()
                    }
                )
                .accessibility(hidden: true)
            }

            Button(
                action: { viewStore.send(.advance) },
                label: { Text(L10n.stgBtnCardResetAdvance) }
            )
            .disabled(!viewStore.canMayAdvance)
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: viewStore.canMayAdvance, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private struct CANView: View {
        var store: HealthCardPasswordDomain.Store
        @State var showAnimation = true
        @State var scannedcan: ScanCAN?

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
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
                    }
                    .padding()

                    CardWallCANInputView(
                        can: viewStore.binding(get: \.can) { .canUpdateCan($0) }
                    ) {}
                        .padding(.top)

                    TertiaryListButton(
                        text: L10n.cdwBtnCanScanner,
                        imageName: SFSymbolName.camera,
                        accessibilityIdentifier: A11y.cardWall.canInput.cdwBtnCanScan
                    ) {
                        viewStore.send(.setNavigation(tag: .scanner))
                    }
                    .padding()
                    .fullScreenCover(isPresented: Binding<Bool>(
                        get: { viewStore.state.route == .scanner },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: .can))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationView {
                            CANCameraScanner(canScan: $scannedcan) { canScan in
                                if let canScan = scannedcan {
                                    viewStore.send(.canUpdateCan(canScan))
                                }
                                viewStore.send(.setNavigation(tag: .can))
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
            .respectKeyboardInsets()
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }
}

struct HealthCardPasswordCanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthCardPasswordCanView(
                store: HealthCardPasswordDomain.Dummies.store
            )
        }
    }
}
