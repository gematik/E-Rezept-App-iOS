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

import SnapshotTesting
import SwiftUI
import XCTest

extension XCTestCase {
    func snapshotModi<T>() -> [String: Snapshotting<T, UIImage>] where T: SwiftUI.View {
        [
            "light": .image,
            "dark": .image(precision: 1, traits: UITraitCollection(userInterfaceStyle: .dark)),
            "accessibilityBig": .image(traits:
                UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)),
            "accessibilitySmall": .image(traits: UITraitCollection(preferredContentSizeCategory: .extraSmall)),
        ]
    }

    func snapshotModiOnDevices<T>() -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneSe.light":
                .image(
                    layout: .device(config: ViewImageConfig.iPhoneSe),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhone8.light":
                .image(
                    layout: .device(config: ViewImageConfig.iPhone8),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhoneX.light":
                .image(
                    layout: .device(config: ViewImageConfig.iPhoneX),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhoneXsMax.light":
                .image(
                    layout: .device(config: ViewImageConfig.iPhoneXsMax),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
        ]
    }

    func snapshotModiOnDevicesWithAccessibility<T>() -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneX.light.xs":
                .image(
                    layout: .device(config: ViewImageConfig.iPhoneX),
                    traits: UITraitCollection(preferredContentSizeCategory: .extraSmall)
                ),
//            "iPhoneX.light.xxxl":
//                .image(
//                    layout: .device(config: ViewImageConfig.iPhoneX),
//                    traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
//                ),
        ]
    }

    func snapshotModiOnDevicesWithTheming<T>(mode: UIUserInterfaceStyle = .dark) -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneX.\(mode == .dark ? "dark" : "light")":
                .image(
                    layout: .device(config: ViewImageConfig.iPhoneX),
                    traits: UITraitCollection(traitsFrom: [
                        UITraitCollection(userInterfaceStyle: mode),
                        UITraitCollection(preferredContentSizeCategory: .medium),
                    ])
                ),
        ]
    }
}

struct TransparencyPattern: ViewModifier {
    private class TestBundleAnchor {}

    static var testBundle = Bundle(for: TestBundleAnchor.self)

    func body(content: Content) -> some View {
        content
            .background(
                Image("transparent_bg", bundle: Self.testBundle)
                    .resizable(resizingMode: .tile)
            )
    }
}

extension View {
    func transparencyPattern() -> some View {
        modifier(TransparencyPattern())
    }
}

extension UIImage {
    private class TestBundleAnchor {}

    static var testBundle = Bundle(for: TestBundleAnchor.self)

    convenience init?(testBundleNamed: String) {
        self.init(named: testBundleNamed, in: Self.testBundle, with: nil)
    }
}
