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

import Combine
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class MedicationReminderOneDaySummaryDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<MedicationReminderOneDaySummaryDomain>

    override func setUp() {
        super.setUp()
    }

    func testOnAppear() async {
        // given
        let sut = TestStore(
            initialState: .init(entries: [UUID]())
        ) {
            MedicationReminderOneDaySummaryDomain()
        } withDependencies: { dependencies in
            dependencies.date = DateGenerator { Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(100) }
        }

        sut.dependencies.medicationScheduleRepository.readAll = {
            [
                Self.Fixtures.medicationScheduleActive,
                Self.Fixtures.medicationScheduleActivePrecedingTitle,
                Self.Fixtures.medicationScheduleInFuture,
                Self.Fixtures.medicationScheduleInactive,
            ]
        }

        // when
        await sut.send(.onAppear)

        // then
        await sut.receive(.schedulesReceived(
            [
                Self.Fixtures.medicationScheduleActive,
                Self.Fixtures.medicationScheduleActivePrecedingTitle,
                Self.Fixtures.medicationScheduleInFuture,
                Self.Fixtures.medicationScheduleInactive,
            ]
        )) { state in
            // schedules to present are filtered (active?) and sorted by title
            state.medicationSchedules = [
                Self.Fixtures.medicationScheduleActivePrecedingTitle,
                Self.Fixtures.medicationScheduleActive,
            ]
        }
    }
}

extension MedicationReminderOneDaySummaryDomainTests {
    enum Fixtures {
        static let medicationScheduleActive = MedicationSchedule(
            start: Date(timeIntervalSinceReferenceDate: 0),
            end: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 7),
            title: "Gerafenac Salbe 30 mg",
            dosageInstructions: "1-0-0-0",
            taskId: "123.4567.891",
            isActive: true,
            entries: IdentifiedArray(
                uniqueElements: [
                    MedicationSchedule.Entry(
                        title: "Entry1 Title",
                        hourComponent: 10,
                        minuteComponent: 5,
                        dosageForm: "Dosage(s)",
                        amount: "2"
                    ),
                ]
            )
        )

        static let medicationScheduleActivePrecedingTitle = MedicationSchedule(
            start: Date(timeIntervalSinceReferenceDate: 0),
            end: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 7),
            title: "Berafenac Salbe 30 mg",
            dosageInstructions: "1-0-0-0",
            taskId: "123.4567.891",
            isActive: true,
            entries: IdentifiedArray(
                uniqueElements: [
                    MedicationSchedule.Entry(
                        title: "Entry1 Title",
                        hourComponent: 10,
                        minuteComponent: 5,
                        dosageForm: "Dosage(s)",
                        amount: "2"
                    ),
                ]
            )
        )

        static let medicationScheduleInFuture = MedicationSchedule(
            start: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 2),
            end: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 7),
            title: "Gerafenac Pille 30 mg",
            dosageInstructions: "0-1-1-0",
            taskId: "123.4567.893",
            isActive: true,
            entries: IdentifiedArray(
                uniqueElements: [
                    MedicationSchedule.Entry(
                        title: "Entry1 Title",
                        hourComponent: 10,
                        minuteComponent: 00,
                        dosageForm: "Dosage(s)",
                        amount: "2"
                    ),
                ]
            )
        )

        static let medicationScheduleInactive = MedicationSchedule(
            start: Date(timeIntervalSinceReferenceDate: 0),
            end: Date(timeIntervalSinceReferenceDate: 0).addingTimeInterval(60 * 60 * 24 * 7),
            title: "Gerafenac Pille 30 mg",
            dosageInstructions: "1-0-0-0",
            taskId: "123.4567.893",
            isActive: false,
            entries: IdentifiedArray(
                uniqueElements: [
                    MedicationSchedule.Entry(
                        title: "Entry1 Title",
                        hourComponent: 10,
                        minuteComponent: 00,
                        dosageForm: "Dosage(s)",
                        amount: "2"
                    ),
                ]
            )
        )
    }
}
