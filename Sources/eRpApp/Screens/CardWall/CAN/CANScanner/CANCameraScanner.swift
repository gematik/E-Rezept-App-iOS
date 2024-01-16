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

import AVFoundation
import ComposableArchitecture
import SwiftUI

struct CANCameraScanner: View {
    @Binding var canScan: ScanCAN?
    var closeAction: (ScanCAN?) -> Void

    var body: some View {
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
                            closeAction(canScan)
                        }
                    }
                }
                .padding(.bottom)
            }
            .padding()
        }.navigationBarItems(leading: CloseButton {
            closeAction(nil)
            toggleFlashlight(status: false)
        },
        trailing: LightSwitch(isFlashOn: false)
            .accessibility(identifier: A11y.cardWall.canScanner.cdwScnBtnClose)
            .accessibility(label: Text(L10n.cdwCanScanBtnClose)))
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
    @State var isFlashOn: Bool {
        didSet {
            toggleFlashlight(status: isFlashOn)
        }
    }

    var body: some View {
        VStack {
            if (AVCaptureDevice.default(for: AVMediaType.video)?.hasTorch) != nil {
                Button(action: {
                    isFlashOn.toggle()
                }, label: {
                    HStack {
                        Image(systemName: !isFlashOn ? SFSymbolName.lightbulb : SFSymbolName
                            .lightbulbSlash).foregroundColor(Color.primary)
                        Text(!isFlashOn ? L10n.scnBtnLightOn : L10n.scnBtnLightOff)
                            .foregroundColor(Color.primary)
                            .padding(.trailing)
                    }
                })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding()
            }
        }.onReceive(NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                isFlashOn = false
        }
        .onChange(of: isFlashOn) { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

struct KVNRCameraScanner_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CANCameraScanner(canScan: .constant("123123")) { _ in }
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
