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

import eRpKit
import GemCommonsKit
import SwiftUI

struct KVNRCameraScanner: View {
    @Binding var kvnr: KVNR?
    @Binding var show: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VisionView(kvnr: $kvnr)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if let kvnr = kvnr {
                    Text(kvnr)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }

                PrimaryTextButton(text: L10n.cdwBtnOrderEgkScanKvnrConfirm,
                                  a11y: A11y.cardWall.orderEGK.cdwBtnOrderEgkScanKvnrConfirm,
                                  isEnabled: kvnr != nil) {
                    show = false
                }
            }
            .padding()
        }
    }
}

struct KVNRCameraScanner_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KVNRCameraScanner(kvnr: .constant("Q123456784"), show: .constant(true))
        }
    }
}

struct VisionView: UIViewControllerRepresentable {
    @Binding var kvnr: KVNR?

    func makeUIViewController(context _: Context) -> KVNRCameraScannerViewController {
        KVNRCameraScannerViewController()
    }

    func updateUIViewController(_ uiViewController: KVNRCameraScannerViewController, context _: Context) {
        uiViewController.kvnrScanned = { kvnr in
            self.kvnr = kvnr
        }
    }
}
