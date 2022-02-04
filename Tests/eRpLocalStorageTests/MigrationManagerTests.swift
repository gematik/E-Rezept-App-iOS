// swiftlint:disable file_length
//
//  Copyright (c) 2022 gematik GmbH
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
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class MigrationManagerTests: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var coreDataController: CoreDataController?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("database/\(UUID().uuidString)")
    }

    override func tearDown() {
        let folderUrl = databaseFile.deletingLastPathComponent()
        expect(try self.fileManager.removeItem(at: folderUrl)).toNot(throwError())

        super.tearDown()
    }

    func loadCoreDataController() throws -> CoreDataController {
        guard let controller = coreDataController else {
            #if os(macOS)
            let controller = try CoreDataController(
                url: databaseFile,
                fileProtection: FileProtectionType(rawValue: "none")
            )
            #else
            let controller = try CoreDataController(
                url: databaseFile,
                fileProtection: .completeUnlessOpen
            )
            #endif
            coreDataController = controller
            return controller
        }

        return controller
    }

    lazy var tasksForPatientAnna: [ErxTask] = {
        [
            ErxTask.Dummies.erxTask(
                id: "100.200.300.400.500",
                authoredOn: "2021-03-10T10:55:04+02:00",
                practitioner: ErxTask.Dummies.demoPractitionerStorchhausen,
                patient: ErxTask.Dummies.demoPatientAnna,
                organisation: ErxTask.Dummies.demoOrganizationStorchhausen
            ),
            ErxTask.Dummies.erxTask(
                id: "100.200.300.400.501",
                authoredOn: "2021-03-11T10:55:04+02:00",
                practitioner: ErxTask.Dummies.demoPractitionerTodgluecklich,
                patient: ErxTask.Dummies.demoPatientAnna,
                organisation: ErxTask.Dummies.demoOrganizationTodgluecklich
            ),
        ]
    }()

    lazy var tasksForPatientLudger: [ErxTask] = {
        [
            ErxTask.Dummies.erxTask(
                id: "200.300.400.500.600",
                authoredOn: "2021-03-12T10:55:04+02:00",
                practitioner: ErxTask.Dummies.demoPractitionerTodgluecklich,
                patient: ErxTask.Dummies.demoPatientLudger,
                organisation: ErxTask.Dummies.demoOrganizationTodgluecklich
            ),
            ErxTask.Dummies.erxTask(
                id: "200.300.400.500.601",
                authoredOn: "2021-03-13T10:55:04+02:00",
                practitioner: ErxTask.Dummies.demoPractitionerTodgluecklich,
                patient: ErxTask.Dummies.demoPatientLudger,
                organisation: ErxTask.Dummies.demoOrganizationTodgluecklich
            ),
        ]
    }()

    lazy var scannedTask: ErxTask = {
        ErxTask.Dummies.scannedTask(
            id: "123.456.789.111",
            authoredOn: "2021-03-15T10:55:04+02:00",
            accessCode: "asdfasref1241z344hjegdba8a23827349bi"
        )
    }()

    func testModel4MigrationWithTwoDifferentPatientTasksAndScannedTasks() throws {
        let userDataStore = MockUserDataStore()
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerValue = try loadCoreDataController()
        let sut = MigrationManager(
            factory: factory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(profileId: nil,
                                                       coreDataControllerFactory: factory,
                                                       backgroundQueue: AnyScheduler.immediate),
            userDataStore: userDataStore
        )
        // pre fill database with tasks from two different patients and a scanned task
        let erxTaskStore = ErxTaskCoreDataStore(profileId: nil, coreDataControllerFactory: factory)
        var tasks = tasksForPatientAnna + tasksForPatientLudger
        tasks.append(scannedTask)
        try erxTaskStore.add(tasks: tasks)
        let communications = tasks.flatMap(\.communications)
        try erxTaskStore.add(communications: communications)
        let auditEvents = tasks.flatMap(\.auditEvents)
        try erxTaskStore.add(auditEvents: auditEvents)

        var receivedCompletions = [Subscribers.Completion<MigrationError>]()
        var receivedResults = [ModelVersion]()
        let cancellable =
            sut.startModelMigration(from: ModelVersion.taskStatus)
                .sink(receiveCompletion: { completion in
                    receivedCompletions.append(completion)
                }, receiveValue: { modelVersion in
                    receivedResults.append(modelVersion)
                })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.first) == .profiles

        let profileStore = ProfileCoreDataStore(coreDataControllerFactory: factory)

        var receivedProfileCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedProfileResults = [[Profile]]()
        _ = profileStore.listAllProfiles()
            .first()
            .sink(receiveCompletion: { completion in
                receivedProfileCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedProfileResults.append(profiles)
            })

        expect(receivedProfileResults.count).toEventually(equal(1))
        expect(receivedProfileResults.first?.count).toEventually(equal(2))

        guard let firstProfile = receivedProfileResults.first?.first else {
            fail("expected to receive this profile")
            return
        }
        expect(firstProfile.erxTasks.count) == 3
        expect(firstProfile.erxTasks).to(contain(scannedTask))
        if firstProfile.name == "Anna Vetter" {
            expect(firstProfile.name) == "Anna Vetter"
            expect(firstProfile.insuranceId).to(beNil())
            expect(firstProfile.erxTasks).to(contain(tasksForPatientAnna[0].modifyAsExpected()))
            expect(firstProfile.erxTasks).to(contain(tasksForPatientAnna[1].modifyAsExpected()))
        } else {
            expect(firstProfile.name) == "Ludger Königsstein"
            expect(firstProfile.insuranceId).to(beNil())
            expect(firstProfile.erxTasks).to(contain(tasksForPatientLudger[0].modifyAsExpected()))
            expect(firstProfile.erxTasks).to(contain(tasksForPatientLudger[1].modifyAsExpected()))
        }

        guard let secondProfile = receivedProfileResults.first?.last else {
            fail("expected to receive this profile")
            return
        }

        expect(secondProfile.erxTasks.count) == 2
        if secondProfile.name == "Ludger Königsstein" {
            expect(secondProfile.name) == "Ludger Königsstein"
            expect(secondProfile.insuranceId).to(beNil())
            expect(secondProfile.erxTasks).to(contain(tasksForPatientLudger[0].modifyAsExpected()))
            expect(secondProfile.erxTasks).to(contain(tasksForPatientLudger[1].modifyAsExpected()))
        } else {
            expect(secondProfile.name) == "Anna Vetter"
            expect(secondProfile.insuranceId).to(beNil())
            expect(secondProfile.erxTasks).to(contain(tasksForPatientAnna[0].modifyAsExpected()))
            expect(secondProfile.erxTasks).to(contain(tasksForPatientAnna[1].modifyAsExpected()))
        }

        expect(receivedProfileCompletions.count).toEventually(equal(1))
        expect(receivedProfileCompletions.first) == .finished

        cancellable.cancel()
    }

    func testModel4MigrationWithoutExistingTasks() throws {
        let userDataStore = MockUserDataStore()
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerValue = try loadCoreDataController()
        let sut = MigrationManager(
            factory: factory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(profileId: nil, coreDataControllerFactory: factory),
            userDataStore: userDataStore
        )

        var receivedCompletions = [Subscribers.Completion<MigrationError>]()
        var receivedResults = [ModelVersion]()
        let cancellable =
            sut.startModelMigration(from: .taskStatus)
                .sink(receiveCompletion: { completion in
                    receivedCompletions.append(completion)
                }, receiveValue: { modelVersion in
                    receivedResults.append(modelVersion)
                })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.first) == .profiles

        let profileStore = ProfileCoreDataStore(coreDataControllerFactory: factory)

        var receivedProfileCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedProfileResults = [[Profile]]()
        _ = profileStore.listAllProfiles()
            .first()
            .sink(receiveCompletion: { completion in
                receivedProfileCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedProfileResults.append(profiles)
            })

        expect(receivedProfileResults.count).toEventually(equal(1))
        expect(receivedProfileResults.first?.count).toEventually(equal(1))

        guard let defaultProfile = receivedProfileResults.first?[0] else {
            fail("expected to receive this profile")
            return
        }
        expect(defaultProfile.name) == "mgm_fallback_profile_name"
        expect(defaultProfile.insuranceId).to(beNil())
        expect(defaultProfile.erxTasks) == []

        expect(receivedProfileCompletions.count).toEventually(equal(1))
        expect(receivedProfileCompletions.first) == .finished

        cancellable.cancel()
    }

    func testModel4MigrationWithOnlyScannedTasks() throws {
        let userDataStore = MockUserDataStore()
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerValue = try loadCoreDataController()
        let sut = MigrationManager(
            factory: factory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(profileId: nil, coreDataControllerFactory: factory),
            userDataStore: userDataStore
        )

        // pre fill database with tasks from two different patients and a scanned task
        let erxTaskStore = ErxTaskCoreDataStore(profileId: nil, coreDataControllerFactory: factory)
        try erxTaskStore.add(tasks: [scannedTask])

        var receivedCompletions = [Subscribers.Completion<MigrationError>]()
        var receivedResults = [ModelVersion]()
        let cancellable =
            sut.startModelMigration(from: ModelVersion.taskStatus)
                .sink(receiveCompletion: { completion in
                    receivedCompletions.append(completion)
                }, receiveValue: { modelVersion in
                    receivedResults.append(modelVersion)
                })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.first) == .profiles

        let profileStore = ProfileCoreDataStore(coreDataControllerFactory: factory)

        var receivedProfileCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedProfileResults = [[Profile]]()
        _ = profileStore.listAllProfiles()
            .first()
            .sink(receiveCompletion: { completion in
                receivedProfileCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedProfileResults.append(profiles)
            })

        expect(receivedProfileResults.count).toEventually(equal(1))
        expect(receivedProfileResults.first?.count).toEventually(equal(1))

        guard let defaultProfile = receivedProfileResults.first?[0] else {
            fail("expected to receive this profile")
            return
        }
        expect(defaultProfile.name) == "mgm_fallback_profile_name"
        expect(defaultProfile.insuranceId).to(beNil())
        expect(defaultProfile.erxTasks) == [scannedTask]

        expect(receivedProfileCompletions.count).toEventually(equal(1))
        expect(receivedProfileCompletions.first) == .finished

        cancellable.cancel()
    }

    func testMigrationFromVersion4ToVersion5WithoutAuditEvents() throws {
        let userDataStore = MockUserDataStore()
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerValue = try loadCoreDataController()
        let sut = MigrationManager(
            factory: factory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(profileId: nil,
                                                       coreDataControllerFactory: factory,
                                                       backgroundQueue: AnyScheduler.immediate),
            userDataStore: userDataStore
        )

        var receivedCompletions = [Subscribers.Completion<MigrationError>]()
        var receivedResults = [ModelVersion]()
        let cancellable =
            sut.startModelMigration(from: ModelVersion.profiles)
                .sink(receiveCompletion: { completion in
                    receivedCompletions.append(completion)
                }, receiveValue: { modelVersion in
                    receivedResults.append(modelVersion)
                })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.first) == .auditEventsInProfile

        cancellable.cancel()
    }

    func testMigrationFromVersion4ToVersion5WithAuditEvents() throws {
        let userDataStore = MockUserDataStore()
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerValue = try loadCoreDataController()
        let erxTaskStore = ErxTaskCoreDataStore(profileId: UUID(),
                                                coreDataControllerFactory: factory,
                                                backgroundQueue: AnyScheduler.immediate)
        let sut = MigrationManager(
            factory: factory,
            erxTaskCoreDataStore: erxTaskStore,
            userDataStore: userDataStore
        )
        // pre fill database with tasks and auditEvents
        let tasks = tasksForPatientAnna + tasksForPatientLudger
        let auditEvents = tasks.flatMap(\.auditEvents)
        try erxTaskStore.add(auditEvents: auditEvents)

        var receivedCompletions = [Subscribers.Completion<MigrationError>]()
        var receivedResults = [ModelVersion]()
        let cancellable =
            sut.startModelMigration(from: ModelVersion.profiles)
                .sink(receiveCompletion: { completion in
                    receivedCompletions.append(completion)
                }, receiveValue: { modelVersion in
                    receivedResults.append(modelVersion)
                })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.first) == .auditEventsInProfile

        // verify that audit events have been deleted
        var receivedAuditEventCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedAuditEventsResults = [ErxAuditEvent]()
        _ = erxTaskStore.listAllAuditEvents(for: nil)
            .first()
            .sink(receiveCompletion: { completion in
                receivedAuditEventCompletions.append(completion)
            }, receiveValue: { auditEvents in
                receivedAuditEventsResults = auditEvents
            })
        expect(receivedAuditEventsResults.count).toEventually(equal(0))

        cancellable.cancel()
    }
}

extension ErxTask {
    // Removes AuditEvents and  lastModified of ErxTask and sets insuranceId of Patient to nil
    func modifyAsExpected() -> ErxTask {
        let patient = ErxTask.Patient(
            name: patient?.name,
            address: patient?.address,
            birthDate: patient?.birthDate,
            phone: patient?.phone,
            status: patient?.status,
            insurance: patient?.insurance,
            insuranceId: nil
        )

        return ErxTask(
            identifier: id,
            status: status,
            accessCode: accessCode,
            fullUrl: fullUrl,
            authoredOn: authoredOn,
            lastModified: nil,
            expiresOn: expiresOn,
            acceptedUntil: acceptedUntil,
            redeemedOn: redeemedOn,
            author: author,
            dispenseValidityEnd: dispenseValidityEnd,
            noctuFeeWaiver: noctuFeeWaiver,
            prescriptionId: prescriptionId,
            substitutionAllowed: substitutionAllowed,
            source: source,
            medication: medication,
            patient: patient,
            practitioner: practitioner,
            organization: organization,
            workRelatedAccident: workRelatedAccident,
            auditEvents: [],
            communications: communications,
            medicationDispense: medicationDispense
        )
    }
}
