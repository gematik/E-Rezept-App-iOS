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

// TODO: type with only optional values is strange, refactor swiftlint:disable:this todo
struct MedicationDetailCellView: View {
    let value: String?
    var subtitle: String?
    var title: LocalizedStringKey?
    var isLastInSection = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value ?? L10n.prscFdTxtNa.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                HStack {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                        Spacer()
                    } else if let title = title {
                        Text(title)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                        Spacer()
                    }
                }
            }

            if !isLastInSection {
                Divider()
            }
        }
        .padding(.leading)

        if isLastInSection {
            Divider()
        }
    }
}

struct MedicationDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationDetailCellView(value: "Filmtabletten",
                                     title: "Darreichungsform")
            MedicationDetailCellView(value: "Filmtabletten",
                                     title: "Darreichungsform",
                                     isLastInSection: true)
            Divider()
                .preferredColorScheme(.dark)
        }
    }
}
