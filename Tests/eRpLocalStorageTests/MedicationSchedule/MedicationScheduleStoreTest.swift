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
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import TestUtils
import XCTest

// swiftlint:disable file_length
final class MedicationScheduleStoreTest: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var coreDataFactory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory
            .appendingPathComponent("testDB_MedicationScheduleCoreDataStoreTest.db")
        print("database++", databaseFile.absoluteString)
    }

    override func tearDown() {
        // important to destory the store so that each test starts with an empty database
        if let controller = try? coreDataFactory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = coreDataFactory else {
            #if os(macOS)
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: FileProtectionType(rawValue: "none")
            )

            #else
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: .completeUnlessOpen
            )
            #endif
            coreDataFactory = factory
            return factory
        }
        return factory
    }

    private func loadMedicationScheduleCoreDataStore() -> MedicationScheduleCoreDataStore {
        MedicationScheduleCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: .immediate,
            backgroundQueue: .main
        )
    }

    private func loadErxTaskCoreDataStore(for profileId: UUID? = nil) -> ErxTaskCoreDataStore {
        DefaultErxTaskCoreDataStore(
            profileId: profileId,
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: .immediate,
            backgroundQueue: .main,
            dateProvider: { Date() }
        )
    }

    func testSaveUpdatedMedicationSchedules() throws {
        let taskStore = loadErxTaskCoreDataStore()
        let sut = loadMedicationScheduleCoreDataStore()

        // each Schedule must have a related Task in store
        try taskStore.add(tasks: [ErxTask.Fixtures.task_id_1, ErxTask.Fixtures.task_id_2])

        let task1Schedule = MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1
        let initialSchedules = [
            task1Schedule,
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2,
        ]

        let saveResult = try sut.save(medicationSchedules: initialSchedules)
        expect(saveResult).to(equal(initialSchedules))

        let updatedTask1Schedule = MedicationSchedule(
            start: "2021-06-11T10:55:06+02:00".date!,
            end: "2021-07-10T10:55:06+02:00".date!,
            title: "Test Schedule updated",
            dosageInstructions: "Two times a day",
            taskId: task1Schedule.taskId,
            isActive: true,
            entries: [
                task1Schedule.entries.first!,
                .init(hourComponent: 16, minuteComponent: 50, dosageForm: "Dosis", amount: "2"),
            ]
        )

        let updatedSaveResult = try sut.save(medicationSchedules: [updatedTask1Schedule])
        expect(updatedSaveResult).to(equal([updatedTask1Schedule]))

        let fetchResult = try sut.fetchAll()
        expect(fetchResult).to(equal([
            updatedTask1Schedule,
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2,
        ]))
    }

    func testFetchById() throws {
        let taskStore = loadErxTaskCoreDataStore()
        let sut = loadMedicationScheduleCoreDataStore()

        // each Schedule must have a related Task in store
        try taskStore.add(tasks: [ErxTask.Fixtures.task_id_1, ErxTask.Fixtures.task_id_2])

        let scheduleInStore = [
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1,
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2,
        ]
        let saveResult = try sut.save(medicationSchedules: scheduleInStore)
        expect(saveResult).to(equal(scheduleInStore))

        let resultByTaskId = try sut.fetch(by: "id_2")
        expect(resultByTaskId).to(equal(MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2))
    }

    func testFetchByChildEntryId() throws {
        let taskStore = loadErxTaskCoreDataStore()
        let sut = loadMedicationScheduleCoreDataStore()

        let task = ErxTask(
            identifier: "id_1",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            lastModified: "2021-07-10T10:55:04+02:00",
            medicationSchedule: MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1
        )
        // each Schedule must have a related Task in store
        try taskStore.add(tasks: [task, ErxTask.Fixtures.task_id_2])

        let scheduleInStore = [
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1,
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2,
        ]
        let saveResult = try sut.save(medicationSchedules: scheduleInStore)
        expect(saveResult).to(equal(scheduleInStore))

        let entryId = task.medicationSchedule!.entries.first!.id
        let resultByEntityId = try sut.fetch(byEntryId: entryId, dateProvider: { Date() })

        let expectedResult = MedicationScheduleFetchByEntryIdResponse(
            medicationSchedule: MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1,
            task: task
        )
        expect(resultByEntityId).to(equal(expectedResult))
    }

    func testDeleteMedicationSchedule() throws {
        let taskStore = loadErxTaskCoreDataStore()
        let sut = loadMedicationScheduleCoreDataStore()

        // each Schedule must have a related Task in store
        try taskStore.add(tasks: [ErxTask.Fixtures.task_id_1, ErxTask.Fixtures.task_id_2])

        let expected = [
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1,
            MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2,
        ]

        let saveResult = try sut.save(medicationSchedules: expected)
        expect(saveResult).to(equal(expected))

        let fetchResult = try sut.fetchAll()
        expect(fetchResult).to(equal(expected))

        try sut.delete(medicationSchedules: [MedicationSchedule.Fixtures.medicationScheduleWForTask_id_1])

        let fetchAfterDeleteResult = try sut.fetchAll()
        expect(fetchAfterDeleteResult).to(equal([MedicationSchedule.Fixtures.medicationScheduleWForTask_id_2]))
    }
}
