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

import AVKit
import Combine
import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CardWallReadCardView: View {
    @Perception.Bindable var store: StoreOf<CardWallReadCardDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    Text(L10n.cdwTxtRcCta)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                        .padding(.top, 48)
                        .padding(.horizontal)

                    Text(L10n.cdwTxtRcSubheadline)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.horizontal)
                        .padding(.bottom, 32)

                    NFCPhoneView()
                }
                .padding(.horizontal)

                Spacer()

                GreyDivider()

                Button {
                    store.send(store.output.nextAction)
                } label: {
                    Label {
                        Text(store.output.buttonTitle, bundle: .module)
                    } icon: {
                        if !store.output.nextButtonEnabled {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .buttonStyle(.primary(isEnabled: store.output.nextButtonEnabled))
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcNext)
                .accessibility(hint: Text(L10n.cdwBtnRcNextHint))
                .padding(.vertical)
            }
            .demoBanner(isPresented: store.isDemoModus) {
                Text(L10n.cdwTxtRcDemoModeInfo)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.send(.openHelpView)
                    }, label: {
                        HStack(alignment: .center) {
                            Image(systemName: SFSymbolName.questionmarkCircle)
                            Text(L10n.cdwBtnRcHelp)
                        }
                        .foregroundColor(Colors.textSecondary)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    })
                        .fullScreenCover(item: $store
                            .scope(state: \.destination?.help, action: \.destination.help)) { store in
                                NavigationStack {
                                    ReadCardHelpView(store: store)
                                }
                                .tint(Colors.primary700)
                                .navigationViewStyle(StackNavigationViewStyle())
                        }
                }
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .keyboardShortcut(.defaultAction) // workaround: this makes the alert's primary button bold
        }
        .statusBar(hidden: true)
    }

    struct NFCPhoneView: View {
        @State private var step1 = false
        @State private var step2 = false

        var body: some View {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Colors.primary100)
                        .frame(width: 210, height: 210, alignment: .leading)
                        .opacity(step2 ? 0 : 1)
                    Circle()
                        .fill(Colors.primary300)
                        .frame(width: 90, height: 90, alignment: .leading)
                        .opacity(step1 ? 0 : 1)
                }
                .task {
                    withAnimation(.easeInOut(duration: 0.45).delay(0.65).repeatForever(autoreverses: true)) {
                        step2.toggle()
                    }
                    withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                        step1.toggle()
                    }
                }
                Image(asset: Asset.CardReader.cardReadPosition1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 50)
                    .padding(.trailing, 35)
            }
        }
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
