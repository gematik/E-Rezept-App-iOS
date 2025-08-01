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
import CombineSchedulers
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import eRpStyleKit
import SwiftUI

struct CardWallCANView: View {
    @Perception.Bindable var store: StoreOf<CardWallCANDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 8) {
                CANView(store: store)

                Spacer()

                GreyDivider()

                Button {
                    // workaround: dismiss keyboard to fix safearea bug for iOS 16
                    UIApplication.shared.dismissKeyboard()
                    store.send(.advance)
                } label: {
                    Text(L10n.cdwBtnCanDone)
                        .accessibilityIdentifier(A11y.cardWall.canInput.cdwBtnCanDone)
                }
                .buttonStyle(.primary(isEnabled: store.state.can.count == 6, isDestructive: false, width: .wideHugging))
                .navigationDestination(
                    item: $store.scope(state: \.destination?.pin, action: \.destination.pin)
                ) { store in
                    CardWallPINView(store: store)
                }
            }
            .demoBanner(isPresented: store.isDemoModus) {
                Text(L10n.cdwTxtCanDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtCanTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    store.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.canInput.cdwBtnCanCancel)
                .accessibility(label: Text(L10n.cdwBtnCanCancelLabel))
            )
        }
    }

    private struct CANView: View {
        @Perception.Bindable var store: StoreOf<CardWallCANDomain>

        @State var showAnimation = true

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.vertical, showsIndicators: true) {
                    if store.state.wrongCANEntered {
                        WrongCANEnteredWarningView()
                            .padding()
                    }
                    VStack(alignment: .leading, spacing: 56) {
                        if showAnimation {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(asset: Asset.CardWall.cardwallCardWithArrow)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 343, maxHeight: 215, alignment: .center)
                                    .accessibility(identifier: A11y.cardWall.canInput.cdwImgCanCard)
                                    .accessibility(removeTraits: .isImage)
                                    .accessibility(label: Text(L10n.cdwImgCanCardLabel))
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading)
                                    ))

                                Spacer()
                            }
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.cdwTxtCanSubtitle)
                                .foregroundColor(Colors.systemLabel)
                                .font(.title)
                                .bold()
                                .accessibility(identifier: A11y.cardWall.canInput.cdwTctCanHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            CANScanButton(store: store)
                        }
                    }
                    .padding()

                    // [REQ:BSI-eRp-ePA:O.Purp_2#2,O.Data_6#2] CAN is used for eGK connection
                    CardWallCANInputView(
                        can: $store.can.sending(\.update)
                    ) {
                        store.send(.advance)
                    }

                    Text(L10n.cdwTxtCanDescription2)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .font(.footnote)
                        .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInstruction)
                        .padding(.horizontal)

                    Button(
                        action: {
                            store.send(.egkButtonTapped)
                            UIApplication.shared.dismissKeyboard()
                        }, label: {
                            HStack(spacing: 4) {
                                Text(L10n.cdwBtnNoCan2)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: SFSymbolName.arrowRight)
                            }
                            .foregroundColor(Colors.primary700)
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(size: 15))
                    .accessibility(identifier: A11y.cardWall.canInput.cdwBtnCanMore)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .fullScreenCover(item: $store
                        .scope(state: \.destination?.egk, action: \.destination.egk)) { store in
                            NavigationStack {
                                OrderHealthCardListView(store: store)
                                    .tint(Colors.primary700)
                                    .navigationViewStyle(StackNavigationViewStyle())
                            }
                    }
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

    private struct WrongCANEnteredWarningView: View {
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

    struct CANScanButton: View {
        @Perception.Bindable var store: StoreOf<CardWallCANDomain>
        @State var scannedcan: ScanCAN?

        var body: some View {
            WithPerceptionTracking {
                TertiaryListButton(
                    text: L10n.cdwBtnCanScanner2.key,
                    semiBold: true,
                    imageName: SFSymbolName.camera,
                    accessibilityIdentifier: A11y.cardWall.canInput.cdwBtnCanScan
                ) {
                    store.send(.showScannerView)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                .fullScreenCover(
                    isPresented: Binding<Bool>(
                        get: { store.destination == .scanner },
                        set: { show in
                            if !show {
                                store.send(.resetNavigation)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationStack {
                            CANCameraScanner(
                                canScan: $scannedcan,
                                onSuccessfulScanAction: {
                                    store.send(.successfulScan)
                                },
                                closeAction: { canScan in
                                    if let canScan = scannedcan {
                                        store.send(.update(can: canScan.value))
                                    }
                                    store.send(.resetNavigation)
                                }
                            )
                        }
                        .tint(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        CardWallCANView(store: CardWallCANDomain.Dummies.store)
    }
}
