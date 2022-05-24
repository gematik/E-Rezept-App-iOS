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

import eRpStyleKit
import SwiftUI

/// sourcery: StringAssetInitialized
struct FormTextFieldView: View {
    let placeholder: LocalizedStringKey?
    var subtitle: LocalizedStringKey?
    @Binding var text: String
    var showSeparator: Bool

    init(placeholder: LocalizedStringKey? = nil,
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
                    TextField(
                        placeholder ?? "",
                        text: _text
                    )

                    if let title = subtitle {
                        Text(title)
                            .font(.subheadline)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                if !text.isEmpty {
                    Spacer()
                    Image(systemName: SFSymbolName.crossIconFill)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            text = ""
                        }
                        .padding(.horizontal, 16)
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
                FormTextFieldView(placeholder: "Placeholder", subtitle: nil, text: .constant(""), showSeparator: true)
                FormTextFieldView(placeholder: nil, subtitle: "Subtitle", text: .constant(""), showSeparator: true)
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

            VStack {
                FormTextFieldView(placeholder: "Placeholder", subtitle: nil, text: .constant(""), showSeparator: true)
                FormTextFieldView(placeholder: nil, subtitle: "Subtitle", text: .constant(""), showSeparator: true)
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
