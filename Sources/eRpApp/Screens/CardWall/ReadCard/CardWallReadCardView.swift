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

import AVKit
import Combine
import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CardWallReadCardView: View {
    let store: StoreOf<CardWallReadCardDomain>
    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        180 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    init(store: StoreOf<CardWallReadCardDomain>) {
        self.store = store
    }

    struct ViewState: Equatable {
        let destinationTag: CardWallReadCardDomain.Destinations.State.Tag?
        let output: CardWallReadCardDomain.State.Output
        let isDemoModus: Bool

        init(state: CardWallReadCardDomain.State) {
            destinationTag = state.destination?.tag
            output = state.output
            isDemoModus = state.isDemoModus
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Use overlay to also fill safe area but specify fixed height
                        VStack {}
                            .frame(width: nil, height: Self.height, alignment: .top)
                            .overlay(
                                HStack {
                                    Image(Asset.CardWall.onScreenEgk)
                                        .scaledToFill()
                                        .frame(width: nil, height: Self.height, alignment: .bottom)
                                }
                            )
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 2,
                                                       lineCap: CoreGraphics.CGLineCap.round,
                                                       lineJoin: CoreGraphics.CGLineJoin.round,
                                                       miterLimit: 2,
                                                       dash: [8, 8],
                                                       dashPhase: 0))
                            .foregroundColor(Color(.opaqueSeparator))
                            .frame(width: nil, height: 2, alignment: .center)
                    }
                    Text(L10n.cdwTxtRcPlacement)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(8)
                        .padding(.bottom, 16)

                    Text(L10n.cdwTxtRcCta)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding()

                    TertiaryButton(text: L10n.cdwBtnRcHelp.key, imageName: SFSymbolName.questionmarkCircle) {
                        viewStore.send(.openHelpViewScreen)
                    }
                    .fullScreenCover(isPresented: Binding<Bool>(
                        get: { viewStore.state.destinationTag == .help },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        NavigationView {
                            IfLetStore(
                                store.destinationsScope(state: /CardWallReadCardDomain.Destinations.State.help),
                                then: ReadCardHelpView.init(store:)
                            )
                        }
                        .accentColor(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    })
                    .padding()
                }
                Spacer()

                GreyDivider()

                Button {
                    viewStore.send(viewStore.output.nextAction)
                } label: {
                    Label {
                        Text(viewStore.output.buttonTitle)
                    } icon: {
                        if !viewStore.output.nextButtonEnabled {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .buttonStyle(.primary(isEnabled: viewStore.output.nextButtonEnabled))
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcNext)
                .accessibility(hint: Text(L10n.cdwBtnRcNextHint))
                .padding(.vertical)

                Button(action: {
                    viewStore.send(.delegate(.singleClose))
                }, label: {
                    Label(title: { Text(L10n.cdwBtnRcBack) }, icon: {})
                })
                    .buttonStyle(.secondary)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtRcDemoModeInfo)
            }
            .alert(
                store.destinationsScope(state: /CardWallReadCardDomain.Destinations.State.alert),
                dismiss: .setNavigation(tag: .none)
            )
            .keyboardShortcut(.defaultAction) // workaround: this makes the alert's primary button bold
            .onAppear {
                viewStore.send(.getChallenge)
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }

    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
            return path
        }
    }
}

struct CardWallReadCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<CardWallReadCardView> {
            CardWallReadCardView(
                store: CardWallReadCardDomain.Dummies.store
            )
        }
        .previewDevice("iPhone 11")
    }
}
