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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class MedicationReminderSetupDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<MedicationReminderSetupDomain>

    static let now = Date()
    let calendar = Calendar.autoupdatingCurrent

    override func setUp() {
        super.setUp()
    }

    func testStore(
        with state: MedicationReminderSetupDomain.State = {
            MedicationReminderSetupDomain.State(
                medicationSchedule: MedicationReminderSetupDomainTests.Fixtures.medicationScheduleZeroEntries,
                destination: nil
            )
        }()
    ) -> TestStore {
        TestStore(
            initialState: state
        ) {
            MedicationReminderSetupDomain()
        } withDependencies: { dependencies in
            dependencies.uuid = UUIDGenerator.incrementing
            dependencies.date = DateGenerator.constant(Self.now)
            dependencies.calendar = calendar
            dependencies.medicationScheduleRepository = .init(
                create: { _ in },
                readAll: { [] },
                read: { _ in nil },
                delete: { _ in }
            )
            dependencies.notificationScheduler = .init(
                schedule: { _ in },
                cancelAllPendingRequests: {},
                removeDeliveredNotification: { _ in },
                requestAuthorization: { _ in true },
                isAuthorized: { true }
            )
        }
    }

    func testAddButtonTapped() async {
        // given
        let sut = testStore()

        let expectedNewEntry = MedicationSchedule.Entry(
            id: UUID(0),
            title: "1",
            hourComponent: calendar.component(.hour, from: Self.now),
            minuteComponent: calendar.component(.minute, from: Self.now),
            dosageForm: "Dosis",
            amount: "1"
        )

        // then
        await sut.send(.addButtonPressed) { state in
            state.medicationSchedule.entries = [expectedNewEntry]
        }

        var schedule = sut.state.medicationSchedule
        // when setting the time of the first entry to 12:00
        var expectedNewEntry1200 = expectedNewEntry
        expectedNewEntry1200.hourComponent = 12
        expectedNewEntry1200.minuteComponent = 00
        schedule.entries = [expectedNewEntry1200]

        await sut.send(.set(\.$medicationSchedule, schedule)) { state in
            // then the time is updated
            state.medicationSchedule.entries = [expectedNewEntry1200]
        }

        // when tapping the add button again
        var expectedSecondEntry = expectedNewEntry1200
        expectedSecondEntry.id = UUID(1)

        await sut.send(.addButtonPressed) { state in
            // then time and amount are carried over from the last entry expectedNewEntry1200
            state.medicationSchedule.entries = [expectedNewEntry1200, expectedSecondEntry]
        }
    }

    func testSaveButtonTapped() async {
        let sut = testStore()

        await sut.send(.save)
        await sut.receive(.delegate(.saveButtonTapped(
            Self.Fixtures.medicationScheduleZeroEntries
        )))
        await sut.finish()
    }

    func testRepetitionTypeChanged() async {
        let sut = testStore()

        await sut.send(.repetitionTypeChanged(.infinite)) { state in
            state.medicationSchedule.end = Date.distantFuture
        }

        await sut.send(.repetitionTypeChanged(.finite)) { state in
            state.medicationSchedule.end = MedicationReminderSetupDomainTests.now
        }
    }

    func testBindingEndDateBeforeStartDate() async {
        let sut = testStore()
        var medicationScheduleWithFutureStartDate = Fixtures.medicationScheduleZeroEntries
        medicationScheduleWithFutureStartDate.start = Self.now.addingTimeInterval(60 * 60 * 24 * 7 * 3)

        await sut.send(.binding(.set(\.$medicationSchedule, medicationScheduleWithFutureStartDate))) { state in
            state.medicationSchedule.start = medicationScheduleWithFutureStartDate.start
            state.medicationSchedule.end = medicationScheduleWithFutureStartDate.start
        }
        await sut.finish()
    }
}

extension MedicationReminderSetupDomainTests {
    enum Fixtures {
        static let medicationScheduleZeroEntries = MedicationSchedule(
            id: UUID(),
            start: MedicationReminderSetupDomainTests.now,
            end: MedicationReminderSetupDomainTests.now.addingTimeInterval(60 * 60 * 24 * 7),
            title: "",
            dosageInstructions: "",
            taskId: "123.4567.8901",
            isActive: true,
            entries: []
        )
    }
}
