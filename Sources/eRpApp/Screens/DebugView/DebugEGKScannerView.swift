//
//  Copyright (c) 2021 gematik GmbH
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

struct DebugEGKScannerView: View {
    @Binding var show: Bool

    // virtual eGK private key
    @Binding var prkCHAUTbase64: String
    // virtual eGK certificate
    @Binding var cCHAUTbase64: String

    @State var validPrkFound = false
    @State var validPukFound = false
    @State var error: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            AVScannerView(erxCodeTypes: [.qr, .dataMatrix],
                          supportedCodeTypes: [.qr, .dataMatrix],
                          scanning: show) { output in
                guard case let .erxCode(keyBase64Wrapped) = output.first,
                      let keyBase64 = keyBase64Wrapped else { return }
                do {
                    let data = try Base64.decode(string: keyBase64)

                    if (try? BrainpoolP256r1.Verify.PrivateKey(raw: data)) != nil {
                        validPrkFound = true
                        prkCHAUTbase64 = keyBase64
                    } else if (try? X509(der: data)) != nil {
                        validPukFound = true
                        cCHAUTbase64 = keyBase64
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
                        Image(systemName: validPrkFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validPrkFound ? Colors.secondary600 : Colors.red600)
                        Text("PrkCHAut")
                    }
                    HStack {
                        Image(systemName: validPukFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validPukFound ? Colors.secondary600 : Colors.red600)
                        Text("CCHAut")
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

struct DebugEGKScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugEGKScannerView(show: .constant(true),
                                prkCHAUTbase64: .constant(""),
                                cCHAUTbase64: .constant(""),
                                validPrkFound: false,
                                validPukFound: true,
                                error: nil)
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}

#endif
