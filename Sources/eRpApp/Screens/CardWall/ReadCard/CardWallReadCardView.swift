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

import AVKit
import Combine
import ComposableArchitecture
import SwiftUI

struct CardWallReadCardView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let store: CardWallReadCardDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                InformationBlockView(store: store)

                Spacer(minLength: 0)

                GreyDivider()

                LoadingPrimaryButton(
                    text: viewStore.output.buttonTitle,
                    isLoading: !viewStore.output.nextButtonEnabled
                ) {
                    viewStore.send(viewStore.output.nextAction)
                }
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcNext)
                .accessibility(hint: Text(L10n.cdwBtnRcNextHint))
                .padding([.horizontal, .vertical])
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtRcDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtRcTitle, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomNavigationBackButton(presentationMode: presentationMode),
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcCancel)
                .accessibility(label: Text(L10n.cdwBtnRcCancelLabel))
            )
            .onAppear {
                viewStore.send(.getChallenge)
            }
            .onDisappear {}
        }
    }
}

extension CardWallReadCardView {
    // MARK: - screen related views

    private struct InformationBlockView: View {
        let store: CardWallReadCardDomain.Store

        static var videoPlayer: AVPlayer? = {
            guard let bundle = Bundle.main.path(forResource: "eRezept_eGK", ofType: "mp4") else {
                return nil
            }
            let url = URL(fileURLWithPath: bundle)
            return AVPlayer(url: url)
        }()

        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.cdwTxtRcHeadline)
                        .font(Font.title2.bold())
                        .accessibility(identifier: A11y.cardWall.readCard.cdwTxtRcHeadline)
                    Text(L10n.cdwTxtRcDescription)
                        .font(.body)
                        .accessibility(identifier: A11y.cardWall.readCard.cdwTxtRcDescription)

                    VideoPlayer(player: Self.videoPlayer)
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .frame(minWidth: 100, maxWidth: .infinity)
                        .onAppear {
                            Self.videoPlayer?.play()
                        }
                        .cornerRadius(16, corners: .allCorners)

                    Text(L10n.cdwTxtRcStepsTitle)
                        .font(Font.title3.bold())
                        .foregroundColor(Colors.systemLabel)
                        .padding(.top, 32)

                    CardWallReadCardView.StepsBlockView(store: store)
                        .layoutPriority(1)
                }
                .foregroundColor(Color(.label))
                .padding([.horizontal])
                .padding(.top, 40)
            }
        }
    }
}

extension CardWallReadCardView {
    private struct StepsBlockView: View {
        let store: CardWallReadCardDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack(spacing: 16) {
                    ProgressTile(icon: SFSymbolName.numbers1circle,
                                 title: L10n.cdwTxtRcStepGetChallenge,
                                 description: nil,
                                 state: viewStore.output.challengeProgressTileState)
                    ProgressTile(icon: SFSymbolName.numbers2circle,
                                 title: L10n.cdwTxtRcStepSignChallenge,
                                 description: nil,
                                 state: viewStore.output.signingProgressTileState)
                    ProgressTile(icon: SFSymbolName.numbers3circle,
                                 title: L10n.cdwTxtRcStepVerifyAtIdp,
                                 description: nil,
                                 state: viewStore.output.verifyProgressTileState)
                }
            }
        }
    }
}

struct CardWallReadCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallReadCardView(
                store: CardWallReadCardDomain.Dummies.store
            )
        }
        .previewDevice("iPhone 11")
        .generateVariations()
    }
}
