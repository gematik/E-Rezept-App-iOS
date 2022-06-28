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
import eRpStyleKit
import SwiftUI

struct CardWallIntroductionView<Content: View, Content2: View>: View {
    let store: CardWallIntroductionDomain.Store
    let nextView: () -> Content
    let fastTrackView: () -> Content2

    init(store: CardWallIntroductionDomain.Store,
         @ViewBuilder nextView: @escaping () -> Content,
         @ViewBuilder fastTrackView: @escaping () -> Content2) {
        self.store = store
        self.nextView = nextView
        self.fastTrackView = fastTrackView
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                InformationBlockView(store: store)

                Spacer(minLength: 0)

                GreyDivider()

                Group {
                    PrimaryTextButton(text: L10n.cdwBtnIntroNext,
                                      a11y: A11y.cardWall.intro.cdwBtnIntroLater) {
                        viewStore.send(.advance(forward: true))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    Button(action: {
                        viewStore.send(.advanceExtAuth(forward: true))
                    }, label: {
                        Group {
                            Text(L10n.cdwBtnIntroFasttrackLeading)
                                .foregroundColor(Color(.label)) +
                                Text(L10n.cdwBtnIntroFasttrackCenter) +
                                Text(L10n.cdwBtnIntroFasttrackTrailing)
                                .foregroundColor(Color(.label))
                        }
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom])
                        .frame(maxWidth: .infinity, alignment: .center)
                    })

                    NavigationLink(
                        destination: nextView(),
                        isActive: viewStore.binding(
                            get: \.showNextScreen,
                            send: CardWallIntroductionDomain.Action.advance(forward:)
                        )
                    ) {
                        EmptyView()
                    }.accessibility(hidden: true)

                    NavigationLink(
                        destination: fastTrackView(),
                        isActive: viewStore.binding(
                            get: \.showFastTrackScreen,
                            send: CardWallIntroductionDomain.Action.advanceExtAuth(forward:)
                        )
                    ) {
                        EmptyView()
                    }.accessibility(hidden: true)

                    NavigationLink(
                        destination: EmptyView(),
                        isActive: .constant(false)
                    ) {
                        EmptyView()
                    }.accessibility(hidden: true)
                }
            }
            .navigationBarTitle(L10n.cdwTxtIntroHeaderTop, displayMode: .large)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
                .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
            )
        }
    }
}

extension CardWallIntroductionView {
    // MARK: - screen related views

    private struct InformationBlockView: View {
        let store: CardWallIntroductionDomain.Store
        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.cdwTxtIntroDescriptionNew)
                                .font(.body)
                                .foregroundColor(Colors.systemLabel)
                                .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroDescription)

                            VStack(alignment: .leading, spacing: 16) {
                                Text(L10n.cdwTxtIntroNeededSubheadline)
                                    .font(Font.body.weight(.semibold))

                                Link(
                                    destination: URL( // swiftlint:disable:next line_length
                                        string: "https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten/woran-erkenne-ich-ob-ich-eine-nfc-faehige-gesundheitskarte-habe#c204"
                                    )! // swiftlint:disable:this force_unwrapping
                                ) {
                                    HStack {
                                        Label(title: {
                                            Text(L10n.cdwTxtIntroEgkCheckmark)
                                                .foregroundColor(Color(.label))
                                        }, icon: {
                                            Image(systemName: SFSymbolName.checkmarkCircleFill)
                                                .foregroundColor(Colors.secondary500)
                                                .font(.title3)
                                        })
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Image(systemName: SFSymbolName.info)
                                            .font(Font.title3)
                                    }
                                    .padding(16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                }

                                Label(title: {
                                    Text(L10n.cdwTxtIntroPinCheckmark)
                                }, icon: {
                                    Image(systemName: SFSymbolName.checkmarkCircleFill)
                                        .foregroundColor(Colors.secondary500)
                                        .font(.title3)
                                })
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)

                                VStack(spacing: 8) {
                                    Text(L10n.cdwTxtIntroFootnote)
                                        .foregroundColor(Color(.secondaryLabel))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Button(action: {
                                        viewStore.send(.showEGKOrderInfoView)
                                    }, label: {
                                        Text(L10n.cdwBtnIntroFootnote)
                                    })
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(Colors.primary)
                                        .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroMore)
                                        .fullScreenCover(isPresented: viewStore.binding(
                                            get: \.isEGKOrderInfoViewPresented,
                                            send: CardWallIntroductionDomain.Action.dismissEGKOrderInfoView
                                        )) {
                                            NavigationView {
                                                OrderHealthCardView {
                                                    viewStore.send(.dismissEGKOrderInfoView)
                                                }
                                            }
                                            .accentColor(Colors.primary600)
                                            .navigationViewStyle(StackNavigationViewStyle())
                                        }
                                }
                                .font(.subheadline)
                            }
                            .padding(.top, 32)
                        }.padding()
                    }
                }
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallIntroductionView(
                store: CardWallIntroductionDomain.Dummies.store
            ) {
                EmptyView()
            } fastTrackView: {
                EmptyView()
            }
        }
    }
}
