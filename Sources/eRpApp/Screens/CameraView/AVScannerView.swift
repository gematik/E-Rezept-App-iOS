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
import SwiftUI

/// View that forwards the scanned `AVMetadataObject`s as `ScanOutput` while presenting the camera feed.
struct AVScannerView: UIViewControllerRepresentable {
    /// These are the code types we will analyse further.
    let erxCodeTypes: [AVMetadataObject.ObjectType]
    /// Don't bother to react to other kinds of codes.
    let supportedCodeTypes: [AVMetadataObject.ObjectType]
    /// `true` if scanning should be resumed,  `false` if scanning should be stopped
    let scanning: Bool
    /// Executed whenever an output was emitted
    var onScanOutput: ([ScanOutput]) -> Void

    func makeUIViewController(context _: Context) -> AVScannerViewController {
        let controller = AVScannerViewController()
        controller.erxCodeTypes = erxCodeTypes
        controller.supportedCodeTypes = supportedCodeTypes
        controller.onScanOutput = onScanOutput
        controller.errorDelegate = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: AVScannerViewController, context _: Context) {
        // Here we can add pause/continue scanning (potentially via a Coordinator)
        if scanning {
            uiViewController.resumeCamera()
        } else {
            uiViewController.pauseCamera()
        }
    }
}

// [REQ:BSI-eRp-ePA:O.Data_8#2] This controller uses the camera as an input device. Frames are processed but never
// stored, metadata is never created here.
class AVScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    /// These are the code types we will analyse further.
    var erxCodeTypes: [AVMetadataObject.ObjectType] = []
    /// Don't bother to react to other kinds of codes.
    var supportedCodeTypes: [AVMetadataObject.ObjectType] = []
    /// Executed whenever an output was emitted
    var onScanOutput: ([ScanOutput]) -> Void = { _ in }
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let captureSession = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()

    weak var errorDelegate: AVScannerViewErrorDelegate?

    lazy var visualEffectView: UIView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return effectView
    }()

    // MARK: Code handling

    func metadataOutput(_: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from _: AVCaptureConnection) {
        let codes = metadataObjects.filter { metadataObject in
            supportedCodeTypes.contains(metadataObject.type)
        }
        .map { metadataObject in
            createScanOutput(for: metadataObject)
        }
        DispatchQueue.main.async {
            self.onScanOutput(codes)
        }
    }

    private func createScanOutput(for metadataObject: AVMetadataObject) -> ScanOutput {
        guard erxCodeTypes.contains(metadataObject.type) else {
            return .invalidCode
        }
        let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject
        return .text(readableObject?.stringValue?.dropGS1Prefix())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupCamera()
    }

    override func viewDidDisappear(_ animated: Bool) {
        stopCamera()

        super.viewDidDisappear(animated)
    }

    // MARK: Camera handling

    func pauseCamera() {
        view.addSubview(visualEffectView)
        visualEffectView.frame = view.bounds
    }

    func resumeCamera() {
        visualEffectView.removeFromSuperview()
    }

    private func stopCamera() {
        captureSession.stopRunning()
    }

    private func setupCamera() {
        guard !captureSession.isRunning else {
            // already running
            return
        }

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            errorDelegate?.handle(error: AVScannerViewController.Error.initalizationError)
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: backCamera)

            // Set the input device and output device on the capture session.
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.metadataObjectTypes = supportedCodeTypes
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        } catch {
            errorDelegate?.handle(error: AVScannerViewController.Error.other(error))
            return
        }
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds

        view.layer.addSublayer(videoPreviewLayer)
        previewLayer = videoPreviewLayer
        // Start video capture.
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    // MARK: Orientation changes

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        previewLayer?.frame = view.bounds

        if let orientation = view.window?.windowScene?.interfaceOrientation {
            let newSize = view.layer.bounds.size
            previewLayer?.updateFor(orientation: orientation, size: newSize)
        }
    }

    private func presentInitializationErrorAlert() {
        let alert = UIAlertController(title: L10n.camInitFailTitle.text,
                                      message: L10n.camInitFailMessage.text,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.alertBtnClose.text,
                                         style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AVScannerViewController: AVScannerViewErrorDelegate {
    // sourcery: CodedError = "002"
    enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case initalizationError
        // sourcery: errorCode = "02"
        case other(Swift.Error)

        static var kAuthorizaionErrorCode = -11852
    }

    func handle(error: Error) {
        switch error {
        case .initalizationError: presentInitializationErrorAlert()
        case let .other(nsError):
            let nsError = nsError as NSError
            // authorization error is handled from CameraAuthorizationAlertView
            if nsError.code != Error.kAuthorizaionErrorCode {
                presentInitializationErrorAlert()
            }
        }
    }
}

extension AVCaptureVideoPreviewLayer {
    func updateFor(orientation: UIInterfaceOrientation, size: CGSize) {
        // correct position of previewLayer
        position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)

        // rotate the previewLayer, in order to have camera picture right
        switch orientation {
        case .portrait:
            setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(0.0)))
        case .landscapeLeft:
            setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
        case .landscapeRight:
            setAffineTransform(CGAffineTransform(rotationAngle: -.pi / 2))
        case .portraitUpsideDown:
            setAffineTransform(CGAffineTransform(rotationAngle: .pi))
        default:
            break
        }
    }
}

extension String {
    /// Drop concatenation Symbol 0x1D from barcode. See chapter 2.2.2 of
    /// [GS1_DataMatrix_Guideline.pdf](https://www.gs1.org/docs/barcodes/GS1_DataMatrix_Guideline.pdf)
    ///
    /// - Returns: Returns the data matrix code content without concatenation symbols upfront.
    func dropGS1Prefix() -> String {
        guard let prefix = String(data: Data([0x1D]), encoding: .utf8),
              self.hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
