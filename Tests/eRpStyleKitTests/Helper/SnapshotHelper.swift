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
private let defaultPrecision: Float = 1
/// The default `perceptualPrecision` to use if a specific value is not provided.
private let defaultPerceptualPrecision: Float = 1

extension XCTestCase {
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
        ]
    }
}

@MainActor
enum SnapshotHelper {
    private static var didRecord = false

    static func fixOffsetProblem() {
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

class ERPSnapshotTestCase: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .failed, diffTool: "open") {
            super.invokeTest()
        }
    }

    @MainActor
    override func setUp() {
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
        Snapshot(self.snapshotting) {
            NavigationStack {
                Text("*")
                    .navigationTitle("⚕︎ Redeem")
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}

struct Snapshot<Content>: View where Content: View {
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
            self.image?
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            self.snapshotting
                .snapshot(AnyView(self.content()))
                .run { self.image = Image(uiImage: $0) }
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
        let base: [UITraitCollection] = [
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone),
        ]

        switch orientation {
        case .landscape:
            return .init(traitsFrom: base + [
                .init(horizontalSizeClass: .regular),
                .init(verticalSizeClass: .compact),
            ])
        case .portrait:
            return .init(traitsFrom: base + [
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
            ])
        }
    }
}
