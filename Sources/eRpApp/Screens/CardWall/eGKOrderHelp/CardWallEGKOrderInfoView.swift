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

struct CardWallEGKOrderInfoView: View {
    let closeAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: closeAction) {
                    Text(L10n.navClose)
                        .font(.body)
                        .foregroundColor(Colors.primary)
                }
                .accessibility(identifier: A11y.cardWall.orderEGKInfo.cdwBtnOrderEgkClose)
            }.padding(.bottom)

            ScrollView(.vertical, showsIndicators: true) {
                Text(L10n.cdwTxtOrderEgkInfoHeadline)
                    .font(Font.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                    .accessibility(identifier: A11y.cardWall.orderEGKInfo.cdwTxtOrderEgkInfoHeadline)

                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text(L10n.cdwTxtOrderEgkInfoText1)
                            .padding(.bottom, 8)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .top) {
                            Text(UnicodeCharacter.bullet)
                            Text(L10n.cdwTxtOrderEgkInfoText2)
                        }
                        .padding(.leading, 8)
                        .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .top) {
                            Text(UnicodeCharacter.bullet)
                            Text(L10n.cdwTxtOrderEgkInfoText3)
                        }
                        .padding(.leading, 8)
                        .fixedSize(horizontal: false, vertical: true)

                        Text(L10n.cdwTxtOrderEgkInfoText4)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)

                    Text(L10n.cdwTxtOrderEgkInfoFootnote)
                        .font(.caption)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    TertiaryListButton(
                        text: L10n.cdwTxtOrderEgkInfoButton,
                        imageName: nil,
                        accessibilityIdentifier: A11y.cardWall.orderEGKInfo.cdwBtnOrderEgkInfo
                    ) {
                        if let url = URL(string: NSLocalizedString("cdw_txt_order_egk_info_link", comment: "")) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .accessibility(identifier: A11y.cardWall.orderEGKInfo.cdwTxtOrderEgkTextblock)
            }
        }
        .padding()
    }
}

struct CardWallEGKOrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardWallEGKOrderInfoView {}
            CardWallEGKOrderInfoView {}
                .preferredColorScheme(.dark)
        }
    }
}
