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
struct PrimaryTextFieldView: View {
    var placeholder: LocalizedStringKey
    @Binding var text: String
    let a11y: String

    var body: some View {
        TextField(
            placeholder,
            text: $text
        )
        .padding()
        .font(Font.body)
        .foregroundColor(Colors.systemLabel)
        .background(Colors.systemGray6)
        .cornerRadius(16)
        .accessibility(identifier: a11y)
    }
}

struct PrimaryTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                PrimaryTextFieldView(placeholder: "Placeholder", text: .constant(""), a11y: "")
                PrimaryTextFieldView(placeholder: "Placeholder", text: .constant("Some text"), a11y: "")
            }

            VStack {
                PrimaryTextFieldView(placeholder: "Placeholder", text: .constant(""), a11y: "")
                PrimaryTextFieldView(placeholder: "Placeholder", text: .constant("Some text"), a11y: "")
            }
            .preferredColorScheme(.dark)
        }
    }
}
