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

struct TertiaryButton: View {
    var text: LocalizedStringKey
    var isEnabled = true
    var imageName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text, bundle: .module)
                    .fontWeight(.regular)
                    .font(.subheadline)
                    .foregroundColor(isEnabled ? Colors.primary : Colors.systemGray)
                    .fixedSize(horizontal: false, vertical: true)
                if let image = imageName {
                    Image(systemName: image)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(isEnabled ? Colors.primary : Colors.systemGray)
                }
                Spacer()
            }
        }.buttonStyle(TertiaryButtonStyle())
            .disabled(!isEnabled)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.25 : 1)
    }
}

struct TertiaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TertiaryButton(text: "Peter picked a peck of pickled peppers",
                           imageName: SFSymbolName.map) {}
                .previewLayout(.fixed(width: 350.0, height: 100.0))
            TertiaryButton(text: "Peter picked a peck of pickled peppers",
                           isEnabled: false) {}
                .previewLayout(.fixed(width: 350.0, height: 100.0))
            TertiaryButton(text: "A peck of pickled peppers Peter Piper picked.") {}
                .previewLayout(.fixed(width: 400.0, height: 100.0))
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraLarge)
            TertiaryButton(text: "A peck of pickled peppers Peter Piper picked.",
                           isEnabled: false,
                           imageName: SFSymbolName.map) {}
                .previewLayout(.fixed(width: 400.0, height: 100.0))
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraLarge)
        }
    }
}
