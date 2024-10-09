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

import SwiftUI
import UIKit

struct BlurEffectView: UIViewRepresentable {
    init(style: UIBlurEffect.Style, isEnabled _: Bool) {
        self.style = style
        strength = 1.0
    }

    init(style: UIBlurEffect.Style, strength: CGFloat) {
        self.style = style
        self.strength = strength
    }

    let style: UIBlurEffect.Style
    var isEnabled: Bool {
        strength > 0.0
    }

    let strength: CGFloat

    func makeUIView(context _: UIViewRepresentableContext<Self>)
        -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiVisualEffectView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {
        if uiVisualEffectView.effect == nil {
            uiVisualEffectView.effect = UIBlurEffect(style: style)
        }
        uiVisualEffectView.alpha = strength
    }
}
