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

struct DetailedIconCellView: View {
    let title: LocalizedStringKey
    let value: String
    let imageName: String
    let a11y: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Text(value)
                        .foregroundColor(Colors.primary)
                }
                Spacer()
                Image(systemName: imageName)
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Colors.primary)

            }.fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Divider()
        }
    }
}
