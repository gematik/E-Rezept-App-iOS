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
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class ProfileCoreDataStoreTests: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var factory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: databaseFile.absoluteString) {
            expect(try self.fileManager.removeItem(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = factory else {
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
            self.factory = factory
            return factory
        }

        return factory
    }

    private func loadProfileCoreDataStore(for _: UUID? = nil) -> ProfileCoreDataStore {
        ProfileCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: DispatchQueue.main
        )
    }

    private func loadErxCoreDataStore(for profileId: UUID? = nil) throws -> ErxTaskCoreDataStore {
        ErxTaskCoreDataStore(
            profileId: profileId,
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: DispatchQueue.main
        )
    }

    private lazy var profileSimple: Profile = {
        Profile(
            name: "Karl",
            identifier: UUID(),
            color: .grey,
            emoji: "🤖"
        )
    }()

    private lazy var profileAuthenticated: Profile = {
        Profile(
            name: "Karl",
            identifier: UUID(),
            insuranceId: "k1234",
            color: .grey,
            lastAuthenticated: Date()
        )
    }()

    private lazy var profileWithTasksAndAuditEvents: Profile = {
        Profile(
            name: "Karl",
            identifier: UUID(),
            insuranceId: "k1234",
            color: .grey,
            emoji: "🤖",
            lastAuthenticated: Date(),
            erxTasks: [ErxTask(identifier: "id1", status: .ready, accessCode: "accessCode1"),
                       ErxTask(identifier: "id2", status: .ready, accessCode: "accessCode2")],
            erxAuditEvents: [ErxAuditEvent(identifier: "id1", text: "message")]
        )
    }()

    func testSavingProfile() throws {
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileSimple, profileWithTasksAndAuditEvents])
    }

    func testSavingProfileWillNotStoreTasksAndAuditEvents() throws {
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileSimple, profileWithTasksAndAuditEvents])

        // verify result
        var receivedListAllProfileValues = [[Profile]]()
        var receivedCompletions = [Subscribers.Completion<ProfileCoreDataStore.Error>]()
        let cancellable = store.listAllProfiles()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        expect(receivedCompletions.count) == 0
        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        // than two profiles should be received (without saving erxtTasks and erxAuditEvents)
        expect(receivedListAllProfileValues[0].count) == 2
        let receivedProfiles = receivedListAllProfileValues[0]
        expect(receivedProfiles).to(contain(profileSimple))
        let expectedResult = Profile(name: profileWithTasksAndAuditEvents.name,
                                     identifier: profileWithTasksAndAuditEvents.identifier,
                                     created: profileWithTasksAndAuditEvents.created,
                                     insuranceId: profileWithTasksAndAuditEvents.insuranceId,
                                     color: profileWithTasksAndAuditEvents.color,
                                     emoji: profileWithTasksAndAuditEvents.emoji,
                                     lastAuthenticated: profileWithTasksAndAuditEvents.lastAuthenticated,
                                     erxTasks: [],
                                     erxAuditEvents: [])
        expect(receivedProfiles).to(contain(expectedResult))

        cancellable.cancel()
    }

    func testSaveProfilesWithFailingLoadingDatabase() throws {
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerError = CoreDataStoreError.notImplemented
        let store = ProfileCoreDataStore(
            coreDataControllerFactory: factory,
            backgroundQueue: DispatchQueue.main
        )

        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        var receivedSaveResults = [Bool]()

        let cancellable = store.save(profiles: [profileSimple])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                fail("did not expect to receive a value")
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(0))
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) ==
            .failure(CoreDataStoreError.initialization(error: factory.loadCoreDataControllerError!))

        cancellable.cancel()
    }

    func testListAllProfiles() throws {
        let store = loadProfileCoreDataStore()
        // given two saved profiles in store
        let heinz = Profile(name: "Heinz",
                            insuranceId: "1234",
                            emoji: "🤖",
                            lastAuthenticated: Date())
        let dieter = Profile(name: "Dieter", lastAuthenticated: Date().addingTimeInterval(1000))
        try store.add(profiles: [heinz, dieter])

        var receivedListAllProfileValues = [[Profile]]()
        var receivedCompletions = [Subscribers.Completion<ProfileCoreDataStore.Error>]()

        // when
        let cancellable = store.listAllProfiles()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        expect(receivedCompletions.count) == 0
        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        // than two profiles should be received
        expect(receivedListAllProfileValues[0].count) == 2
        let receivedProfiles = receivedListAllProfileValues[0]
        expect(receivedProfiles[0]) == dieter
        expect(receivedProfiles[1]) == heinz

        cancellable.cancel()
    }

    func testUpdatingProfile() throws {
        let store = loadProfileCoreDataStore()
        // given
        try store.add(profiles: [profileSimple])

        let updatedProfile = Profile(
            name: "New Karl",
            identifier: profileSimple.identifier,
            insuranceId: "k1234",
            color: .red,
            lastAuthenticated: Date(),
            erxTasks: [ErxTask(identifier: "id", status: .ready, accessCode: "access")]
        )
        // when updating the saved profile
        try store.add(profiles: [updatedProfile])

        var receivedListAllProfileValues = [[Profile]]()
        let cancellable = store.listAllProfiles()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        // than there should be only one in store with the updated values
        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        expect(receivedListAllProfileValues[0].count) == 1
        let result = receivedListAllProfileValues[0].first
        expect(result?.identifier) == updatedProfile.identifier
        expect(result?.color) == updatedProfile.color
        expect(result?.name) == updatedProfile.name
        expect(result?.insuranceId) == updatedProfile.insuranceId
        expect(result?.lastAuthenticated) == updatedProfile.lastAuthenticated
        expect(result?.erxTasks) == [] // erxTasks should not be saved

        cancellable.cancel()
    }

    func testDeleteProfileWithTasksAndAuditEvents() throws {
        // given when we store a profile and related tasks and audit events
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileWithTasksAndAuditEvents])
        let erxTaskStore = try loadErxCoreDataStore(for: profileWithTasksAndAuditEvents.identifier)
        // task and audit events have to be stored separately
        try erxTaskStore.add(tasks: profileWithTasksAndAuditEvents.erxTasks)
        try erxTaskStore.add(auditEvents: profileWithTasksAndAuditEvents.erxAuditEvents)

        // when deleting the profile
        var receivedDeleteResults = [Bool]()
        var receivedDeleteCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        _ = store.delete(profiles: [profileWithTasksAndAuditEvents])
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { result in
                receivedDeleteResults.append(result)
            })
        expect(receivedDeleteResults.count).toEventually(equal(1))
        expect(receivedDeleteResults.first).to(beTrue())
        expect(receivedDeleteCompletions.count).toEventually(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // than
        var receivedListAllProfileValues = [[Profile]]()
        _ = store.listAllProfiles()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        // there should be no profile left in store
        expect(receivedListAllProfileValues.first?.count) == 0

        var receivedListAllErxTasksValues = [[ErxTask]]()
        _ = erxTaskStore.listAllTasks()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { erxTasks in
                receivedListAllErxTasksValues.append(erxTasks)
            })

        expect(receivedListAllErxTasksValues.count).toEventually(equal(1))
        // and no erxTasks
        expect(receivedListAllErxTasksValues.first?.count) == 0

        var receivedListAllAuditEventsValues = [[ErxAuditEvent]]()
        _ = erxTaskStore.listAllAuditEvents(for: nil)
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { erxAuditEvents in
                receivedListAllAuditEventsValues.append(erxAuditEvents)
            })

        expect(receivedListAllAuditEventsValues.count).toEventually(equal(1))
        // and no erxAuditEvents
        expect(receivedListAllAuditEventsValues.first?.count) == 0
    }

    func testFetchProfileByIdSuccess() throws {
        let store = loadProfileCoreDataStore()
        // given
        let profileToFetch = Profile(name: "Fetchme")
        try store.add(profiles: [profileToFetch])

        // when we fetch that profile
        var receivedFetchResult: Profile?
        let cancellable = store.fetchProfile(by: profileToFetch.identifier)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // than it should be the one we expect
        expect(receivedFetchResult).toEventually(equal(profileToFetch))

        cancellable.cancel()
    }

    func testFetchProfileByIdNoResults() throws {
        let store = loadProfileCoreDataStore()
        let profileToFetch = Profile(name: "profileToFetch")

        var receivedNoResult = false
        // when fetching a profile that has not been added to the store
        let cancellable = store.fetchProfile(by: profileToFetch.identifier)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // than it should return none
        expect(receivedNoResult).toEventually(beTrue())

        cancellable.cancel()
    }

    func testFetchingProfilesWithTasksAndAuditEvents() throws {
        // given
        let profileStore = loadProfileCoreDataStore()
        try profileStore.add(profiles: [profileWithTasksAndAuditEvents])
        let erxTaskStore = try loadErxCoreDataStore(for: profileWithTasksAndAuditEvents.identifier)
        // task and audit events have to be stored separately
        try erxTaskStore.add(tasks: profileWithTasksAndAuditEvents.erxTasks)
        try erxTaskStore.add(auditEvents: profileWithTasksAndAuditEvents.erxAuditEvents)

        // when fetching ...
        var receivedListAllProfileValues = [[Profile]]()
        var receivedCompletions = [Subscribers.Completion<ProfileCoreDataStore.Error>]()
        let cancellable = profileStore.listAllProfiles()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        expect(receivedCompletions.count) == 0
        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        // than the stored profile with tasks and auditEvents should be returned
        expect(receivedListAllProfileValues.first?.count) == 1
        guard let profile = receivedListAllProfileValues.first?.first else {
            fail("expected to receive a profile")
            return
        }
        expect(profile.name) == profileWithTasksAndAuditEvents.name
        expect(profile.identifier) == profileWithTasksAndAuditEvents.identifier
        expect(profile.erxTasks).to(contain(profileWithTasksAndAuditEvents.erxTasks))
        expect(profile.erxAuditEvents).to(contain(profileWithTasksAndAuditEvents.erxAuditEvents))

        cancellable.cancel()
    }
}

extension ProfileCoreDataStore {
    func add(profiles: [Profile]) throws {
        var receivedSaveCompletions = [Subscribers.Completion<ProfileCoreDataStore.Error>]()
        var receivedSaveResults = [Bool]()

        let cancellable = save(profiles: profiles)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(1))
        expect(receivedSaveResults.last).to(beTrue())
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }
}
