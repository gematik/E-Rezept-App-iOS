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

import eRpStyleKit
import SwiftUI

/// sourcery: StringAssetInitialized
struct TertiaryListButton: View {
    var text: LocalizedStringKey
    var imageName: String? = SFSymbolName.refresh
    var accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .foregroundColor(Colors.primary)
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Colors.primary)
            }
        }
        .buttonStyle(TertiaryListButtonStyle())
        .accessibility(identifier: accessibilityIdentifier)
    }
}

struct TertiaryListButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(configuration.isPressed ? 0.25 : 1)
    }
}

struct TertiaryListButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TertiaryListButton(text: "Peter picked a peck of pickled peppers",
                               accessibilityIdentifier: "some") {}
                .previewLayout(.fixed(width: 350.0, height: 100.0))
            TertiaryListButton(text: "A peck of pickled peppers Peter Piper picked.",
                               accessibilityIdentifier: "some") {}
                .previewLayout(.fixed(width: 400.0, height: 100.0))
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraLarge)
        }
    }
}
