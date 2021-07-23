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

import SwiftUI

struct Tile: View {
    var iconSystemName: String?
    var iconName: String?
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let discloseIcon: String
    var isDisabled = false

    var body: some View {
        HStack(spacing: 16) {
            HStack(alignment: .top, spacing: 0) {
                if let iconSystemName = iconSystemName {
                    Image(systemName: iconSystemName)
                        .frame(minWidth: 24, minHeight: 24)
                        .foregroundColor(isDisabled ? Color(.secondaryLabel) : Colors.primary500)
                        .font(Font.title3.bold())
                } else if let iconName = iconName {
                    Image(iconName)
                        .frame(minWidth: 24, minHeight: 24)
                        .foregroundColor(isDisabled ? Color(.secondaryLabel) : Colors.primary500)
                        .font(Font.title3.bold())
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(isDisabled ? Colors.systemLabelSecondary : Colors.systemLabel)
                    if let description = description {
                        Text(description)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                    }
                }
                .padding(.leading, 16)

                Spacer(minLength: 0)
            }
            .padding(0)

            Image(systemName: discloseIcon)
                .frame(minWidth: 24, minHeight: 24)
                .foregroundColor(Color(.tertiaryLabel))
                .font(Font.title3)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .border(Colors.separator, cornerRadius: 16)
    }
}

struct CheckboxTile_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Tile(iconSystemName: SFSymbolName.qrCode,
                     title: "Jetzt in Apotheke einlösen ",
                     description: "Sie stehen in einer Apotheke und möchten Ihr Rezept einlösen.",
                     discloseIcon: SFSymbolName.rightDisclosureIndicator)
                Spacer()
            }
            .padding()
            .previewLayout(.fixed(width: 375, height: 500.0))

            VStack {
                Tile(iconSystemName: SFSymbolName.qrCode,
                     title: "Jetzt in Apotheke einlösen ",
                     description: "Sie stehen in einer Apotheke und möchten Ihr Rezept einlösen.",
                     discloseIcon: SFSymbolName.rightDisclosureIndicator)
                Spacer()
            }
            .preferredColorScheme(.dark)
            .padding()
            .previewLayout(.fixed(width: 375, height: 500.0))

            VStack {
                Tile(iconSystemName: SFSymbolName.qrCode,
                     title: "Jetzt in Apotheke einlösen ",
                     description: "Sie stehen in einer Apotheke und möchten Ihr Rezept einlösen.",
                     discloseIcon: SFSymbolName.rightDisclosureIndicator)
                Spacer()
            }
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .padding()
            .previewLayout(.fixed(width: 375, height: 700.0))
        }
    }
}
