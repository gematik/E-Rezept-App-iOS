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
import eRpKit
import SwiftUI

struct CardWallLoginSelectionView<EGK: View, KK: View>: View {
    let egkSubView: EGK
    let kkSubView: KK

    @State var selectedTile: Int?

    var firstBinding: Binding<Bool> {
        .init {
            selectedTile == 1
        } set: { _ in
            selectedTile = 1
        }
    }

    var secondBinding: Binding<Bool> {
        .init {
            selectedTile == 2
        } set: { _ in
            selectedTile = 2
        }
    }

    @State var egkEnabled = false
    @State var kkEnabled = false

    init(@ViewBuilder egk: () -> EGK, @ViewBuilder kkApp: () -> KK) {
        egkSubView = egk()
        kkSubView = kkApp()
    }

    @AppStorage("enable_fast_track_preview") var enableFastTrackPreview = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.cdwTxtSelHeadline)
                        .font(Font.title3.bold())

                    Text(L10n.cdwTxtSelDescription)

                    Tile(selected: firstBinding) {
                        VStack(spacing: 8) {
                            Image(decorative: Asset.Illustrations.arztRedCircle)

                            Text(L10n.cdwTxtSelEgkTitle)
                                .font(Font.headline.bold())
                            Text(L10n.cdwTxtSelEgkDescription)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibility(identifier: A11y.cardWall.select.cdwBtnSelEgk)
                    .padding(.top, 24)

                    if enableFastTrackPreview {
                        Tile(selected: .constant(false),
                             hideSelectionMark: true) {
                            VStack(spacing: 8) {
                                Image(decorative: Asset.Illustrations.mannkarteCircle)

                                Text(L10n.cdwTxtSelKkappComingSoonTitle)
                                    .font(Font.headline.bold())
                                    .foregroundColor(Color(.secondaryLabel))
                                Text(L10n.cdwTxtSelKkappComingSoonDescription)
                                    .font(.subheadline)
                                    .foregroundColor(Color(.tertiaryLabel))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibility(identifier: A11y.cardWall.select.cdwBtnSelKkapp)
                    } else {
                        Tile(selected: secondBinding) {
                            VStack(spacing: 8) {
                                Image(decorative: Asset.Illustrations.celebrationYellowCircle)

                                Text(L10n.cdwTxtSelKkappTitle)
                                    .font(Font.headline.bold())
                                Text(L10n.cdwTxtSelKkappDescription)
                                    .font(.subheadline)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibility(identifier: A11y.cardWall.select.cdwBtnSelKkapp)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle(L10n.cdwTxtSelTitle)
            .navigationBarTitleDisplayMode(.inline)

            GreyDivider()

            PrimaryTextButton(text: L10n.cdwBtnSelContinue,
                              a11y: A11y.cardWall.select.cdwBtnSelContinue,
                              isEnabled: selectedTile != nil) {
                guard let selectedTile = selectedTile else { return }

                switch selectedTile {
                case 1:
                    egkEnabled = true
                    kkEnabled = false
                case 2:
                    egkEnabled = false
                    kkEnabled = true
                default:
                    egkEnabled = false
                    kkEnabled = false
                }
            }
            .padding()

            NavigationLink(
                destination: egkSubView,
                isActive: $egkEnabled
            ) {
                EmptyView()
            }
            .accessibility(hidden: true)

            NavigationLink(
                destination: kkSubView,
                isActive: $kkEnabled
            ) {
                EmptyView()
            }
            .accessibility(hidden: true)

            // Dummy to work around SwiftUI Navigation bug on iOS <= 14.5
            NavigationLink(
                destination: EmptyView(),
                isActive: .constant(false)
            ) {
                EmptyView()
            }
            .accessibility(hidden: true)
        }
    }

    private struct Tile<Content: View>: View {
        @Binding var selected: Bool
        private let hideSelectionMark: Bool
        var content: () -> Content

        init(selected: Binding<Bool>, hideSelectionMark: Bool = false, @ViewBuilder content: @escaping () -> Content) {
            _selected = selected
            self.hideSelectionMark = hideSelectionMark
            self.content = content
        }

        var body: some View {
            Button(action: {
                selected.toggle()
            }, label: {
                ZStack(alignment: .topTrailing) {
                    content()
                        .frame(maxWidth: .infinity)

                    if !hideSelectionMark {
                        Image(systemName: selected ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                            .frame(minWidth: 24, minHeight: 24)
                            .foregroundColor(selected ? Colors.primary : Color(.tertiaryLabel))
                            .font(Font.title3)
                    }
                }
            })
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .border(selected ? Colors.primary : Colors.separator,
                        width: selected ? 2 : 0.5,
                        cornerRadius: 16)
                .buttonStyle(PlainButtonStyle())
        }
    }
}

struct CardWallLoginSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallLoginSelectionView {
                Text("EGK")
            } kkApp: {
                Text("KK")
            }
        }
    }
}
