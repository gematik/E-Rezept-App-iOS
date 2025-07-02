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

import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

extension UIImage {
    private class TestBundleAnchor {}

    static let testBundle = Bundle(for: TestBundleAnchor.self)

    convenience init?(testBundleNamed: String) {
        self.init(named: testBundleNamed, in: Self.testBundle, with: nil)
    }
}

extension ViewImageConfig {
    func noInsets() -> Self {
        .init(safeArea: .init(top: 47, left: 0, bottom: 0, right: 0), size: size, traits: traits)
    }
}

@MainActor
enum SnapshotHelper {
    private static var didRecord = false

    static func fixOffsetProblem() {
        guard didRecord == false else { return }

        assertSnapshot(
            of: OffsetPreview(
                .image(layout: .device(config: .iPhone14(.portrait)))
            ),
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

@MainActor
class ERPSnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()

        SnapshotHelper.fixOffsetProblem()
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
