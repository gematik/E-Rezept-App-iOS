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

import SnapshotTesting
import SwiftUI
import XCTest

/// The default `precision` to use if a specific value is not provided.
private let defaultPrecision: Float = 0.99
/// The default `perceptualPrecision` to use if a specific value is not provided.
private let defaultPerceptualPrecision: Float = 0.93

extension ViewImageConfig {
    func noInsets() -> Self {
        .init(safeArea: .zero, size: size, traits: traits)
    }
}

extension XCTestCase {
    func figmaReference<T>() -> [String: Snapshotting<T, UIImage>] where T: SwiftUI.View {
        [
            "light": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision
            ),
            "dark": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
        ]
    }

    func snapshotModi<T>() -> [String: Snapshotting<T, UIImage>] where T: SwiftUI.View {
        [
            "light": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision
            ),
            "dark": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
            "accessibilityBig": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
            ),
            "accessibilitySmall": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(preferredContentSizeCategory: .extraSmall)
            ),
        ]
    }

    func snapshotModiOnDevices<T>() -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneSe.light":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneSe.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhone8.light":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhone8.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhoneX.light":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneX.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhoneXsMax.light":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneXsMax.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
        ]
    }

    func snapshotModiOnDevicesWithAccessibility<T>() -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneX.light.xs":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneX.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .extraSmall)
                ),
        ]
    }

    func snapshotModiOnDevicesWithTheming<T>(mode: UIUserInterfaceStyle = .dark) -> [String: Snapshotting<T, UIImage>]
        where T: SwiftUI.View {
        [
            "iPhoneX.\(mode == .dark ? "dark" : "light")":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneX.noInsets()),
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

enum SnapshotHelper {
    static var didRecord = false

    static func fixOffsetProblem() {
        guard didRecord == false else { return }

        let dummy = NavigationView {
            Text("*")
                .navigationTitle("⚕︎ Redeem")
        }
        assertSnapshot(matching: dummy, as: .image(precision: 0.0), named: "dummy", record: false)
        didRecord = true
    }
}

class ERPSnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"

        SnapshotHelper.fixOffsetProblem()
    }
}
