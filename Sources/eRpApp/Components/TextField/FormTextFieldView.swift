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
struct FormTextFieldView: View {
    let placeholder: String?
    var subtitle: LocalizedStringKey?
    @Binding var text: String
    var showSeparator: Bool

    @State private var isFirstResponder = false

    init(placeholder: String? = nil,
         subtitle: LocalizedStringKey? = nil,
         text: Binding<String>,
         showSeparator: Bool = true) {
        self.placeholder = placeholder
        self.subtitle = subtitle
        _text = text
        self.showSeparator = showSeparator
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    FocusTextField(
                        placeholder: placeholder,
                        text: _text,
                        isFirstResponder: $isFirstResponder
                    )

                    if let title = subtitle {
                        Text(title, bundle: .module)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                if !text.isEmpty, isFirstResponder {
                    Spacer()
                    Image(systemName: SFSymbolName.crossIconFill)
                        .foregroundColor(Color(.tertiaryLabel))
                        .onTapGesture {
                            text = ""
                        }
                }
            }
            .modifier(BottomDividerStyle(showSeparator: showSeparator))
        }
    }
}

struct FormTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                FormTextFieldView(
                    placeholder: "Placeholder",
                    subtitle: "",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: nil,
                    subtitle: "Subtitle",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: "Very long placeholder with some text in it",
                    subtitle: "Very long subtitle with even more text in it, to check if it truncates correctly",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: "Placeholder",
                    subtitle: "Students",
                    text: .constant("Robert Drop Table"),
                    showSeparator: false
                )
            }
            VStack {
                FormTextFieldView(
                    placeholder: "Placeholder",
                    subtitle: "",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: nil,
                    subtitle: "Subtitle",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: "Placeholder",
                    subtitle: "Subtitle",
                    text: .constant(""),
                    showSeparator: true
                )
                FormTextFieldView(
                    placeholder: "Placeholder",
                    subtitle: "Students",
                    text: .constant("Robert Drop Table"),
                    showSeparator: false
                )
            }
            .preferredColorScheme(.dark)
        }
    }
}
