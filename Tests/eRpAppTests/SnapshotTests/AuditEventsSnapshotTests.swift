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
import ComposableArchitecture
@testable import eRpApp
import IdentifiedCollections
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class AuditEventsSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testAuditEventsLoadedSnapshots() {
        let elements: [AuditEventsDomain.State.AuditEvent] = [
            .init(id: "abc",
                  title: "Medication1",
                  description:
                  "A very long description for a very very important audit event for some very " +
                      "interesting medication.",
                  date: "2021-01-20, 16:21"),
            .init(id: "def",
                  title: "Medication2",
                  description:
                  "A very long description for a very very important audit event for some very " +
                      "interesting medication.",
                  date: "2021-01-20, 16:22"),
            .init(id: "ghi",
                  title: "Medication3",
                  description:
                  "A very long description for a very very important audit event for some very " +
                      "interesting medication.",
                  date: "2021-01-20, 16:23"),
        ]

        let sut = NavigationView {
            AuditEventsView(
                store: .init(
                    initialState: .init(profileUUID: UUID(),
                                        entries: IdentifiedArrayOf(uniqueElements: elements),
                                        lastUpdated: "Last Edited 2021-01-20, 16:21"),
                    reducer: EmptyReducer()
                )
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testEmptyAuditEventsSnapshots() {
        let sut = NavigationView {
            AuditEventsView(
                store: .init(initialState: .init(profileUUID: UUID(),
                                                 entries: [],
                                                 lastUpdated: nil),
                             reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoadingAuditEventsSnapshots() {
        let sut = NavigationView {
            AuditEventsView(
                store: .init(
                    initialState: .init(profileUUID: UUID(),
                                        entries: nil,
                                        lastUpdated: nil),
                    reducer: EmptyReducer()
                )
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
