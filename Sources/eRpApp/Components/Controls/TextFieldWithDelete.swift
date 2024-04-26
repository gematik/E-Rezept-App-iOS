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
struct TextFieldWithDelete: View {
    internal init(title: LocalizedStringKey,
                  text: Binding<String>,
                  accessibilityLabelKey: LocalizedStringKey? = nil) {
        self.title = title
        _text = text
        self.accessibilityLabelKey = accessibilityLabelKey ?? title
    }

    let title: LocalizedStringKey
    let accessibilityLabelKey: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(title,
                      text: $text)
                .padding()
                .font(Font.body)
                .foregroundColor(Color(.label))
                .accessibility(label: Text(accessibilityLabelKey))
                .overlay(
                    HStack {
                        if text.isEmpty == false {
                            Button(action: {
                                text = ""
                            }, label: {
                                Image(systemName: SFSymbolName.crossIconFill)
                                    .foregroundColor(Color(.tertiaryLabel))
                            })
                                .accessibility(identifier: A11y.controls.textfieldwithdelete.ctlBtnTextfieldDelete)
                                .foregroundColor(Color(.tertiaryLabel))
                                .padding()
                                .buttonStyle(PlainButtonStyle())
                        }
                    }, alignment: .trailing
                )
        }
    }
}

struct TextFieldWithDelete_Preview: PreviewProvider {
    struct Wrapper: View {
        @State var text = "Anna Vetta"
        var body: some View {
            TextFieldWithDelete(title: "MyName", text: $text)
        }
    }

    static var previews: some View {
        Group {
            Wrapper()
        }
    }
}
