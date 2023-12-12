//
//  Copyright (c) 2023 gematik GmbH
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
@testable import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class CameraViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    /// This will create a start screen
    func testCameraView_Started() {
        let sut = ErxTaskScannerView(store: ScannerDomain.Dummies.store)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
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

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
