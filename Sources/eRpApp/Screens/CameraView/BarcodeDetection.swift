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

import Dependencies
import PDFKit
import UIKit
import Vision

struct BarcodeDetection {
    var detectImage: @Sendable (UIImage) async throws -> [ScanOutput]
    var detectDocument: @Sendable (URL) async throws -> [ScanOutput]
}

extension DependencyValues {
    var barcodeDetection: BarcodeDetection {
        get { self[BarcodeDetection.self] }
        set { self[BarcodeDetection.self] = newValue }
    }
}

extension BarcodeDetection: DependencyKey {
    public static let liveValue = Self(
        detectImage: { image in
            guard let ciImage = CIImage(image: image) else {
                return [.invalidCode]
            }

            return try await detectBarCode(from: ciImage)
        },
        detectDocument: { url in
            var result = [ScanOutput]()
            for image in drawPDF(url: url) {
                guard let ciImage = CIImage(image: image) else { continue }
                try await result.append(contentsOf: detectBarCode(from: ciImage))
            }

            return result.isEmpty ? [.invalidCode] : result
        }
    )

    private static func detectBarCode(from image: CIImage) async throws -> [ScanOutput] {
        let imageRequestHandler = VNImageRequestHandler(
            ciImage: image,
            orientation: .up,
            options: [:]
        )

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    continuation.resume(returning: [.invalidCode])
                    return
                }

                let result: [ScanOutput] = observations.map {
                    guard let code = $0 as? VNBarcodeObservation else {
                        return .invalidCode
                    }
                    return .text(
                        code.payloadStringValue?.dropGS1Prefix()
                    )
                }
                continuation.resume(returning: result)
            }
            request.symbologies = [.aztec, .dataMatrix, .qr]
            try? imageRequestHandler.perform([request])
        }
    }

    private static func drawPDF(url: URL) -> [UIImage] {
        guard url.startAccessingSecurityScopedResource(),
              let document = PDFDocument(url: url)
        else { return [] }
        defer { url.stopAccessingSecurityScopedResource() }

        var images = [UIImage]()

        for pageNumber in 0 ..< document.pageCount {
            // Get a page of the PDF document.
            guard let page = document.page(at: pageNumber) else {
                continue
            }

            // Fetch the page rect for the page we want to render.
            let pageRect = page.bounds(for: .mediaBox)

            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { ctx in
                // Set and fill the background color.
                UIColor.white.set()
                ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))

                // Translate the context so that we only draw the `cropRect`.
                ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)

                // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                // Draw the PDF page.
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }
            images.append(image)
        }

        return images
    }
}
