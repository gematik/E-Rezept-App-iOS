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

import SwiftUI

/// Wrapped `TextField` applying styles and padding suited for using within `SectionContainer`.
public struct FormTextField: View {
    var titleKey: LocalizedStringKey
    var titleKeyBundle: Bundle

    @Binding var text: String

    public init(_ titleKey: LocalizedStringKey, bundle titleKeyBundle: Bundle, text: Binding<String>) {
        self.titleKey = titleKey
        _text = text
        self.titleKeyBundle = titleKeyBundle
    }

    public var body: some View {
        TextField(text: $text) {
            Text(titleKey, bundle: titleKeyBundle)
        }
        .padding()
    }
}

struct SectionContainerTextFieldStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SectionContainer {
                    TextField("Text", text: .constant(""))

                    TextField("Text", text: .constant("somestring"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
