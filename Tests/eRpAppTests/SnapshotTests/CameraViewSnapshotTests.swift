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
@testable import eRpFeatures
@testable import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class CameraViewSnapshotTests: ERPSnapshotTestCase {
    /// This will create a start screen
    func testCameraView_Started() {
        let sut = ErxTaskScannerView(store: ScannerDomain.Dummies.store)
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    /// This will create a screen with a successfull scanned prescription
    func testCameraView_Success() {
        let scannedString = """
        {"urls":["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
        """
        let scannedTasks = try! ScannedErxTask.from(tasks: scannedString)
        let expectedTaskBatches = Set([scannedTasks])
        let sut = ErxTaskScannerView(
            store: ScannerDomain.Dummies.store(
                with: ScannerDomain.State(scanState: .value(scannedTasks),
                                          acceptedTaskBatches: expectedTaskBatches)
            )
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
