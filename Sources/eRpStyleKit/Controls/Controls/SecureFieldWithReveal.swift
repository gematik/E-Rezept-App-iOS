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
import SwiftUI
import SwiftUIIntrospect

/// A `SecureField` with an eye button to reveal the password
public struct SecureFieldWithReveal: View {
    public init(titleKey: StringAsset,
                accessibilityLabelKey: StringAsset? = nil,
                text: Binding<String>,
                textContentType: UITextContentType? = nil,
                borderColor: Color? = nil,
                onCommit: @escaping () -> Void) {
        self.titleKey = titleKey
        self.accessibilityLabelKey = accessibilityLabelKey ?? titleKey
        _text = text
        self.textContentType = textContentType
        self.borderColor = borderColor ?? Colors.systemLabelSecondary
        self.onCommit = onCommit
    }

    let titleKey: StringAsset
    let accessibilityLabelKey: StringAsset
    @Binding var text: String
    let textContentType: UITextContentType?
    let borderColor: Color
    let onCommit: () -> Void

    @State var showPassword = false

    public var body: some View {
        ZStack(alignment: .trailing) {
            // [REQ:BSI-eRp-ePA:O.Data_10#3] `SecureFields` are used for password input.
            SecureField(text: $text) {
                Text(titleKey)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
            .foregroundColor(!showPassword ? Colors.systemLabel : Colors.systemBackground)
            // This suppresses the clearButton displayed in the SecureField (introduced in SceneDelegate)
            // If shown, it's overlapping with the reveal button
            .introspect(.secureField, on: .iOS(.v15, .v16, .v17, .v18, .v26)) { secureField in
                secureField.clearButtonMode = .never
            }
            .onSubmit(onCommit)
            .font(Font.body)
            .accessibility(label: Text(accessibilityLabelKey))
            .textContentType(textContentType)

            HStack {
                Text(text)
                    .font(Font.system(.body, design: .monospaced))
                Spacer()
            }.opacity(showPassword ? 1 : 0)

            Button(action: {
                showPassword.toggle()
            }, label: {
                Image(systemName: showPassword ? SFSymbolName.eye : SFSymbolName.eyeSlash)
            })
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(Colors.systemLabelSecondary)
            .accessibilityValue(showPassword ? "show" : "hide") // for UITests only
            .accessibility(hidden: true)
        }
        .padding()
        .font(Font.body)
        .background(Colors.systemBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    borderColor,
                    lineWidth: 0.5
                )
        )
    }
}

struct SecureFieldWithReveal_Preview: PreviewProvider {
    struct Wrapper: View {
        @State var text = "abc"
        var body: some View {
            SecureFieldWithReveal(titleKey: StringAsset("Passwort", bundle: .main), text: $text) {}
        }
    }

    static var previews: some View {
        Group {
            Wrapper()
        }
    }
}
