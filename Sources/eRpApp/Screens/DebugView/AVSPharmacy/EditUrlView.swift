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

struct EditUrlView: View {
    @Binding var url: String

    var body: some View {
        ScrollView {
            TextEditor(text: $url)
                .padding()
                .frame(minHeight: 100, maxHeight: .infinity)
                .foregroundColor(Colors.systemLabel)
                .keyboardType(.default)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .font(.system(.footnote, design: .monospaced))
                .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
        }
        .padding()
        .navigationTitle("URL")
    }
}

struct EditUrlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditUrlView(url: .constant("https://intern.gematik.de/url/test/preview"))
            EditUrlView(url: .constant("https://intern.gematik.de/url/test/preview"))
                .preferredColorScheme(.dark)
        }
    }
}
