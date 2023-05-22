//
//  Copyright (c) 2023 gematik GmbH
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

import AVFoundation
import DataKit
import OpenSSL
import SwiftUI

struct X509ScannerView: View {
    @Binding var show: Bool
    // name read from the certificate
    @Binding var name: String
    // Base64 DER representation of a scanned HCI encryption certificate (C.HCI.ENC)
    @Binding var derBase64: String

    @State var validCertFound = false
    @State var error: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            AVScannerView(erxCodeTypes: [.qr, .dataMatrix],
                          supportedCodeTypes: [.qr, .dataMatrix],
                          scanning: show) { output in
                guard case let .erxCode(outputString) = output.first,
                      let output = outputString else { return }
                do {
                    let derBytes = try Base64.decode(string: output)

                    if let cert = try? X509(der: derBytes) {
                        if let subject = try? cert.subjectOneLine() {
                            name = subject.starting(after: "CN=")
                        }
                        validCertFound = true
                        derBase64 = output
                    }

                    if let data = output.data(using: .utf8),
                       let cert = try? X509(pem: data) {
                        if let subject = try? cert.subjectOneLine() {
                            name = subject.starting(after: "CN=")
                        }
                        validCertFound = true
                        derBase64 = cert.derBytes?.base64EncodedString() ?? ""
                    }
                } catch {
                    print(error)
                    return
                }
            }

            VStack(alignment: .leading) {
                if let error = error {
                    Text(error)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: validCertFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validCertFound ? Colors.secondary600 : Colors.red600)
                        Text("C.HCI.ENC")
                        Text(name)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)

                PrimaryTextButton(text: "Accept", a11y: "Accept") {
                    show = false
                }
            }
            .padding()
        }
    }
}

struct DebugCertScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            X509ScannerView(
                show: .constant(true),
                name: .constant(""),
                derBase64: .constant(""),
                validCertFound: false,
                error: nil
            )
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}

#endif
