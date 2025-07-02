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

import eRpStyleKit
import SwiftUI

/// sourcery: StringAssetInitialized
struct OptInCell: View {
    let text: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Button(
            action: { isOn.toggle() },
            label: {
                HStack {
                    Text(text, bundle: .module)
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
