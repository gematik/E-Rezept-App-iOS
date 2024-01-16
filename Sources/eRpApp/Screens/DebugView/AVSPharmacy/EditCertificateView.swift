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

#if ENABLE_DEBUG_VIEW

import OpenSSL
import SwiftUI

struct EditCertificateView: View {
    @Binding var name: String
    @State var showScanner = false
    @Binding var value: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name")
                TextField("Certificate name", text: $name)
                    .padding()
                    .background(Colors.systemBackground)
                    .foregroundColor(Colors.systemLabel)
                    .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
            }
            .padding()

            VStack(alignment: .leading, spacing: 4) {
                Text("Zertifikat (C.HCI.ENC)")
                TextEditor(text: $value)
                    .padding()
                    .frame(minHeight: 200, maxHeight: .infinity)
                    .foregroundColor(Colors.systemLabel)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .font(.system(.footnote, design: .monospaced))
                    .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
                Text("Das HCI Verschlüsselungs-Zertifikat muss als Base64 kodiertes DER-Format angeben werden!")
                    .font(.footnote)

            }.padding()
        }
        .navigationTitle("Zertifikat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        showScanner = true
                    },
                    label: { Image(systemName: SFSymbolName.qrCode) }
                )
            }
        }
        .sheet(isPresented: $showScanner) {
            X509ScannerView(
                show: $showScanner,
                name: $name,
                derBase64: $value
            )
        }
    }
}

struct EditCertificateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditCertificateView(name: .constant(""), value: .constant(""))
            EditCertificateView(name: .constant(""), value: .constant(""))
                .preferredColorScheme(.dark)
        }
    }
}

#endif
