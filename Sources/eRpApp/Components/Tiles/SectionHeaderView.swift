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

struct SectionHeaderView: View {
    let text: LocalizedStringKey
    let a11y: String

    var body: some View {
        HStack {
            Text(text)
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
