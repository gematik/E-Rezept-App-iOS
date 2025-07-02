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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordCanView: View {
    @Perception.Bindable var store: StoreOf<HealthCardPasswordCanDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                CANView(store: store)

                Spacer(minLength: 0)

                GreyDivider()

                if store.mode == .forgotPin {
                    // Unlock card and set new secret
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .navigationDestination(
                            item: $store.scope(
                                state: \.destination?.puk,
                                action: \.destination.puk
                            )
                        ) { store in
                            HealthCardPasswordPukView(store: store)
                        }
                        .accessibility(hidden: true)
                }

                if store.mode == .setCustomPin {
                    // Set custom PIN
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .navigationDestination(
                            item: $store.scope(
                                state: \.destination?.oldPin,
                                action: \.destination.oldPin
                            )
                        ) { store in
                            HealthCardPasswordOldPinView(store: store)
                        }
                        .accessibility(hidden: true)
                }

                if store.mode == .unlockCard {
                    // Unlock card
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .navigationDestination(
                            item: $store.scope(
                                state: \.destination?.puk,
                                action: \.destination.puk
                            )
                        ) { store in
                            HealthCardPasswordPukView(store: store)
                        }
                        .accessibility(hidden: true)
                }

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
                .disabled(!store.canMayAdvance)
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: store.canMayAdvance, destructive: false))
                .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private struct CANView: View {
        @Perception.Bindable var store: StoreOf<HealthCardPasswordCanDomain>
        @State var showAnimation = true
        @State var scannedcan: ScanCAN?

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        if showAnimation {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(asset: Asset.CardWall.cardwallCard)
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
                        can: $store.can.sending(\.updateCan)
                        //                    can: store.binding(get: \.can) { .canUpdateCan($0) }
                    ) {}
                        .padding(.top)

                    TertiaryListButton(
                        text: L10n.cdwBtnCanScanner,
                        imageName: SFSymbolName.cameraViewfinder,
                        accessibilityIdentifier: A11y.cardWall.canInput.cdwBtnCanScan
                    ) {
                        store.send(.showScannerView)
                    }
                    .padding()
                    .fullScreenCover(isPresented: Binding<Bool>(
                        get: { store.state.destination == .scanner },
                        set: { show in
                            if !show {
                                store.send(.resetNavigation)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationStack {
                            CANCameraScanner(canScan: $scannedcan) { canScan in
                                if let canScan = scannedcan {
                                    store.send(.updateCan(canScan.value))
                                }
                                store.send(.resetNavigation)
                            }
                        }
                        .tint(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    })
                }
            }
            .onReceive(NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                    withAnimation {
                        showAnimation = false
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                UIApplication.shared.dismissKeyboard()
                withAnimation {
                    showAnimation = true
                }
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }
}

struct HealthCardPasswordCanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthCardPasswordCanView(
                store: HealthCardPasswordCanDomain.Dummies.store
            )
        }
    }
}
