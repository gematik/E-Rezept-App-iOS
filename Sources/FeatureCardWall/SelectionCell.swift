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

import eRpResources
import eRpStyleKit
import SwiftUI

struct SelectionCell: View {
    let text: StringAsset
    let description: StringAsset?
    let a11y: String
    @ScaledMetric var iconSize: CGFloat = 22
    var systemImage: String?
    @Binding var isOn: Bool

    var body: some View {
        Button(
            action: { isOn.toggle() },
            label: {
                HStack {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .frame(width: iconSize)
                            .font(.body.weight(.semibold))
                            .foregroundColor(Colors.primary700)
                            .padding(.trailing)
                    }

                    VStack(alignment: .leading) {
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.body)
                            .foregroundColor(Colors.systemLabel)

                        if let description {
                            Text(description)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer()

                    Image(systemName: isOn ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                        .frame(width: iconSize)
                        .font(.body.weight(.semibold))
                        .foregroundColor(isOn ? Colors.primary700 : Colors.systemLabelSecondary)
                }
                .padding(.vertical)
            }
        )
        .accessibility(identifier: a11y)
        .accessibility(value: isOn ? Text(L10n.sectionTxtIsActiveValue) : Text(L10n.sectionTxtIsInactiveValue))
    }
}

struct SelectionCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SelectionCell(text: StringAsset("Lorem ipsum dolor sit amet", bundle: .main),
                          description: nil,
                          a11y: "dummy_a11y_1",
                          systemImage: SFSymbolName.cardIcon,
                          isOn: .constant(true))

            SelectionCell(text: StringAsset("Lorem ipsum dolor sit amet", bundle: .main),
                          description: StringAsset("""
                          Sed ut perspiciatis unde omnis\
                          iste natus error sit voluptatem\
                          accusantium doloremque laudantium.
                          """, bundle: .main),
                          a11y: "dummy_a11y_2",
                          systemImage: SFSymbolName.bell,
                          isOn: .constant(false))

                .preferredColorScheme(.dark)

            SelectionCell(text: StringAsset("Lorem ipsum dolor sit amet", bundle: .main),
                          description: StringAsset("Lorem ipsum dolor sit amet", bundle: .main),
                          a11y: "dummy_a11y_3",
                          systemImage: SFSymbolName.exclamationMark,
                          isOn: .constant(true))
                .preferredColorScheme(.dark)

            SelectionCell(text: StringAsset("Lorem ipsum dolor sit amet", bundle: .main),
                          description: StringAsset("""
                          Sed ut perspiciatis unde omnis\
                          iste natus error sit voluptatem\
                          accusantium doloremque laudantium.
                          """, bundle: .main),
                          a11y: "dummy_a11y_4",
                          isOn: .constant(false))

            Spacer()
        }
    }
}
