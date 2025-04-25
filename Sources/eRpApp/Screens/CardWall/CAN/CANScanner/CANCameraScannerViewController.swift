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
import eRpKit
import Foundation
import OSLog
import UIKit
import Vision

// Inspired by Apple's https://developer.apple.com/documentation/vision/reading_phone_numbers_in_real_time from WWDC
// Session https://developer.apple.com/videos/play/wwdc19/234/ .

class CANCameraScannerViewController: UIViewController {
    var canScanned: ((ScanCAN) -> Void)?

    @IBOutlet var previewView: PreviewView!
    @IBOutlet var cutoutView: UIView!

    var maskLayer = CAShapeLayer()
    // Device orientation. Updated whenever the orientation changes to a
    // different supported orientation.
    var currentOrientation = UIDeviceOrientation.portrait

    // MARK: - Capture related objects

    private let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "de.gematik.captureSession")

    var captureDevice: AVCaptureDevice?

    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "de.gematik.videoOutput")

    // MARK: - Region of interest (ROI) and text orientation

    // Region of video data output buffer that recognition should be run on.
    // Gets recalculated once the bounds of the preview layer are known.
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    // Orientation of text to search for in the region of interest.
    var textOrientation = CGImagePropertyOrientation.up

    // MARK: - Coordinate transforms

    var bufferAspectRatio: Double!
    // Transform from UI orientation to buffer orientation.
    var uiRotationTransform = CGAffineTransform.identity
    // Transform bottom-left coordinates to top-left.
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    // Transform coordinates in ROI to global coordinates (still normalized).
    var roiToGlobalTransform = CGAffineTransform.identity

    // Vision -> AVF coordinate transform.
    var visionToAVFTransform = CGAffineTransform.identity

    // MARK: - View controller methods

    override func loadView() {
        let bounds = CGRect(x: 0, y: 0, width: 320, height: 512)

        let previewView = PreviewView(frame: bounds)
        previewView.translatesAutoresizingMaskIntoConstraints = true
        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let cutoutView = UIView(frame: bounds)
        cutoutView.translatesAutoresizingMaskIntoConstraints = true
        cutoutView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let view = UIView(frame: bounds)
        view.addSubview(previewView)
        view.addSubview(cutoutView)

        self.previewView = previewView
        self.cutoutView = cutoutView

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up preview view.
        previewView.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

        // Set up cutout view.
        cutoutView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        cutoutView.layer.mask = maskLayer

        // Starting the capture session is a blocking call. Perform setup using
        // a dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()

            // Calculate region of interest now that the camera is setup.
            DispatchQueue.main.async {
                // Figure out initial ROI.
                self.calculateRegionOfInterest()
            }
        }

        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Only change the current orientation if the new one is landscape or
        // portrait. You can't really do anything about flat or unknown.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape {
            currentOrientation = deviceOrientation
        }

        // Handle device orientation in the preview layer.
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            if let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) {
                videoPreviewLayerConnection.videoOrientation = newVideoOrientation
            }
        }

        // Orientation changed: figure out new region of interest (ROI).
        calculateRegionOfInterest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCutout()
    }

    // MARK: - Setup

    func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.55
        let desiredWidthRatio = 0.8
        let maxPortraitWidth = 0.8

        let size: CGSize
        if currentOrientation.isPortrait || currentOrientation == .unknown {
            size = CGSize(
                width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth),
                height: desiredHeightRatio / bufferAspectRatio
            )
        } else {
            size = CGSize(width: desiredWidthRatio, height: desiredHeightRatio)
        }
        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size

        // ROI changed, update transform.
        setupOrientationAndTransform()

        // Update the cutout to match the new ROI.
        DispatchQueue.main.async {
            // Wait for the next run cycle before updating the cutout. This
            // ensures that the preview layer already has its new orientation.
            self.updateCutout()
        }
    }

    func updateCutout() {
        // Figure out where the cutout ends up in layer coordinates.
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = previewView.videoPreviewLayer
            .layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))

        // Create the mask.
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer.path = path.cgPath
    }

    func setupOrientationAndTransform() {
        // Recalculate the affine transform between Vision coordinates and AVF coordinates.
        // Compensate for region of interest.
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y)
            .scaledBy(x: roi.width, y: roi.height)

        // Compensate for orientation (buffers always come in the same orientation).
        switch currentOrientation {
        case .landscapeLeft:
            textOrientation = CGImagePropertyOrientation.up
            uiRotationTransform = CGAffineTransform.identity
        case .landscapeRight:
            textOrientation = CGImagePropertyOrientation.down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
        case .portraitUpsideDown:
            textOrientation = CGImagePropertyOrientation.left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        default: // We default everything else to .portraitUp
            textOrientation = CGImagePropertyOrientation.right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }

        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform)
            .concatenating(uiRotationTransform)
    }

    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: AVMediaType.video,
            position: .back
        ) else {
            Logger.eRpApp.debug("Could not create capture device.")
            return
        }
        self.captureDevice = captureDevice

        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            Logger.eRpApp.debug("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }

        // Configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        ]

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            Logger.eRpApp.debug("Could not add VDO output")
            return
        }

        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            Logger.eRpApp.debug("Could not set zoom level due to error: \(error)")
            return
        }

        captureSession.startRunning()
    }

    // MARK: - UI drawing and interaction

    func pauseCaptureSession() {
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
        }
    }

    @IBAction
    func handleTap(_: UITapGestureRecognizer) {
        captureSessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    var request: VNRecognizeTextRequest!
    // Temporal string tracker
    let numberTracker = StringTracker()

    // MARK: - Text recognition

    // Vision recognition handler.
    func recognizeTextHandler(request: VNRequest, error _: Error?) {
        var numbers = [String]()

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }

        let maximumCandidates = 1

        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }

            if let result = candidate.string.extractCAN() {
                let (range, number) = result
                // Number may not cover full visionResult. Extract bounding box
                // of substring.
                if let box = try? candidate.boundingBox(for: range)?.boundingBox {
                    if checkValidBox(box: box) {
                        numbers.append(number)
                    }
                }
            }
        }

        // Log any found numbers.
        numberTracker.logFrame(strings: numbers)

        // Check if we have any temporally stable numbers.
        if let sureNumber = numberTracker.getStableString() {
            DispatchQueue.main.async { [weak self] in
                self?.canScanned?(ScanCAN(value: sureNumber))
                self?.pauseCaptureSession()
                self?.numberTracker.reset(string: sureNumber)
            }
        }
    }

    func checkValidBox(box: CGRect) -> Bool {
        box.minX > 0.5 * box.width &&
            box.maxX + 0.5 * box.width < 1.0
    }
}

extension CANCameraScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from _: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            request.recognitionLevel = .fast
            request.usesLanguageCorrection = false
            request.regionOfInterest = regionOfInterest

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                       orientation: textOrientation,
                                                       options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                Logger.eRpApp.debug("\(error.localizedDescription)")
            }
        }
    }
}

extension String {
    func extractCAN() -> (Range<String.Index>, String)? {
        if ScanCAN(value: self).isValid,
           let range = range(of: self) {
            return (range, self)
        }
        return nil
    }
}

extension CANCameraScannerViewController {
    class StringTracker {
        var frameIndex: Int64 = 0

        typealias StringObservation = (lastSeen: Int64, count: Int64)

        // Dictionary of seen strings. Used to get stable recognition before displaying anything.
        var seenStrings = [String: StringObservation]()
        var bestCount = Int64(0)
        var bestString = ""

        func logFrame(strings: [String]) {
            for string in strings {
                if seenStrings[string] == nil {
                    seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
                }
                seenStrings[string]?.lastSeen = frameIndex
                seenStrings[string]?.count += 1
            }

            var obsoleteStrings = [String]()

            // Go through strings and prune any that have not been seen in while.
            // Also find the (non-pruned) string with the greatest count.
            for (string, obs) in seenStrings {
                // Remove previously seen text after 30 frames (~1s).
                if obs.lastSeen < frameIndex - 30 {
                    obsoleteStrings.append(string)
                }

                // Find the string with the greatest count.
                let count = obs.count
                if !obsoleteStrings.contains(string), count > bestCount {
                    bestCount = Int64(count)
                    bestString = string
                }
            }
            // Remove old strings.
            for string in obsoleteStrings {
                seenStrings.removeValue(forKey: string)
            }

            frameIndex += 1
        }

        func getStableString() -> String? {
            // Require the recognizer to see the same string at least 10 times.
            if bestCount >= 10 {
                return bestString
            }
            return nil
        }

        func reset(string: String) {
            seenStrings.removeValue(forKey: string)
            bestCount = 0
            bestString = ""
        }
    }
}

extension CANCameraScannerViewController {
    class PreviewView: UIView {
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            guard let layer = layer as? AVCaptureVideoPreviewLayer else {
                fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer." +
                    "Check PreviewView.layerClass implementation.")
            }

            return layer
        }

        var session: AVCaptureSession? {
            get { videoPreviewLayer.session }
            set { videoPreviewLayer.session = newValue }
        }

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}
