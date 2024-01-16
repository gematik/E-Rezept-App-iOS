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

import CoreImage.CIFilterBuiltins
import SwiftUI

#if ENABLE_DEBUG_VIEW

struct DebugQRCodeImporter<ContentType: Codable>: View {
    @Binding var scan: Bool

    var found: (ContentType) -> Void

    @State var error: Error?
    var body: some View {
        ZStack(alignment: .top) {
            AVScannerView(erxCodeTypes: [.qr],
                          supportedCodeTypes: [.qr],
                          scanning: scan) { outputs in
                // only scan once
                guard scan else { return }

                if let output = outputs.first {
                    if case let .text(input) = output,
                       let data = input?.data(using: .utf8) {
                        do {
                            let newContent = try JSONDecoder().decode(ContentType.self, from: data)
                            self.error = nil
                            found(newContent)
                            scan = false
                        } catch {
                            self.error = error
                        }
                    }
                }
            }

            VStack {
                Text("Import via QR-Code")
                    .padding()
                    .background(RoundedCorner(radius: 16).foregroundColor(.black))
                    .foregroundColor(.white)

                Spacer()

                if let error = error {
                    Text(error.localizedDescription)
                        .padding()
                        .background(RoundedCorner(radius: 16).foregroundColor(.black))
                        .foregroundColor(.white)
                }
            }.padding()
        }
        .navigationTitle("Import")
    }
}

struct DebugQRCodeImporter_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugQRCodeImporter<String>(scan: .constant(true)) { _ in }
        }
    }
}

#endif
