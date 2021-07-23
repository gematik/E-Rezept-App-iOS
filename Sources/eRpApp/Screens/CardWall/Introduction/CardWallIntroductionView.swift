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
import ComposableArchitecture
import SwiftUI

struct CardWallIntroductionView: View {
    let store: CardWallIntroductionDomain.Store
    let nextView: () -> AnyView

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                InformationBlockView()

                Spacer(minLength: 0)

                GreyDivider()

                Group {
                    PrimaryTextButton(text: L10n.cdwBtnIntroNext,
                                      a11y: A11y.cardWall.intro.cdwBtnIntroLater) {
                        viewStore.send(.advance(forward: true))
                    }.padding()

                    NavigationLink(
                        destination: nextView(),
                        isActive: viewStore.binding(
                            get: \.showNextScreen,
                            send: CardWallIntroductionDomain.Action.advance(forward:)
                        )
                    ) {
                        EmptyView()
                    }.accessibility(hidden: true)
                }
            }
            .navigationBarTitle(L10n.cdwTxtIntroHeaderTop, displayMode: .inline)
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
        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    Image(Asset.CardWall.cardwallInitial)
                        .resizable()
                        .scaledToFit()
                        .background(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
                            .foregroundColor(Colors.primary100))
                        .accessibility(identifier: A11y.cardWall.intro.cdwImgIntroMain)
                        .accessibility(label: Text(L10n.cdwImgIntroMainLabel))
                        .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.cdwTxtIntroHeaderBottom)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroHeaderBottom)

                        Text(L10n.cdwTxtIntroDescription)
                            .font(.body)
                            .foregroundColor(Colors.systemLabel)
                            .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroDescription)

                        NavigationLink(destination: CardWallEGKOrderHelpView()) {
                            Text(L10n.cdwBtnIntroMore)
                        }
                        .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroMore)

                        // Work around navigation bug when only one Navigation link is present
                        NavigationLink(destination: EmptyView()) {
                            EmptyView()
                        }.hidden()
                    }.padding()

                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.cdwTxtIntroListTitle)
                            .font(Font.body.weight(.semibold))
                            .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroListTitle)
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: SFSymbolName.checkmarkCircleFill)
                                .font(Font.title3.bold())
                                .foregroundColor(Colors.secondary600)
                            Text(L10n.cdwTxtIntroRequirementCard)
                                .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroRequirementCard)
                        }
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: SFSymbolName.checkmarkCircleFill)
                                .font(Font.title3.bold())
                                .foregroundColor(Colors.secondary600)
                            Text(L10n.cdwTxtIntroRequirementPin)
                                .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroRequirementPin)
                        }
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: SFSymbolName.checkmarkCircleFill)
                                .font(Font.title3.bold())
                                .foregroundColor(Colors.secondary600)
                            Text(L10n.cdwTxtIntroRequirementPhone)
                                .accessibility(identifier: A11y.cardWall.intro.cdwTxtIntroRequirementPhone)
                        }
                    }.padding(.horizontal)
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
                AnyView(EmptyView())
            }
        }.generateVariations()
    }
}
