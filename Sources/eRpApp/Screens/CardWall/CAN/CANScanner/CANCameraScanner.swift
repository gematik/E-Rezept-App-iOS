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

import ComposableArchitecture
import eRpKit
import GemCommonsKit
import SwiftUI

struct CANCameraScanner: View {
    let store: CardWallCANDomain.Store
    @Binding var canScan: ScanCAN?

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .top) {
                VisionView(can: $canScan)
                    .edgesIgnoringSafeArea([.top, .bottom])
                    .onAppear {
                        canScan = nil
                    }

                VStack {
                    if let canScan = canScan {
                        Text("\(L10n.cdwCanScanTxtResult.text) \n\(canScan)")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20))
                    } else {
                        Text(L10n.cdwCanScanTxtHint.text)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20))
                    }

                    Spacer()
                    PrimaryTextButton(text: L10n.cdwCanScanBtnConfirm,
                                      a11y: A11y.cardWall.canScanner.cdwScnBtnDone,
                                      isEnabled: canScan != nil) {
                        if canScan != nil {
                            if let canScan = canScan {
                                viewStore.send(.update(can: canScan))
                                viewStore.send(.dismissScannerView)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
            }.navigationBarItems(trailing: CloseButton {
                viewStore.send(.dismissScannerView)
            }
            .accessibility(identifier: A11y.cardWall.canScanner.cdwScnBtnClose)
            .accessibility(label: Text(L10n.cdwCanScanBtnClose)))
        }
    }
}

struct KVNRCameraScanner_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CANCameraScanner(store: CardWallCANDomain.Dummies.store, canScan: .constant("123123"))
        }
    }
}

struct VisionView: UIViewControllerRepresentable {
    @Binding var can: ScanCAN?

    func makeUIViewController(context _: Context) -> CANCameraScannerViewController {
        CANCameraScannerViewController()
    }

    func updateUIViewController(_ uiViewController: CANCameraScannerViewController, context _: Context) {
        uiViewController.canScanned = { can in
            self.can = can
        }
    }
}
