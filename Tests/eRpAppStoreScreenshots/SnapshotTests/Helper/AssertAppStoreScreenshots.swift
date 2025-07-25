// swiftlint:disable:this file_name
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

// The following is heavily inspired by https://github.com/pointfreeco/isowords ❤️

import SnapshotTesting
import SwiftUI

/// The default `precision` to use if a specific value is not provided.
private let defaultPrecision: Float = 0.99
/// The default `perceptualPrecision` to use if a specific value is not provided.
private let defaultPerceptualPrecision: Float = 0.97

struct SnapshotConfig {
    let viewImageConfig: ViewImageConfig
}

let appStoreViewConfigs: [String: ViewImageConfig] = [
    "iPhone_5_5": .iPhone8Plus,
    "iPhone_6_5": .iPhoneXsMax,
]

@MainActor
func assertAppStoreSnapshots<SnapshotContent: View>(
    for view: SnapshotContent,
    backgroundColor: Color,
    colorScheme: ColorScheme,
    precision: Float = defaultPrecision,
    perceptualPrecision: Float = defaultPerceptualPrecision,
    configurations _: [String: ViewImageConfig] = appStoreViewConfigs,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    for (name, config) in appStoreViewConfigs {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            assertSnapshot(
                of: AppStorePreview(
                    .image(
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        layout: .device(config: config.noInsets())
                    ),
                    backgroundColor: backgroundColor
                ) {
                    view
                }
                .environment(\.colorScheme, colorScheme),
                as: .image(
                    precision: precision,
                    perceptualPrecision: perceptualPrecision,
                    layout: .device(config: config.noInsets())
                ),
                named: name,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
