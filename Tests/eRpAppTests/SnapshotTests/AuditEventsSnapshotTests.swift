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
import IdentifiedCollections
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class AuditEventsSnapshotTests: ERPSnapshotTestCase {
    func testAuditEventsLoadedSnapshots() {
        let elements: [AuditEventsDomain.State.AuditEvent] = [
            .init(
                id: "abc",
                title: "Medication1",
                description:
                "A very long description for a very very important audit event for some very " +
                    "interesting medication.",
                date: "2021-01-20, 16:21",
                agentName: nil,
                agentTelematikId: nil
            ),
            .init(
                id: "def",
                title: "Medication2",
                description:
                "A very long description for a very very important audit event for some very " +
                    "interesting medication.",
                date: "2021-01-20, 16:22",
                agentName: nil,
                agentTelematikId: nil
            ),
            .init(
                id: "ghi",
                title: "Medication3",
                description:
                "A very long description for a very very important audit event for some very " +
                    "interesting medication.",
                date: "2021-01-20, 16:23",
                agentName: nil,
                agentTelematikId: nil
            ),
        ]

        let sut = NavigationStack {
            AuditEventsView(
                store: .init(
                    initialState: .init(profileUUID: UUID(),
                                        entries: IdentifiedArrayOf(uniqueElements: elements))

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testEmptyAuditEventsSnapshots() {
        let sut = NavigationStack {
            AuditEventsView(
                store: .init(
                    initialState: .init(
                        profileUUID: UUID(),
                        entries: IdentifiedArrayOf<AuditEventsDomain.State.AuditEvent>()
                    )
                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAuditEventsListWhenAuthenticationNeeded() {
        let sut = NavigationStack {
            AuditEventsView(
                store: .init(
                    initialState: .init(profileUUID: UUID(), entries: nil, needsAuthentication: true)

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoadingAuditEventsSnapshots() {
        let sut = NavigationStack {
            AuditEventsView(
                store: .init(
                    initialState: .init(profileUUID: UUID(), entries: nil)

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
