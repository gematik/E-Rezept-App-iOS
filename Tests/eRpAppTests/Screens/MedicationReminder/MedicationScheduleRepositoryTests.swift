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

import Dependencies
@testable import eRpFeatures
import eRpKit
import ErxTaskRepository
import Nimble
import XCTest

@MainActor
final class MedicationScheduleRepositoryTests: XCTestCase {
    var mockMedicationScheduleStore: MedicationScheduleStoreMock!

    override func setUp() {
        super.setUp()

        mockMedicationScheduleStore = MedicationScheduleStoreMock()
    }

    func testCreate() async throws {
        // given
        let notificationSchedulerCancelAllPendingRequestsCallsCount = LockIsolated(0)
        let notificationSchedulerScheduleCallsCount = LockIsolated(0)
        let notificationSchedulerScheduleInvocation = LockIsolated([MedicationSchedule]())
        let sut = withDependencies {
            $0.medicationScheduleStore = mockMedicationScheduleStore
            $0.notificationScheduler.cancelAllPendingRequests = {
                notificationSchedulerCancelAllPendingRequestsCallsCount.withValue { $0 += 1 }
            }
            $0.notificationScheduler.schedule = { schedules in
                notificationSchedulerScheduleInvocation.setValue(schedules)
                notificationSchedulerScheduleCallsCount.withValue { $0 += 1 }
            }

        } operation: {
            MedicationScheduleRepository.liveValue
        }

        let schedule1 = Self.Fixtures.medicationScheduleOneEntry
        mockMedicationScheduleStore.saveMedicationSchedulesMedicationScheduleMedicationScheduleReturnValue = [schedule1]
        mockMedicationScheduleStore.fetchAllMedicationScheduleReturnValue = [schedule1]

        // when
        try await sut.create(schedule1)

        // then
        expect(self.mockMedicationScheduleStore.saveMedicationSchedulesMedicationScheduleMedicationScheduleCalled)
            .to(beTrue())
        expect(
            self.mockMedicationScheduleStore.saveMedicationSchedulesMedicationScheduleMedicationScheduleCallsCount
        ) ==
            1
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCallsCount) == 1

        notificationSchedulerCancelAllPendingRequestsCallsCount.withValue {
            XCTAssertEqual($0, 1)
        }
        notificationSchedulerScheduleCallsCount.withValue {
            XCTAssertEqual($0, 1)
        }
        notificationSchedulerScheduleInvocation.withValue {
            XCTAssertEqual($0, [schedule1])
        }

        // Create (and schedule) a second MedicationSchedule:
        // given
        let schedule2 = Self.Fixtures.medicationScheduleOneEntryEndDistantFuture
        mockMedicationScheduleStore.saveMedicationSchedulesMedicationScheduleMedicationScheduleReturnValue = [schedule2]
        mockMedicationScheduleStore.fetchAllMedicationScheduleReturnValue = [schedule1, schedule2]

        // when
        try await sut.create(schedule2)

        // then
        expect(
            self.mockMedicationScheduleStore.saveMedicationSchedulesMedicationScheduleMedicationScheduleCallsCount
        ) ==
            2
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCallsCount) == 2

        notificationSchedulerCancelAllPendingRequestsCallsCount.withValue {
            XCTAssertEqual($0, 2)
        }
        notificationSchedulerScheduleCallsCount.withValue {
            XCTAssertEqual($0, 2)
        }
        notificationSchedulerScheduleInvocation.withValue {
            XCTAssertEqual($0, [schedule1, schedule2])
        }
    }

    func testReadAll() async throws {
        // given
        let sut = withDependencies {
            $0.medicationScheduleStore = mockMedicationScheduleStore
        } operation: {
            MedicationScheduleRepository.liveValue
        }

        let schedule = Self.Fixtures.medicationScheduleOneEntry
        mockMedicationScheduleStore.fetchAllMedicationScheduleReturnValue = [schedule]

        // when
        let result = try await sut.readAll()

        // then
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCalled).to(beTrue())
        expect(result) == [schedule]
    }

    func testDelete() async throws {
        let actor = TestActor()
        var actualCallOrder: [String] = []

        // given
        let sut = withDependencies {
            $0.medicationScheduleStore = mockMedicationScheduleStore
            $0.notificationScheduler = .init(
                schedule: { _ in await actor.didCallAPI(name: "schedule") },
                cancelAllPendingRequests: { await actor.didCallAPI(name: "cancelAllPendingRequests") },
                removeDeliveredNotification: unimplemented("removeDeliveredNotification"),
                requestAuthorization: unimplemented("requestAuthorization"),
                isAuthorized: unimplemented("isAuthorized", placeholder: false)
            )
        } operation: {
            MedicationScheduleRepository.liveValue
        }

        mockMedicationScheduleStore.fetchAllMedicationScheduleClosure = {
            actualCallOrder.append("fetchAllClosure")
            return []
        }
        mockMedicationScheduleStore.deleteMedicationSchedulesMedicationScheduleVoidClosure = { _ in
            actualCallOrder.append("deleteMedicationSchedulesClosure")
        }
        let schedule = Self.Fixtures.medicationScheduleOneEntry

        let expectedAsyncCallOrder = [
            "cancelAllPendingRequests",
            "schedule",
        ]

        let expectedSyncCallOrder = [
            "deleteMedicationSchedulesClosure",
            "fetchAllClosure",
        ]

        // when
        try await sut.delete([schedule])

        // then
        expect(self.mockMedicationScheduleStore.deleteMedicationSchedulesMedicationScheduleVoidCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllMedicationScheduleCalled).to(beTrue())
        let actualAsyncCallOrder = await actor.calledAPIOrder()
        expect(expectedAsyncCallOrder).to(equal(actualAsyncCallOrder))
        expect(expectedSyncCallOrder).to(equal(actualCallOrder))
    }

    actor TestActor {
        private var calledAPIs: [String] = []

        func didCallAPI(name: String) {
            calledAPIs.append(name)
        }

        func calledAPIOrder() -> [String] {
            calledAPIs
        }
    }
}

extension MedicationScheduleRepositoryTests {
    enum Fixtures {
        static let now = Date.now
        static let calendar = Calendar.current
        static let oneHourLater = now.addingTimeInterval(60)
        static let medicationScheduleOneEntry: MedicationSchedule = .init(
            id: UUID(),
            start: now,
            end: now,
            title: "",
            dosageInstructions: "",
            taskId: "taskId1",
            isActive: true,
            entries: [
                .init(
                    id: UUID(),
                    title: "oneEntryFirstEntry",
                    hourComponent: calendar.component(.hour, from: oneHourLater),
                    minuteComponent: calendar.component(.minute, from: oneHourLater),
                    dosageForm: "pill",
                    amount: "1"
                ),
            ]
        )

        static let medicationScheduleOneEntryEndDistantFuture: MedicationSchedule = .init(
            id: UUID(),
            start: now,
            end: Date.distantFuture,
            title: "",
            dosageInstructions: "",
            taskId: "taskId1",
            isActive: true,
            entries: [
                .init(
                    id: UUID(),
                    title: "oneEntryFirstEntry",
                    hourComponent: calendar.component(.hour, from: oneHourLater),
                    minuteComponent: calendar.component(.minute, from: oneHourLater),
                    dosageForm: "pill",
                    amount: "1"
                ),
            ]
        )

        static let oneHourEarlier = now.addingTimeInterval(-60)
        static let medicationScheduleOneEntryInThePast: MedicationSchedule = .init(
            id: UUID(),
            start: now,
            end: now,
            title: "",
            dosageInstructions: "",
            taskId: "taskId1",
            isActive: true,
            entries: [
                .init(
                    id: UUID(),
                    title: "oneEntryFirstEntry",
                    hourComponent: calendar.component(.hour, from: oneHourEarlier),
                    minuteComponent: calendar.component(.minute, from: oneHourEarlier),
                    dosageForm: "pill",
                    amount: "1"
                ),
            ]
        )

        static let twoHoursLater = now.addingTimeInterval(60 * 2)
        static let medicationScheduleTwoEntries: MedicationSchedule = .init(
            id: UUID(),
            start: now,
            end: now,
            title: "",
            dosageInstructions: "",
            taskId: "taskId2",
            isActive: true,
            entries: [
                .init(
                    id: UUID(),
                    title: "twoEntriesFirstEntry",
                    hourComponent: Calendar.current.component(.hour, from: oneHourLater),
                    minuteComponent: Calendar.current.component(.minute, from: oneHourLater),
                    dosageForm: "pill",
                    amount: "1"
                ),
                .init(
                    id: UUID(),
                    title: "twoEntriesSecondEntry",
                    hourComponent: Calendar.current.component(.hour, from: twoHoursLater),
                    minuteComponent: Calendar.current.component(.minute, from: twoHoursLater),
                    dosageForm: "pill",
                    amount: "2"
                ),
            ]
        )

        static let medicationScheduleTwoEntriesTwoDays: MedicationSchedule = .init(
            id: UUID(),
            start: now,
            end: now.advanced(by: 60 * 60 * 24),
            title: "",
            dosageInstructions: "",
            taskId: "taskId2",
            isActive: true,
            entries: [
                .init(
                    id: UUID(),
                    title: "twoEntriesFirstEntry",
                    hourComponent: Calendar.current.component(.hour, from: oneHourLater),
                    minuteComponent: Calendar.current.component(.minute, from: now),
                    dosageForm: "pill",
                    amount: "1"
                ),
                .init(
                    id: UUID(),
                    title: "twoEntriesSecondEntry",
                    hourComponent: Calendar.current.component(.hour, from: twoHoursLater),
                    minuteComponent: Calendar.current.component(.minute, from: now),
                    dosageForm: "pill",
                    amount: "2"
                ),
            ]
        )
    }
}
