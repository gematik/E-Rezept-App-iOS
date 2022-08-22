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

import AVFoundation
import ComposableArchitecture
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
            }.navigationBarItems(leading: CloseButton {
                viewStore.send(.dismissScannerView)
                toggleFlashlight(status: false)
            },
            trailing: LightSwitch(store: store)
                .accessibility(identifier: A11y.cardWall.canScanner.cdwScnBtnClose)
                .accessibility(label: Text(L10n.cdwCanScanBtnClose)))
        }
    }
}

private func toggleFlashlight(status: Bool) {
    guard
        let device = AVCaptureDevice.default(for: AVMediaType.video),
        device.hasTorch
    else { return }

    do {
        try device.lockForConfiguration()
        device.torchMode = status ? .on : .off
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}

struct LightSwitch: View {
    let store: CardWallCANDomain.Store
    var body: some View {
        WithViewStore(store) { viewStore in

            if (AVCaptureDevice.default(for: AVMediaType.video)?.hasTorch) != nil {
                Button(action: {
                    viewStore.send(.toggleFlashLight)
                    toggleFlashlight(status: viewStore.isFlashOn)
                }, label: {
                    HStack {
                        Image(systemName: viewStore.state.isFlashOn ? SFSymbolName.lightbulb : SFSymbolName
                            .lightbulbSlash).foregroundColor(Colors.systemColorWhite)
                        Text(viewStore.state.isFlashOn ? L10n.scnBtnLightOn : L10n.scnBtnLightOff)
                            .foregroundColor(Colors.systemColorWhite)
                            .padding(.trailing)
                    }
                })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding()
            }
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
