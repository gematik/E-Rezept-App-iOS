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

struct UIKitTextView: UIViewRepresentable {
    private var attributedString: NSMutableAttributedString
    @Binding private var calculatedHeight: CGFloat
    var onLinkTap: (URL) -> Void

    init(
        attributedString: AttributedString,
        calculatedHeight: Binding<CGFloat>,
        font: UIFont = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular),
        foregroundColor: UIColor = UIColor.label,
        onLinkTap: @escaping (URL) -> Void
    ) {
        _calculatedHeight = calculatedHeight
        let result = NSMutableAttributedString(attributedString)
        result.addAttribute(.font,
                            value: font,
                            range: NSRange(location: 0, length: result.length))
        result.addAttribute(.foregroundColor,
                            value: foregroundColor,
                            range: NSRange(location: 0, length: result.length))
        self.attributedString = result
        self.onLinkTap = onLinkTap
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.anchorPoint = .zero
        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        let newSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width,
                                                 height: .greatestFiniteMagnitude))

        guard calculatedHeight != newSize.height else { return }

        DispatchQueue.main.async { $calculatedHeight.wrappedValue = newSize.height }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextView

        init(parent: UIKitTextView) {
            self.parent = parent
        }

        func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange,
                      interaction _: UITextItemInteraction) -> Bool {
            if URL.absoluteString.hasPrefix("https://") {
                // return true when normal https link
                return true
            } else {
                // handle custom link
                parent.onLinkTap(URL)
                return false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
