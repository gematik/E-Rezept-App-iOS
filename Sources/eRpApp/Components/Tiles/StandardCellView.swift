//
//  Copyright (c) 2024 gematik GmbH
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

struct StandardCellView: View {
    let title: String
    let value: String
    let a11y: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title.uppercased())
                    .font(Font.body)
                    .foregroundColor(Colors.systemLabel)
                Spacer()
                Text(value)
                    .font(Font.monospacedDigit(.body)())
                    .foregroundColor(Colors.systemLabelSecondary)

            }.fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 8)

            Divider()
        }
    }
}
