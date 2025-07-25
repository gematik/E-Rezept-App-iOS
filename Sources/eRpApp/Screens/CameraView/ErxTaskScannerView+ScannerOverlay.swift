//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import AVFoundation
import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

extension ErxTaskScannerView {
    struct ScannerOverlay: View {
        @Perception.Bindable var store: StoreOf<ScannerDomain>
        @State var isImageScaled = false

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    HStack {
                        CloseButton { store.send(.closeWithoutSave) }
                            .accessibility(identifier: A11y.scanner.scnBtnCancelScan)
                            .accessibility(label: Text(L10n.scnBtnCancelScan))

                        Spacer()

                        if (AVCaptureDevice.default(for: AVMediaType.video)?.hasTorch) == true {
                            Button(action: {
                                store.send(.toggleFlashLight)
                                toggleFlashlight(status: store.isFlashOn)
                            }, label: {
                                HStack {
                                    Image(
                                        systemName: !store.isFlashOn ? SFSymbolName.lightbulb : SFSymbolName
                                            .lightbulbSlash
                                    ).foregroundColor(Color.primary)
                                    Text(!store.state.isFlashOn ? L10n.scnBtnLightOn : L10n.scnBtnLightOff)
                                        .foregroundColor(Color.primary)
                                }
                            })
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .padding()
                        }
                    }

                    InfoView(localizedTextKey: textLabel(
                        for: store.scanState,
                        hasScannedBatches: !store.acceptedTaskBatches.isEmpty
                    ))

                    Spacer()
                    if store.scanState.isIdle || store.scanState.isLoading {
                        if isImageScaled {
                            Image(systemName: SFSymbolName.plusViewFinder)
                                .font(Font.largeTitle)
                                .foregroundColor(Colors.yellow500)
                                .transition(.endlessScale(from: 1, to: 1.2))
                        }
                    } else {
                        ScanStateImage(imageAsset: imageAsset(for: store.scanState),
                                       foregroundColor: alertTintColor(for: store.scanState))
                    }
                    Spacer()

                    HStack {
                        Spacer()
                        Button(action: {
                            store.send(.importButtonTapped)
                        }, label: {
                            Image(systemName: SFSymbolName.photoOnRect)
                                .frame(width: 56, height: 56)
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color.primary)
                                .background(
                                    Circle().foregroundColor(Colors.systemGray6)
                                )
                        })
                    }
                    .padding(.horizontal)

                    if !store.acceptedTaskBatches.isEmpty {
                        FinishButton(scannedBatches: store.acceptedTaskBatches) {
                            store.send(.saveAndClose(store.acceptedTaskBatches))
                        }
                    }
                }
                .confirmationDialog($store.scope(state: \.destination?.sheet, action: \.destination.sheet))
                .fileImporter(
                    isPresented: Binding<Bool>(
                        get: { store.destination == .documentImporter },
                        set: { show in
                            if !show {
                                store.send(.resetNavigation)
                            }
                        }
                    ),
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: false
                ) { result in
                    store.send(.response(.documentFileReceived(
                        result.mapError { _ in ScannerDomain.Error.invalid }
                    )))
                }
                .sheet(item: $store
                    .scope(state: \.destination?.imageGallery, action: \.destination.imageGallery)) { _ in
                        ImagePicker(image: .init(get: { nil },
                                                 set: { store.send(.response(.galleryImageReceived($0))) }))
                }
                .onAppear {
                    self.isImageScaled.toggle()
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        store.send(.flashLightOff)
                }
                .onChange(of: store.isFlashOn) { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }

        private func toggleFlashlight(status: Bool) {
            guard
                let device = AVCaptureDevice.default(for: AVMediaType.video),
                device.hasTorch,
                device.isTorchAvailable
            else { return }

            do {
                try device.lockForConfiguration()
                device.torchMode = status ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }

        private func textLabel(for state: LoadingState<[ScannedErxTask], ScannerDomain.Error>,
                               hasScannedBatches: Bool) -> LocalizedStringKey {
            switch state {
            case .idle:
                if !hasScannedBatches {
                    return L10n.scnMsgScanningCode.key
                } else {
                    return L10n.scnMsgScanningCodeConsecutive.key
                }
            case .value: return L10n.scnMsgScannedCodeRecognized.key
            case .loading: return L10n.scnMsgAnalysingCode.key
            case let .error(scanError): return LocalizedStringKey(scanError.localizedDescriptionWithErrorList)
            }
        }

        private func imageAsset(for state: LoadingState<[ScannedErxTask], ScannerDomain.Error>) -> ImageAsset {
            switch state {
            case .value: return Asset.Scanner.check
            case .error: return Asset.Scanner.alert
            case .idle, .loading: preconditionFailure("Scanning does not have an alertImage")
            }
        }

        private func alertTintColor(for scanState: LoadingState<[ScannedErxTask], ScannerDomain.Error>) -> Color {
            scanState.isValue ? Colors.secondary600 : Colors.systemLabel
        }
    }
}

extension ErxTaskScannerView.ScannerOverlay {
    struct InfoView: View {
        let localizedTextKey: LocalizedStringKey
        var body: some View {
            VStack {
                HStack {
                    Text(localizedTextKey, bundle: .module)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .accessibility(identifier: A11y.scanner.scnTxtScanState)
                        .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(BlurEffectView(style: .systemUltraThinMaterial, isEnabled: true))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }

    struct ScanStateImage: View {
        let imageAsset: ImageAsset
        let foregroundColor: Color

        @State var imageScale: CGFloat = 0.5

        var body: some View {
            Image(decorative: imageAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(foregroundColor)
                .frame(height: 140, alignment: .center)
                .scaleEffect(imageScale)
                .accessibility(hidden: true) // we do not want an accessibility frame
                .accessibility(identifier: A11y.scanner.scnImgScanAlert)
                .onAppear {
                    withAnimation(.spring()) {
                        self.imageScale = 1.0
                    }
                }
        }
    }

    struct AnimatableCircularCounter<S: StringProtocol>: View {
        private let content: S

        init(_ content: S) {
            self.content = content
        }

        @State var counterScale: CGFloat = 1.0
        @State var previousContent: S = ""

        var body: some View {
            Text(self.content)
                .fontWeight(.bold)
                .font(.system(size: 15))
                .foregroundColor(Colors.secondary600)
                .padding(5)
                .background(Colors.systemGray6)
                .clipShape(Circle())
                .scaleEffect(counterScale)
                .onReceive(Just(self.counterScale)) { scale in
                    if scale == 2.0 {
                        withAnimation {
                            self.counterScale = 1.0
                        }
                    }
                }
                .onReceive(Just(self.content)) { content in
                    if content != self.previousContent {
                        withAnimation {
                            self.previousContent = content
                            self.counterScale = 2.0
                        }
                    }
                }
        }
    }

    struct FinishButton: View {
        let scannedBatches: Set<[ScannedErxTask]>
        let action: () -> Void
        @State var isResultPresented = false

        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: action) {
                            HStack {
                                Text(L10n.scnBtnScanningDone(scannedBatches.count).text) // Plural count is ignored
                                    .fontWeight(.semibold)
                                    .font(.system(size: 18))
                                    .foregroundColor(Colors.systemColorWhite)
                                    .animation(nil)
                                Spacer()
                                AnimatableCircularCounter("\(scannedBatches.count)")
                            }
                        }.accessibility(identifier: A11y.scanner.scnBtnScanningDone)
                    }

                    Spacer()
                }
                .padding(5)
                .background(Colors.secondary600)
                .cornerRadius(20)
                .padding(20)
            }.background(Colors.systemGray6)
                .cornerRadius(20)
                .padding([.horizontal, .bottom])
                .transition(.move(edge: .bottom))
        }
    }
}

extension Animation {
    static func ripple() -> Animation {
        Animation.spring(dampingFraction: 0.75)
    }
}

#if DEBUG
struct ScannerOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // success appearance
            ErxTaskScannerView.ScannerOverlay(
                store: ScannerDomain.Dummies.store(
                    with: ScannerDomain.State(scanState: .value([]), acceptedTaskBatches: [])
                )
            )

            // duplicate appearance
            ErxTaskScannerView.ScannerOverlay(
                store: ScannerDomain.Dummies.store(
                    with: ScannerDomain.State(scanState: .error(.duplicate), acceptedTaskBatches: [])
                )
            )
            .preferredColorScheme(.dark)

            // invalid appearance
            ErxTaskScannerView.ScannerOverlay(
                store: ScannerDomain.Dummies.store(
                    with: ScannerDomain.State(scanState: .idle, acceptedTaskBatches: [])
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif
