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
import SwiftUIIntrospect

/// sourcery: StringAssetInitialized
struct SecureFieldWithReveal: View {
    internal init(titleKey: LocalizedStringKey,
                  accessibilityLabelKey: LocalizedStringKey? = nil,
                  text: Binding<String>,
                  textContentType: UITextContentType? = nil,
                  backgroundColor: Color = Color(.systemBackground),
                  onCommit: @escaping () -> Void) {
        self.titleKey = titleKey
        self.accessibilityLabelKey = accessibilityLabelKey ?? titleKey
        _text = text
        self.textContentType = textContentType
        self.backgroundColor = backgroundColor
        self.onCommit = onCommit
    }

    let titleKey: LocalizedStringKey
    let accessibilityLabelKey: LocalizedStringKey
    @Binding var text: String
    let textContentType: UITextContentType?
    let backgroundColor: Color
    let onCommit: () -> Void

    @State var showPassword = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // [REQ:BSI-eRp-ePA:O.Data_10#3] `SecureFields` are used for password input.
            SecureField(text: $text) {
                Text(titleKey, bundle: .module)
            }
            // This suppresses the clearButton displayed in the SecureField (introduced in SceneDelegate)
            // If shown, it's overlapping with the reveal button
            .introspect(.secureField, on: .iOS(.v15, .v16, .v17, .v18)) { secureField in
                secureField.clearButtonMode = .never
            }
            .onSubmit(onCommit)
            .font(Font.body)
            .foregroundColor(!showPassword ? Color(.label) : self.backgroundColor)
            .accessibility(label: Text(accessibilityLabelKey, bundle: .module))
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
                .foregroundColor(Color(.tertiaryLabel))
                .accessibilityValue(showPassword ? "show" : "hide") // for UITests only
                .accessibility(hidden: true)
        }
    }
}

struct SecureFieldWithReveal_Preview: PreviewProvider {
    struct Wrapper: View {
        @State var text = "abc"
        var body: some View {
            SecureFieldWithReveal(titleKey: "Passwort", text: $text) {}
        }
    }

    static var previews: some View {
        Group {
            Wrapper()
        }
    }
}
