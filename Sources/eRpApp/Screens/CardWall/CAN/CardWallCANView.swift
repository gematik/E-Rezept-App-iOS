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

import Combine
import CombineSchedulers
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import SwiftUI

struct CardWallCANView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let store: CardWallCANDomain.Store

    let nextView: () -> Content

    init(store: CardWallCANDomain.Store, @ViewBuilder nextView: @escaping () -> Content) {
        self.store = store
        self.nextView = nextView
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                CANView(store: store)

                NavigationLink(destination: nextView(),
                               isActive: viewStore.binding(
                                   get: \.showNextScreen,
                                   send: CardWallCANDomain.Action.reset
                               )) {
                    EmptyView()
                }.accessibility(hidden: true)

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnCanDone,
                                  a11y: A11y.cardWall.canInput.cdwBtnCanDone,
                                  isEnabled: viewStore.state.can.count == 6) {
                    viewStore.send(.advance)
                }.padding(.horizontal)
                    .padding(.bottom)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtCanDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtCanTitle, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomNavigationBackButton(presentationMode: presentationMode),
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.canInput.cdwBtnCanCancel)
                .accessibility(label: Text(L10n.cdwBtnCanCancelLabel))
            )
        }
    }

    private struct CANView: View {
        var store: CardWallCANDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    if viewStore.state.wrongCANEntered {
                        WorngCANEnteredWarningView().padding()
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtCanSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroHeaderBottom)
                            .padding()

                        HStack(alignment: .center) {
                            Spacer()
                            Image(Asset.CardWall.cardwallCard)
                                .frame(width: 231, height: 145, alignment: .center)
                                .accessibility(identifier: A11y.cardWall.canInput.cdwImgCanCard)
                                .accessibility(label: Text(L10n.cdwImgCanCardLabel))
                                .padding(.bottom, 24)
                            Spacer()
                        }

                        CardWallCANInputView(can: viewStore.binding(get: \.can) { .update(can: $0) }) {
                            viewStore.send(.advance)
                        }.padding(.horizontal)

                        Text(L10n.cdwTxtCanInputLabel)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInstruction)
                            .padding(.horizontal)

                        EmptyView()
                            .sheet(isPresented: viewStore.binding(
                                get: \.isEGKOrderInfoViewPresented,
                                send: CardWallCANDomain.Action.dismissEGKOrderInfoView
                            )) {
                                CardWallEGKOrderInfoView {
                                    viewStore.send(.dismissEGKOrderInfoView)
                                }
                            }

                        HintView<CardWallCANDomain.Action>(
                            hint: Hint(id: A11y.cardWall.canInput.cdwBtnCanMore,
                                       title: NSLocalizedString("cdw_hint_can_order_egk_title", comment: ""),
                                       message: NSLocalizedString("cdw_hint_can_order_egk_message", comment: ""),
                                       actionText: L10n.cdwHintCanOrderEgkBtn,
                                       action: CardWallCANDomain.Action.showEGKOrderInfoView,
                                       imageName: Asset.CardWall.apothekerin2.name,
                                       closeAction: nil,
                                       style: .neutral,
                                       buttonStyle: .tertiary,
                                       imageStyle: .bottomAligned),
                            textAction: { viewStore.send(.showEGKOrderInfoView) },
                            closeAction: nil
                        )
                        .padding()
                    }
                }.respectKeyboardInsets()
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
                ) {
                    EmptyView()
                }
            }.generateVariations()
        }
    }
}
