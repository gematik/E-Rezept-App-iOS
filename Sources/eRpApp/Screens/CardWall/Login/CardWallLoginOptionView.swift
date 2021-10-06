//
//  Copyright (c) 2021 gematik GmbH
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

struct CardWallLoginOptionView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let store: CardWallLoginOptionDomain.Store
    let nextView: () -> Content

    init(store: CardWallLoginOptionDomain.Store, @ViewBuilder nextView: @escaping () -> Content) {
        self.store = store
        self.nextView = nextView
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                PrivacyWarningView(store: store)

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
                }
                .padding()

                NavigationLink(
                    destination: nextView(),
                    isActive: viewStore.binding(
                        get: { $0.showNextScreen },
                        send: CardWallLoginOptionDomain.Action.navigateBack
                    )
                ) {
                    EmptyView()
                }.accessibility(hidden: true)

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnBiometryContinue,
                                  a11y: A11y.cardWall.loginOption.cdwBtnLoginOptionContinue,
                                  isEnabled: viewStore.state.selectedLoginOption.hasSelection) {
                    viewStore.send(.advance)
                }
                .accessibility(label: Text(L10n.cdwBtnBiometryContinueLabel))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtBiometryDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtBiometryTitle, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomNavigationBackButton(presentationMode: presentationMode)
                    .accessibility(identifier: A11y.cardWall.loginOption.cdwBtnLoginOptionBack),
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.loginOption.cdwBtnLoginOptionCancel)
                .accessibility(label: Text(L10n.cdwBtnBiometryCancelLabel))
            )
        }
    }

    // [REQ:gemSpec_IDP_Frontend:A_21574] Actual view
    private struct PrivacyWarningView: View {
        let store: CardWallLoginOptionDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack(alignment: .leading) {
                    EmptyView()
                        .sheet(isPresented: viewStore.binding(
                            get: { $0.isSecurityWarningPresented },
                            send: CardWallLoginOptionDomain.Action.dismissSecurityWarning
                        )) {
                            VStack(alignment: .leading) {
                                ScrollView(.vertical, showsIndicators: true) {
                                    VStack(alignment: .center) {
                                        Text(L10n.cdwTxtBiometrySecurityWarningTitle)
                                            .foregroundColor(Colors.systemLabel)
                                            .font(.title3)
                                            .bold()
                                            .accessibility(identifier: A11y.cardWall.loginOption
                                                .cdwTxtLoginOptionSecurityWarningTitle)
                                            .padding(.bottom, 16)

                                        Spacer()

                                        Text(L10n.cdwTxtBiometrySecurityWarningDescription)
                                            .foregroundColor(Colors.systemLabel)
                                            .font(.body)
                                            .accessibility(identifier: A11y.cardWall.loginOption
                                                .cdwTxtLoginOptionSecurityWarningDescription)
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
                                    viewStore.send(.acceptSecurityWarning)
                                }
                                .accessibility(label: Text(L10n.cdwBtnBiometryContinueLabel))
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                }
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
                    ) {
                        EmptyView()
                    }
                }
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
            }
        }
    }
}
