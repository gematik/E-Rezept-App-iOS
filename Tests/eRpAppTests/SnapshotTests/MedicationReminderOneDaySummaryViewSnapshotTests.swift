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
@testable import eRpApp
import eRpKit
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class MedicationReminderOneDaySummaryViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testMedicationReminderOneDaySummaryView() {
        let sut = MedicationReminderOneDaySummaryView(
            store: .init(initialState: .init(
                entries: [UUID](),
                medicationSchedules: [
                    Self.Fixtures.medicationScheduleMock1,
                    Self.Fixtures.medicationScheduleMock2,
                ]
            )) {
                EmptyReducer()
            }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension MedicationReminderOneDaySummaryViewSnapshotTests {
    enum Fixtures {
        static let medicationScheduleMock1: MedicationSchedule = {
            let date = Date(timeIntervalSinceReferenceDate: 0)

            let entryMock1 = MedicationSchedule.Entry(
                id: UUID(1),
                title: "Entry1 Title",
                hourComponent: 10,
                minuteComponent: 5,
                dosageForm: "Dosage(s)",
                amount: "2"
            )
            let entryMock2 = MedicationSchedule.Entry(
                id: UUID(2),
                title: "Entry2 Title",
                hourComponent: 14,
                minuteComponent: 5,
                dosageForm: "Dosage(s)",
                amount: "1"
            )
            let entryMock3 = MedicationSchedule.Entry(
                id: UUID(3),
                title: "Entry3 Title",
                hourComponent: 0,
                minuteComponent: 0,
                dosageForm: "Dosage(s)",
                amount: "3"
            )
            let entryMock4 = MedicationSchedule.Entry(
                id: UUID(4),
                title: "Entry4 Title",
                hourComponent: 16,
                minuteComponent: 0,
                dosageForm: "Dosage(s)",
                amount: "2"
            )

            return MedicationSchedule(
                id: UUID(2),
                start: date,
                end: date.addingTimeInterval(60 * 60 * 24 * 7),
                title: "Gerafenac Salbe 30 mg",
                dosageInstructions: "Some medication instruction",
                taskId: "123.4567.891",
                isActive: true,
                entries: IdentifiedArray(
                    uniqueElements: [
                        entryMock3,
                        entryMock1,
                        entryMock2,
                        entryMock4,
                    ]
                )
            )
        }()

        static let medicationScheduleMock2: MedicationSchedule = {
            let date = Date(timeIntervalSinceReferenceDate: 0)

            let entryMock1 = MedicationSchedule.Entry(
                id: UUID(1),
                title: "Entry Title",
                hourComponent: 10,
                minuteComponent: 10,
                dosageForm: "Dosage(s)",
                amount: "1"
            )

            return MedicationSchedule(
                id: UUID(1),
                start: Date(timeIntervalSinceReferenceDate: 0),
                end: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 7),
                title: "Medication Schedule",
                dosageInstructions: "Medication Instruction",
                taskId: "123.4567.890",
                isActive: true,
                entries: IdentifiedArray(
                    uniqueElements: [
                        entryMock1,
                    ]
                )
            )
        }()
    }
}
