//
//  Copyright (c) 2023 gematik GmbH
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
import SwiftUI
import UIKit

struct CardWallLoginOptionView: View {
    let store: StoreOf<CardWallLoginOptionDomain>

    struct ViewState: Equatable {
        let destinationTag: CardWallLoginOptionDomain.Destinations.State.Tag?
        let isDemoModus: Bool
        var selectedLoginOption = LoginOption.notSelected

        init(state: CardWallLoginOptionDomain.State) {
            destinationTag = state.destination?.tag
            isDemoModus = state.isDemoModus
            selectedLoginOption = state.selectedLoginOption
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack(alignment: .leading) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtBiometrySubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.loginOption.cdwTxtLoginOptionSubtitle)
                            .padding(.bottom, 16)
                    }

                    SelectionCell(
                        text: L10n.cdwTxtBiometryOptionBiometryTitle,
                        description: L10n.cdwTxtBiometryOptionBiometryDescription,
                        a11y: A11y.cardWall.loginOption.cdwTxtLoginOptionBiometry,
                        systemImage: SFSymbolName.faceId,
                        isOn: viewStore.binding(
                            get: { $0.selectedLoginOption.isWithBiometry },
                            send: .select(option: .withBiometry)
                        )
                        .animation()
                    )
                    .padding(.horizontal)
                    .border(Colors.systemGray5, cornerRadius: 16)

                    SelectionCell(
                        text: L10n.cdwTxtBiometryOptionNoneTitle,
                        description: L10n.cdwTxtBiometryOptionNoneDescription,
                        a11y: A11y.cardWall.loginOption.cdwTxtLoginOptionWithoutBiometry,
                        systemImage: SFSymbolName.rollback,
                        isOn: viewStore.binding(
                            get: { $0.selectedLoginOption.isWithoutBiometry },
                            send: .select(option: .withoutBiometry)
                        )
                        .animation()
                    )
                    .padding(.horizontal)
                    .border(Colors.systemGray5, cornerRadius: 16)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .hidden()
                        .accessibility(hidden: true)
                        .alert(
                            store.scope(state: \.$destination, action: CardWallLoginOptionDomain.Action.destination),
                            state: /CardWallLoginOptionDomain.Destinations.State.alert,
                            action: CardWallLoginOptionDomain.Destinations.Action.alert
                        )
                    PrivacyWarningViewContainer(store: store)
                }
                .padding()

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnBiometryContinue,
                                  a11y: A11y.cardWall.loginOption.cdwBtnLoginOptionContinue,
                                  isEnabled: viewStore.state.selectedLoginOption.hasSelection) {
                    viewStore.send(.advance)
                }
                .accessibility(label: Text(L10n.cdwBtnBiometryContinueLabel))
                .padding([.bottom, .leading, .trailing])

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: CardWallLoginOptionDomain.Action.destination),
                    state: /CardWallLoginOptionDomain.Destinations.State.readcard,
                    action: CardWallLoginOptionDomain.Destinations.Action.readcardAction(action:),
                    onTap: { viewStore.send(.setNavigation(tag: .readcard)) },
                    destination: CardWallReadCardView.init(store:),
                    label: {}
                )
                .hidden()
                .accessibility(hidden: true)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtBiometryDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtBiometryTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.loginOption.cdwBtnLoginOptionCancel)
                .accessibility(label: Text(L10n.cdwBtnBiometryCancelLabel))
            )
        }
    }

    // [REQ:gemSpec_IDP_Frontend:A_21574] Actual view
    // [REQ:BSI-eRp-ePA:O.Resi_1#3] View containing information regarding the login options.
    struct PrivacyWarningViewContainer: View {
        let store: StoreOf<CardWallLoginOptionDomain>

        struct ViewState: Equatable {
            let destinationTag: CardWallLoginOptionDomain.Destinations.State.Tag?

            init(state: CardWallLoginOptionDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            WithViewStore(store, observe: ViewState.init) { viewStore in
                VStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .fullScreenCover(isPresented: Binding<Bool>(
                            get: { viewStore.state.destinationTag == .warning },
                            set: { show in
                                if !show {
                                    viewStore.send(.setNavigation(tag: nil))
                                }
                            }
                        )) {
                            CardWallLoginOptionView.PrivacyWarningViewContainer.PrivacyWarningView {
                                viewStore.send(.acceptSecurityWarning)
                            }
                        }
                        .hidden()
                        .accessibility(hidden: true)
                }
            }
        }
    }
}

extension CardWallLoginOptionView.PrivacyWarningViewContainer {
    struct PrivacyWarningView: View {
        var confirm: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .center) {
                        Text(L10n.cdwTxtBiometrySecurityWarningTitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .bold()
                            .accessibility(
                                identifier: A11y.cardWall.loginOption.cdwTxtLoginOptionSecurityWarningTitle
                            )
                            .padding(.bottom, 16)

                        Spacer()

                        Text(L10n.cdwTxtBiometrySecurityWarningDescription)
                            .foregroundColor(Colors.systemLabel)
                            .font(.body)
                            .accessibility(
                                identifier: A11y.cardWall.loginOption.cdwTxtLoginOptionSecurityWarningDescription
                            )
                            .padding(.bottom, 16)
                    }
                }
                .padding()

                Spacer()

                GreyDivider()

                PrimaryTextButton(
                    text: L10n.cdwBtnBiometrySecurityWarningAccept,
                    a11y: A11y.cardWall.loginOption.cdwBtnLoginOptionSecurityWarningAccept
                ) {
                    confirm()
                }
                .accessibility(label: Text(L10n.cdwBtnBiometryContinueLabel))
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

struct CardWallBiometryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(["iPhone SE (1st generation)", "iPhone 11"], id: \.self) { deviceName in
                NavigationView {
                    CardWallLoginOptionView(
                        store: CardWallLoginOptionDomain.Dummies.store
                    )
                }
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
            }
        }
    }
}
