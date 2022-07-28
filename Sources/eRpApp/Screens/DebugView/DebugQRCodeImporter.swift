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

import CoreImage.CIFilterBuiltins
import SwiftUI

#if ENABLE_DEBUG_VIEW

struct DebugQRCodeImporter<ContentType: Codable>: View {
    @Binding
    var scan: Bool

    var found: (ContentType) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            AVScannerView(erxCodeTypes: [.qr],
                          supportedCodeTypes: [.qr],
                          scanning: scan) { outputs in
                // only scan once
                guard scan else { return }

                if let output = outputs.first {
                    if case let .erxCode(input) = output,
                       let data = input?.data(using: .utf8),
                       let newContent = try? JSONDecoder().decode(ContentType.self, from: data) {
                        found(newContent)
                        scan = false
                    }
                }
            }

            Text("Import via QR-Code")
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
