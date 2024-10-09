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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class MedicationReminderListViewSnapshotTests: ERPSnapshotTestCase {
    func testMedicationReminderListView() {
        let sut = MedicationReminderListView(
            store: .init(
                initialState: .init(
                    profileMedicationReminder:
                    [
                        Self.Fixtures.profileMedicationReminder1,
                        Self.Fixtures.profileMedicationReminder2,
                    ]
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

extension MedicationReminderListViewSnapshotTests {
    enum Fixtures {
        static let profileA = UserProfile(
            from: Profile(
                name: "Spooky Dennis",
                identifier: UUID(),
                created: Date(),
                givenName: "Dennis",
                familyName: "Doe",
                insurance: "Spooky BKK",
                insuranceId: "X112233445",
                color: .blue,
                lastAuthenticated: Date().addingTimeInterval(-60 * 8),
                erxTasks: []
            ),
            isAuthenticated: true
        )
        static let profileB = UserProfile(
            from: Profile(
                name: "Gruseliger Günther",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .blue,
                lastAuthenticated: nil,
                erxTasks: []
            ),
            isAuthenticated: false
        )

        static let profileMedicationReminder1: MedicationReminderListDomain.ProfileMedicationReminder = {
            let date = Date(timeIntervalSinceReferenceDate: 0)
            let medicationSchedule1 = MedicationSchedule(
                id: UUID(1),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Medication Schedule",
                dosageInstructions: "Medication Instruction",
                taskId: "123.4567.890",
                isActive: true,
                entries: IdentifiedArray(uniqueElements: [])
            )
            let medicationSchedule2 = MedicationSchedule(
                id: UUID(2),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Gerafenac Salbe 30 mg",
                dosageInstructions: "Some medication instruction",
                taskId: "123.4567.891",
                isActive: false,
                entries: IdentifiedArray(uniqueElements: [])
            )

            return MedicationReminderListDomain.ProfileMedicationReminder(
                profile: profileA,
                medicationProfileReminderList: [medicationSchedule1, medicationSchedule2]
            )
        }()

        static let profileMedicationReminder2: MedicationReminderListDomain.ProfileMedicationReminder = {
            let date = Date(timeIntervalSinceReferenceDate: 0)
            let medicationSchedule1 = MedicationSchedule(
                id: UUID(10),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Medium akut",
                dosageInstructions: "Medication Instruction",
                taskId: "123.4567.890",
                isActive: true,
                entries: IdentifiedArray(uniqueElements: [])
            )
            let medicationSchedule2 = MedicationSchedule(
                id: UUID(11),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Malarium 20g",
                dosageInstructions: "Some medication instruction",
                taskId: "123.4567.891",
                isActive: false,
                entries: IdentifiedArray(uniqueElements: [])
            )
            let medicationSchedule3 = MedicationSchedule(
                id: UUID(12),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Hyperbol Tablette stark",
                dosageInstructions: "Some medication instruction",
                taskId: "123.4567.891",
                isActive: true,
                entries: IdentifiedArray(uniqueElements: [])
            )

            return MedicationReminderListDomain.ProfileMedicationReminder(
                profile: profileB,
                medicationProfileReminderList: [medicationSchedule1, medicationSchedule2, medicationSchedule3]
            )
        }()
    }
}
