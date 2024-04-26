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

import Dependencies
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

@MainActor
final class MedicationScheduleRepositoryTests: XCTestCase {
    var mockMedicationScheduleStore: MockMedicationScheduleStore!

    override func setUp() {
        super.setUp()

        mockMedicationScheduleStore = MockMedicationScheduleStore()
    }

    func testCreate() async throws {
        // given
        let notificationSchedulerCancelAllPendingRequestsCallsCount = ActorIsolated(0)
        let notificationSchedulerScheduleCallsCount = ActorIsolated(0)
        let notificationSchedulerScheduleInvocation = ActorIsolated([MedicationSchedule]())
        let sut = withDependencies {
            $0.medicationScheduleStore = mockMedicationScheduleStore
            $0.notificationScheduler.cancelAllPendingRequests = {
                await notificationSchedulerCancelAllPendingRequestsCallsCount.withValue { $0 += 1 }
            }
            $0.notificationScheduler.schedule = { schedules in
                await notificationSchedulerScheduleInvocation.setValue(schedules)
                await notificationSchedulerScheduleCallsCount.withValue { $0 += 1 }
            }

        } operation: {
            MedicationScheduleRepository.liveValue
        }

        let schedule1 = Self.Fixtures.medicationScheduleOneEntry
        mockMedicationScheduleStore.saveMedicationSchedulesReturnValue = [schedule1]
        mockMedicationScheduleStore.fetchAllReturnValue = [schedule1]

        // when
        try await sut.create(schedule1)

        // then
        expect(self.mockMedicationScheduleStore.saveMedicationSchedulesCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.saveMedicationSchedulesCallsCount) == 1
        expect(self.mockMedicationScheduleStore.fetchAllCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllCallsCount) == 1

        await notificationSchedulerCancelAllPendingRequestsCallsCount.withValue {
            XCTAssertEqual($0, 1)
        }
        await notificationSchedulerScheduleCallsCount.withValue {
            XCTAssertEqual($0, 1)
        }
        await notificationSchedulerScheduleInvocation.withValue {
            XCTAssertEqual($0, [schedule1])
        }

        // Create (and schedule) a second MedicationSchedule:
        // given
        let schedule2 = Self.Fixtures.medicationScheduleOneEntryEndDistantFuture
        mockMedicationScheduleStore.saveMedicationSchedulesReturnValue = [schedule2]
        mockMedicationScheduleStore.fetchAllReturnValue = [schedule1, schedule2]

        // when
        try await sut.create(schedule2)

        // then
        expect(self.mockMedicationScheduleStore.saveMedicationSchedulesCallsCount) == 2
        expect(self.mockMedicationScheduleStore.fetchAllCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllCallsCount) == 2

        await notificationSchedulerCancelAllPendingRequestsCallsCount.withValue {
            XCTAssertEqual($0, 2)
        }
        await notificationSchedulerScheduleCallsCount.withValue {
            XCTAssertEqual($0, 2)
        }
        await notificationSchedulerScheduleInvocation.withValue {
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
        mockMedicationScheduleStore.fetchAllReturnValue = [schedule]

        // when
        let result = try await sut.readAll()

        // then
        expect(self.mockMedicationScheduleStore.fetchAllCalled).to(beTrue())
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
                isAuthorized: unimplemented("isAuthorized")
            )
        } operation: {
            MedicationScheduleRepository.liveValue
        }

        mockMedicationScheduleStore.fetchAllClosure = {
            actualCallOrder.append("fetchAllClosure")
            return []
        }
        mockMedicationScheduleStore.deleteMedicationSchedulesClosure = { _ in
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
        expect(self.mockMedicationScheduleStore.deleteMedicationSchedulesCalled).to(beTrue())
        expect(self.mockMedicationScheduleStore.fetchAllCalled).to(beTrue())
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
        static let medicationScheduleOneEntry: MedicationSchedule = {
            MedicationSchedule(
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
        }()

        static let medicationScheduleOneEntryEndDistantFuture: MedicationSchedule = {
            MedicationSchedule(
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
        }()

        static let oneHourEarlier = now.addingTimeInterval(-60)
        static let medicationScheduleOneEntryInThePast: MedicationSchedule = {
            MedicationSchedule(
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
        }()

        static let twoHoursLater = now.addingTimeInterval(60 * 2)
        static let medicationScheduleTwoEntries: MedicationSchedule = {
            MedicationSchedule(
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
        }()

        static let medicationScheduleTwoEntriesTwoDays: MedicationSchedule = {
            MedicationSchedule(
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
        }()
    }
}
