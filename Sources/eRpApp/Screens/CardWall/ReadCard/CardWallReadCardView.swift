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
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
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

        // swiftlint:disable:next force_unwrapping
        let videoURL: URL = Bundle.main.url(forResource: "eRezept_eGK", withExtension: "mp4")!

        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.cdwTxtRcHeadline)
                        .font(Font.title3.bold())
                        .accessibility(identifier: A11y.cardWall.readCard.cdwTxtRcHeadline)
                    Text(L10n.cdwTxtRcDescription)
                        .font(.subheadline)
                        .accessibility(identifier: A11y.cardWall.readCard.cdwTxtRcDescription)

                    LoopingVideoPlayerContainerView(withURL: videoURL)
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .frame(minWidth: 100, maxWidth: .infinity)
                        .cornerRadius(16, corners: .allCorners)
                        .padding(.top, 28)
                }
                .foregroundColor(Color(.label))
                .padding([.horizontal])
                .padding(.top, 40)
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
    }
}
