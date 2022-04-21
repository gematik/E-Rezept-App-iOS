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

/// sourcery: StringAssetInitialized
struct SecureFieldWithReveal: View {
    internal init(titleKey: LocalizedStringKey,
                  accessibilityLabelKey: LocalizedStringKey? = nil,
                  text: Binding<String>,
                  textContentType: UITextContentType? = nil,
                  onCommit: @escaping () -> Void) {
        self.titleKey = titleKey
        self.accessibilityLabelKey = accessibilityLabelKey ?? titleKey
        self.textContentType = textContentType
        _text = text
        self.onCommit = onCommit
    }

    let titleKey: LocalizedStringKey
    let accessibilityLabelKey: LocalizedStringKey
    let textContentType: UITextContentType?
    @Binding var text: String
    let onCommit: () -> Void

    @State var showPassword = false

    var body: some View {
        ZStack(alignment: .trailing) {
            SecureField(titleKey, text: $text, onCommit: onCommit)
                .font(Font.body)
                .foregroundColor(!showPassword ? Color(.label) : Color(.systemBackground))
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
