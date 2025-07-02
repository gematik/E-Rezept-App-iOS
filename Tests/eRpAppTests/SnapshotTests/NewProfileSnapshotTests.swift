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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class NewProfileSnapshotTests: ERPSnapshotTestCase {
    func testEditProfileFigmaVariant1() {
        let sut = NavigationStack {
            NewProfileView(
                store: .init(
                    initialState: .init(
                        name: "Spooky Dennis",
                        color: .blue
                    )
                ) {
                    EmptyReducer()
                }
            )
        }
        .frame(width: 375, height: 812, alignment: .top)

        assertSnapshots(of: sut, as: figmaReference())
    }

    func testNewProfileFilledWithAcronymSnapshot() {
        let sut = NewProfileView(
            store: .init(
                initialState: .init(name: "Anna Vetter",
                                    color: .grey,
                                    image: .baby)
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
