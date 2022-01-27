//
//  Copyright (c) 2022 gematik GmbH
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

import CombineSchedulers
@testable import eRpApp
@testable import eRpLocalStorage
import SnapshotTesting
import SwiftUI
import XCTest

final class CreatePasswordViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testCreatePasswordView_Create_Password() {
        let sut = CreatePasswordView(
            store: CreatePasswordDomain.Store(
                initialState: CreatePasswordDomain.State(
                    mode: .create,
                    password: "",
                    passwordA: "newPassword",
                    passwordB: "newPassword",
                    passwordStrength: .strong,
                    showPasswordErrorMessage: false,
                    showOriginalPasswordWrong: false
                ),
                reducer: CreatePasswordDomain.Reducer.empty,
                environment: CreatePasswordDomain.Dummies.environment
            )
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCreatePasswordView_Update_Password_Mismatch() {
        let sut = CreatePasswordView(
            store: CreatePasswordDomain.Store(
                initialState: CreatePasswordDomain.State(
                    mode: .update,
                    password: "oldPassword",
                    passwordA: "newPassworf",
                    passwordB: "newPassword",
                    passwordStrength: .strong,
                    showPasswordErrorMessage: true,
                    showOriginalPasswordWrong: true
                ),
                reducer: CreatePasswordDomain.Reducer.empty,
                environment: CreatePasswordDomain.Dummies.environment
            )
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCreatePasswordView_Update_Password_Insufficient_Strength() {
        let sut = CreatePasswordView(
            store: CreatePasswordDomain.Store(
                initialState: CreatePasswordDomain.State(
                    mode: .update,
                    password: "oldPassword",
                    passwordA: "newPassword",
                    passwordB: "newPassword",
                    showPasswordErrorMessage: true,
                    showOriginalPasswordWrong: true
                ),
                reducer: CreatePasswordDomain.Reducer.empty,
                environment: CreatePasswordDomain.Dummies.environment
            )
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
