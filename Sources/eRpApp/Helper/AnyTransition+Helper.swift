//
//  Copyright (c) 2023 gematik GmbH
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

extension AnyTransition {
    static func repeating<Modifier: ViewModifier>(
        from: Modifier,
        to: Modifier, // swiftlint:disable:this identifier_name
        duration: Double = 1
    )
        -> AnyTransition {
        .asymmetric(
            insertion: AnyTransition
                .modifier(active: from, identity: to)
                .animation(Animation.easeInOut(duration: duration).repeatForever())
                .combined(with: .opacity),
            removal: .opacity
        )
    }

    struct Opacity: ViewModifier {
        private let opacity: Double

        init(_ opacity: Double) {
            self.opacity = opacity
        }

        func body(content: Content) -> some View {
            content.opacity(opacity)
        }
    }

    struct Scale: ViewModifier {
        private let scale: Double

        init(_ scale: Double) {
            self.scale = scale
        }

        func body(content: Content) -> some View {
            content.scaleEffect(scale)
        }
    }

    static func endlessFade(from fromOpacity: Double, to toOpacity: Double, duration: Double = 1) -> AnyTransition {
        repeating(from: Opacity(fromOpacity), to: Opacity(toOpacity), duration: duration)
    }

    static func endlessScale(from fromScale: Double, to toScale: Double, duration: Double = 1) -> AnyTransition {
        repeating(from: Scale(fromScale), to: Scale(toScale), duration: duration)
    }
}
