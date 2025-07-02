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
struct SectionHeaderView: View {
    let text: LocalizedStringKey
    let a11y: String

    var body: some View {
        HStack {
            Text(text, bundle: .module)
                .font(Font.headline.weight(Font.Weight.bold))
                .foregroundColor(Colors.systemLabel)
                .multilineTextAlignment(.leading)
                .accessibility(identifier: a11y)
                .padding([.top, .trailing])
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                SectionHeaderView(text: "Peter picked a peck of pickled peppers", a11y: "dummy_a11y_a")
                Spacer()
            }
            .background(Color.purple)
            VStack {
                Spacer()
                SectionHeaderView(text: "Peter picked a peck of pickled peppers", a11y: "dummy_a11y_b")
                Spacer()
            }
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .background(Color.purple)
        }.previewLayout(.fixed(width: 400.0, height: 150.0))
    }
}
