//
//  Copyright (c) 2021 gematik GmbH
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

import SwiftUI

struct LinksAwareTextView: UIViewRepresentable {
    typealias URLKey = String
    typealias URLString = String
    typealias LinksStrings = [URLKey: URLString]

    @Binding private var calculatedHeight: CGFloat

    private let attributedString: NSMutableAttributedString

    init(text: String,
         links: LinksStrings,
         calculatedHeight: Binding<CGFloat>) {
        _calculatedHeight = calculatedHeight

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        attributedString = NSMutableAttributedString(string: text,
                                                     attributes: [.paragraphStyle: style])

        for (key, string) in links {
            guard let range = text.range(of: key) else { continue }

            attributedString.addAttribute(.link,
                                          value: string,
                                          range: NSRange(range, in: text))
        }
    }

    func makeUIView(context _: Context) -> UITextView {
        let textView = NonSelectableTextView()
        textView.attributedText = attributedString
        textView.textColor = UIColor(Asset.Colors.primary900.color)

        return textView
    }

    func updateUIView(_ uiView: UITextView,
                      context _: Context) {
        let newSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width,
                                                 height: .greatestFiniteMagnitude))

        guard calculatedHeight != newSize.height else { return }

        DispatchQueue.main.async { $calculatedHeight.wrappedValue = newSize.height }
    }

    private class NonSelectableTextView: UITextView, UITextViewDelegate {
        override var canBecomeFirstResponder: Bool { false }
    }
}
