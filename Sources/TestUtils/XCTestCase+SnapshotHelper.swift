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

import eRpResources
import SnapshotTesting
import SwiftUI
import XCTest

// Snapshots only for iOS Targets
#if canImport(UIKit)
import UIKit

/// The default `precision` to use if a specific value is not provided.
private let defaultPrecision: Float = 1
/// The default `perceptualPrecision` to use if a specific value is not provided.
private let defaultPerceptualPrecision: Float = 1

extension ViewImageConfig {
    func noInsets() -> Self {
        ViewImageConfig(safeArea: .zero, size: size, traits: traits)
    }
}

extension XCTestCase {
    /// Snapshotting configurations for Figma reference images in light and dark mode.
    public func figmaReference<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
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

    /// Snapshotting configurations for different modes including light, dark, and accessibility sizes.
    public func snapshotModi<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
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

    /// Snapshotting configurations for accessibility size XL.
    public func snapshotModiContentSizeXL<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
        [
            "accessibilityXL": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
            ),
        ]
    }

    /// Snapshotting configurations for current device in different modes.
    public func snapshotModiCurrentDevice<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
        [
            "iPhoneXsMax.light":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhone13.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .medium)
                ),
            "iPhone14.light.xs":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhone13.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .extraSmall)
                ),
            "iPhone14.dark":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhone13.noInsets()),
                    traits: UITraitCollection { mutableTraits in
                        mutableTraits.userInterfaceStyle = .dark
                        mutableTraits.preferredContentSizeCategory = .medium
                    }
                ),
        ]
    }

    /// Snapshotting configurations for different devices in light mode.
    public func snapshotModiOnDevices<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
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

    /// Snapshotting configurations for different devices in light mode with accessibility sizes.
    public func snapshotModiOnDevicesWithAccessibility<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
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

    /// Snapshotting configurations for different devices in light mode with accessibility size XL.
    public func snapshotModiOnDevicesWithAccessibilityXL<T: SwiftUI.View>() -> [String: Snapshotting<T, UIImage>] {
        [
            "iPhoneX.light.xl":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneX.noInsets()),
                    traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
                ),
        ]
    }

    /// Snapshotting configurations for different devices with theming (light and dark mode).
    public func snapshotModiOnDevicesWithTheming<T: SwiftUI.View>(mode: UIUserInterfaceStyle = .dark)
        -> [String: Snapshotting<T, UIImage>] {
        [
            "iPhoneX.\(mode == .dark ? "dark" : "light")":
                .image(
                    precision: defaultPrecision,
                    perceptualPrecision: defaultPerceptualPrecision,
                    layout: .device(config: ViewImageConfig.iPhoneX.noInsets()),
                    traits: UITraitCollection { mutableTraits in
                        mutableTraits.userInterfaceStyle = mode
                        mutableTraits.preferredContentSizeCategory = .medium
                    }
                ),
        ]
    }
}

/// Helper to fix offset problem in snapshot tests.
@MainActor
public enum SnapshotHelper {
    private static var didRecord = false

    /// Fixes an offset problem that occurs when taking snapshots for the first time in a test run.
    public static func fixOffsetProblem() {
        guard didRecord == false else { return }

        assertSnapshot(
            of: OffsetPreview(.image(layout: .device(config: .iPhone14(.portrait)))),
            as: .image(
                precision: 0.0,
                layout: .device(config: .iPhone14(.portrait))
            ),
            named: "dummy",
            record: false
        )
        didRecord = true
    }
}

open class ERPSnapshotTestCase: XCTestCase {
    override open func invokeTest() {
        withSnapshotTesting(record: .failed, diffTool: "open") {
            super.invokeTest()
        }
    }

    @MainActor
    override open func setUp() {
        super.setUp()
        SnapshotHelper.fixOffsetProblem()
    }
}

struct OffsetPreview: View {
    let snapshotting: Snapshotting<AnyView, UIImage>

    init(_ snapshotting: Snapshotting<AnyView, UIImage>) {
        self.snapshotting = snapshotting
    }

    var body: some View {
        Snapshot(snapshotting) {
            NavigationStack {
                Text("*")
                    .navigationTitle("⚕︎ Redeem")
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}

struct Snapshot<Content: View>: View {
    private let content: () -> Content
    @State private var image: Image?
    private let snapshotting: Snapshotting<AnyView, UIImage>

    init(_ snapshotting: Snapshotting<AnyView, UIImage>,
         @ViewBuilder
         _ content: @escaping () -> Content) {
        self.content = content
        self.snapshotting = snapshotting
    }

    var body: some View {
        ZStack {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            snapshotting
                .snapshot(AnyView(content()))
                .run { image = Image(uiImage: $0) }
        }
    }
}

extension ViewImageConfig {
    static func iPhone14(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 47, bottom: 21, right: 47)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 47, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone14(orientation))
    }
}

extension UITraitCollection {
    static func iPhone14(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        switch orientation {
        case .landscape:
            return UITraitCollection { mutableTraits in
                mutableTraits.userInterfaceIdiom = .phone
                mutableTraits.horizontalSizeClass = .regular
                mutableTraits.verticalSizeClass = .compact
            }
        case .portrait:
            return UITraitCollection { mutableTraits in
                mutableTraits.userInterfaceIdiom = .phone
                mutableTraits.horizontalSizeClass = .compact
                mutableTraits.verticalSizeClass = .regular
            }
        }
    }
}

#endif
