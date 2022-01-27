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

import SwiftUI

struct OptInCell: View {
    let text: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Button(
            action: { isOn.toggle() },
            label: {
                HStack {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(Colors.text)

                    Spacer()

                    Image(systemName: isOn ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                        .font(.title2)
                        .foregroundColor(isOn ? Colors.primary500 : Colors.systemLabelTertiary)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .padding()
            }
        )
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .accessibility(value: isOn ? Text(L10n.sectionTxtIsActiveValue) : Text(L10n.sectionTxtIsInactiveValue))
    }
}

struct OptInCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                OptInCell(text: "Lorem ipsum dolor sit amet",
                          isOn: .constant(true))
                Spacer()
            }
            .background(Color.orange)

            VStack {
                Spacer()
                OptInCell(text: "Lorem ipsum dolor sit amet",
                          isOn: .constant(false))
                Spacer()
            }
            .preferredColorScheme(.dark)
            .background(Color.orange)

            VStack {
                Spacer()
                OptInCell(text: "Lorem ipsum dolor sit amet",
                          isOn: .constant(true))
                Spacer()
            }
            .preferredColorScheme(.dark)
            .background(Color.orange)

            VStack {
                Spacer()
                OptInCell(text: "Lorem ipsum dolor sit amet",
                          isOn: .constant(false))
                Spacer()
            }
            .background(Color.orange)
        }
        .previewLayout(.fixed(width: 400.0,
                              height: 200.0))
    }
}
