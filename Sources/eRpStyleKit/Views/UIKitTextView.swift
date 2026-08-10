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

import SwiftUI
import UIKit

public struct UIKitTextView: UIViewRepresentable {
    private var attributedString: NSAttributedString
    var onLinkTap: (URL) -> Void

    public init(
        attributedString: AttributedString,
        font: UIFont = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular),
        foregroundColor: UIColor = UIColor.label,
        onLinkTap: @escaping (URL) -> Void
    ) {
        UITextView.appearance().linkTextAttributes = [.foregroundColor: UIColor.primary700]

        var result = attributedString
        let range = result.startIndex ..< result.endIndex
        result[range].font = font
        result[range].foregroundColor = foregroundColor

        // Enable underlines for links
        for run in result.runs {
            guard run.attributes.link != nil else { continue }

            result[run.range].underlineStyle = .single
            result[run.range].mergeAttributes(AttributeContainer([.underlineStyle: 1]))
            result[run.range].underlineColor = UIColor.primary700
        }

        self.attributedString = NSAttributedString(result)
        self.onLinkTap = onLinkTap
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.anchorPoint = .zero
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context _: Context) {
        uiView.attributedText = attributedString
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context _: Context) -> CGSize? {
        let width = proposal.width ?? uiView.bounds.width
        let targetWidth = (width.isFinite && width > 0) ? width : UIView.layoutFittingExpandedSize.width
        let fittingSize = uiView.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: targetWidth, height: ceil(fittingSize.height))
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextView

        public init(parent: UIKitTextView) {
            self.parent = parent
        }

        public func textView(_: UITextView, primaryActionFor textItem: UITextItem,
                             defaultAction: UIAction) -> UIAction? {
            switch textItem.content {
            case let .link(url):
                if url.absoluteString.hasPrefix("https://") {
                    return defaultAction
                } else {
                    return UIAction { [parent] _ in
                        parent.onLinkTap(url)
                    }
                }
            case .textAttachment,
                 .tag:
                return defaultAction
            @unknown default:
                return defaultAction
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
