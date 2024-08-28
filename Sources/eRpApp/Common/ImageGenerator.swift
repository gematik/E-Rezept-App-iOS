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
import Foundation
import UIKit

struct ImageGenerator {
    var addCaption: (_ image: UIImage, _ boldText: String, _ text: String) -> UIImage
}

extension ImageGenerator: DependencyKey {
    static var liveValue: ImageGenerator = .init { image, boldText, text in
        Self.addCaption(to: image, withBoldText: boldText, text: text)
    }

    static var testValue: ImageGenerator = .init { _, _, _ in
        UIImage()
    }

    // swiftlint:disable:next function_body_length
    private static func addCaption(to image: UIImage, withBoldText boldText: String, text: String) -> UIImage {
        let imagePadding: CGFloat = 16.0
        let textPadding: CGFloat = 16.0
        let textHeight: CGFloat = 21.0
        let boldTextHeight: CGFloat = 24.0
        let totalTextHeight = textPadding + textHeight
        let totalBoldTextHeight = textPadding + boldTextHeight
        let totalImageSpan = image.size.width + imagePadding + imagePadding
        let cornerRadius: CGFloat = 12.0

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: totalImageSpan,
                height: totalImageSpan + totalTextHeight + totalTextHeight
            )
        )

        return renderer.image { _ in
            UIColor.white.setFill()
            let roundedRect = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: renderer.format.bounds.size),
                cornerRadius: cornerRadius
            )
            roundedRect.fill()

            image.draw(at: CGPoint(x: imagePadding, y: imagePadding))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16.0),
                .paragraphStyle: paragraphStyle,
            ]

            let title = NSAttributedString(string: boldText, attributes: titleAttributes)
            title.draw(
                with: CGRect(
                    x: imagePadding,
                    y: totalImageSpan,
                    width: image.size.width,
                    height: totalBoldTextHeight
                ),
                options: .usesLineFragmentOrigin,
                context: nil
            )

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14.0),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle,
            ]

            let medicationNames = NSAttributedString(string: text, attributes: textAttributes)
            medicationNames.draw(
                with: CGRect(
                    x: imagePadding,
                    y: totalImageSpan + totalTextHeight,
                    width: image.size.width,
                    height: totalTextHeight
                ),
                options: .usesLineFragmentOrigin,
                context: nil
            )
        }
    }
}

// MARK: TCA Dependency

struct ImageGeneratorDependency: DependencyKey {
    static let liveValue: ImageGenerator = .liveValue

    static let previewValue: ImageGenerator = .liveValue

    static let testValue: ImageGenerator = .testValue
}

extension DependencyValues {
    var imageGenerator: ImageGenerator {
        get { self[ImageGeneratorDependency.self] }
        set { self[ImageGeneratorDependency.self] = newValue }
    }
}
