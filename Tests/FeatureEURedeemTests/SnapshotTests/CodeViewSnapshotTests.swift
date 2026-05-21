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

import Combine
import ComposableArchitecture
import eRpKit
@testable import FeatureEURedeem
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

final class CodeViewSnapshotTests: ERPSnapshotTestCase {
    func testCodeViewLoading() {
        let sut = CodeView(
            store: StoreOf<CodeDomain>(
                initialState: .init(countryCode: "PL", isLoading: true)
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCodeViewQRCode() {
        withDependencies {
            $0.date.now = "2020-07-16T09:29:00+00:00".date!
        } operation: {
            let sut = CodeView(
                store: StoreOf<CodeDomain>(
                    initialState: .init(
                        displayMode: .qrCode,
                        euAccessCode: EuAccessCode(
                            accessCode: "ABC123DEF456",
                            validUntil: "2020-07-16T09:32:00+00:00".date!,
                            createdAt: "2020-07-16T09:27:00+00:00".date!
                        ),
                        countryCode: "ES",
                        isLoading: false
                    )
                ) {
                    EmptyReducer()
                }
            )

            assertSnapshots(of: sut, as: snapshotModiOnDevices())
            assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
            assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
        }
    }

    func testCodeViewManual() {
        withDependencies {
            $0.date.now = "2020-07-16T09:29:00+00:00".date!
        } operation: {
            let sut = CodeView(
                store: StoreOf<CodeDomain>(
                    initialState: .init(
                        displayMode: .manual,
                        euAccessCode: EuAccessCode(
                            accessCode: "ABC123DEF456",
                            validUntil: "2020-07-16T09:32:00+00:00".date!,
                            createdAt: "2020-07-16T09:27:00+00:00".date!
                        ),
                        countryCode: "IT",
                        isLoading: false
                    )
                ) {
                    EmptyReducer()
                }
            )

            assertSnapshots(of: sut, as: snapshotModiOnDevices())
            assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
            assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
        }
    }
}
