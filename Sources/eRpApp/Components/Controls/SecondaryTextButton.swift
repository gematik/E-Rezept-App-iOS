//
//  Copyright (c) 2023 gematik GmbH
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

struct SecondaryTextButton: View {
    var text: LocalizedStringKey
    var a11y: String
    var image: Image?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.primary)
                .padding()
                .fixedSize(horizontal: false, vertical: true)

        }.buttonStyle(SecondaryButtonStyle())
            .accessibility(identifier: a11y)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(Colors.systemGray6)
            .cornerRadius(16)
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SecondaryTextButton(text: "Peter picked a peck of pickled peppers", a11y: "") {}
                .previewLayout(.fixed(width: 350.0, height: 150.0))
            SecondaryTextButton(text: "Peter picked a peck of pickled peppers", a11y: "") {}
                .previewLayout(.fixed(width: 400.0, height: 150.0))
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraLarge)
        }
    }
}
