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

struct NavigationTextButton: View {
    let text: LocalizedStringKey
    let a11y: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text, bundle: .module)
                .fontWeight(.semibold)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(isEnabled ? Colors.primary : Color(.systemGray))
                .padding([.bottom, .top])
        }
        .buttonStyle(NavigationTextButtonStyle(enabled: isEnabled))
        .ifLet(a11y) { $0.accessibility(identifier: $1) }
        .disabled(!isEnabled)
    }
}

struct NavigationTextButtonStyle: ButtonStyle {
    private let isEnabled: Bool

    init(enabled: Bool = true) {
        isEnabled = enabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.25 : 1)
    }
}

struct NavigationTextButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                NavigationTextButton(text: "Peter picked a peck of pickled peppers", a11y: "dummy_a11y_a") {}
            }.background(Color.yellow)

            VStack {
                NavigationTextButton(text: "Peter picked a peck of pickled peppers",
                                     a11y: "dummy_a11y_b",
                                     isEnabled: false) {}
            }.background(Color.yellow)

            VStack {
                NavigationTextButton(text: "Peter picked a peck of pickled peppers", a11y: "dummy_a11y_c") {}
                    .previewLayout(.fixed(width: 400.0, height: 150.0))
                    .preferredColorScheme(.dark)
                    .environment(\.sizeCategory, .extraExtraLarge)
            }

        }.previewLayout(.fixed(width: 350.0, height: 100.0))
    }
}
