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
            backgroundQueue: AnyScheduler.main
        )
    }

    private func loadErxCoreDataStore(for profileId: UUID? = nil) throws -> ErxTaskCoreDataStore {
        ErxTaskCoreDataStore(
            profileId: profileId,
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: AnyScheduler.main
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
            givenName: "Karl",
            familyName: "Heinz",
            insurance: "Random BKK",
            insuranceId: "k1234",
            color: .grey,
            lastAuthenticated: Date()
        )
    }()

    private lazy var profileWithTasks: Profile = {
        Profile(
            name: "Karl",
            identifier: UUID(),
            givenName: "Karl",
            familyName: "Heinz",
            insurance: "Random BKK",
            insuranceId: "k1234",
            color: .grey,
            emoji: "🤖",
            lastAuthenticated: Date(),
            erxTasks: [ErxTask(identifier: "id1", status: .ready, accessCode: "accessCode1"),
                       ErxTask(identifier: "id2", status: .ready, accessCode: "accessCode2")]
        )
    }()

    func testSavingProfile() throws {
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileSimple, profileWithTasks])
    }

    func testSavingProfileWillNotStoreTasksAndAuditEvents() throws {
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileSimple, profileWithTasks])

        // verify result
        var receivedListAllProfileValues = [[Profile]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
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
        let expectedResult = Profile(name: profileWithTasks.name,
                                     identifier: profileWithTasks.identifier,
                                     created: profileWithTasks.created,
                                     givenName: profileWithTasks.givenName,
                                     familyName: profileWithTasks.familyName,
                                     insurance: profileWithTasks.insurance,
                                     insuranceId: profileWithTasks.insuranceId,
                                     color: profileWithTasks.color,
                                     emoji: profileWithTasks.emoji,
                                     lastAuthenticated: profileWithTasks.lastAuthenticated,
                                     erxTasks: [])
        expect(receivedProfiles).to(contain(expectedResult))

        cancellable.cancel()
    }

    func testSaveProfilesWithFailingLoadingDatabase() throws {
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerError = LocalStoreError.notImplemented
        let store = ProfileCoreDataStore(
            coreDataControllerFactory: factory,
            backgroundQueue: AnyScheduler.main
        )

        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
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
            .failure(LocalStoreError.initialization(error: factory.loadCoreDataControllerError!))

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
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()

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
        expect(receivedProfiles[0]) == heinz
        expect(receivedProfiles[1]) == dieter

        cancellable.cancel()
    }

    func testUpdatingProfile() throws {
        let store = loadProfileCoreDataStore()
        // given
        try store.add(profiles: [profileSimple])

        let updatedProfile = Profile(
            name: "New Karl",
            identifier: profileSimple.identifier,
            givenName: "New",
            familyName: "Karl",
            insurance: "New BKK",
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
        expect(result?.givenName) == updatedProfile.givenName
        expect(result?.familyName) == updatedProfile.familyName
        expect(result?.insurance) == updatedProfile.insurance
        expect(result?.insuranceId) == updatedProfile.insuranceId
        expect(result?.lastAuthenticated) == updatedProfile.lastAuthenticated
        expect(result?.erxTasks) == [] // erxTasks should not be saved

        cancellable.cancel()
    }

    func testDeleteProfileWithTasks() throws {
        // given when we store a profile and related tasks and audit events
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileWithTasks])
        let erxTaskStore = try loadErxCoreDataStore(for: profileWithTasks.identifier)
        // task and audit events have to be stored separately
        try erxTaskStore.add(tasks: profileWithTasks.erxTasks)

        // when deleting the profile
        var receivedDeleteResults = [Bool]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = store.delete(profiles: [profileWithTasks])
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

    func testUpdateProfileWithMatchingProfileInStore() throws {
        // given
        let store = loadProfileCoreDataStore()
        try store.add(profiles: [profileAuthenticated])

        // when
        var receivedUpdateValues = [Bool]()
        var expectedResult: Profile?
        _ = store.update(profileId: profileAuthenticated.id) { profile in
            profile.name = "Updated Name"
            expectedResult = profile
        }
        .sink(receiveCompletion: { completion in
            expect(completion) == .finished
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedUpdateValues.count).toEventually(equal(1))

        var receivedListAllProfileValues = [[Profile]]()
        // we observe all store changes
        let cancellable = store.listAllProfiles()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { profiles in
                receivedListAllProfileValues.append(profiles)
            })

        // than
        expect(receivedListAllProfileValues.count).toEventually(equal(1))
        expect(receivedListAllProfileValues.first?.count) == 1
        expect(receivedListAllProfileValues.first?.first) == expectedResult

        cancellable.cancel()
    }

    func testUpdateProfileWithoutMatchingProfileInStore() throws {
        let store = loadProfileCoreDataStore()
        var receivedUpdateValues = [Bool]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = store.update(profileId: profileAuthenticated.id) { _ in
            fail("should not be called if an error fetching profile occurs")
        }
        .sink(receiveCompletion: { completion in
            receivedCompletions.append(completion)
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedCompletions.count).toEventually(equal(1))
        let expectedError = LocalStoreError.write(error: ProfileCoreDataStore.Error.noMatchingEntity)
        expect(receivedCompletions.first) == .failure(expectedError)
        expect(receivedUpdateValues.count).toEventually(equal(0))

        cancellable.cancel()
    }

    func testFetchingProfilesWithTasks() throws {
        // given
        let profileStore = loadProfileCoreDataStore()
        try profileStore.add(profiles: [profileWithTasks])
        let erxTaskStore = try loadErxCoreDataStore(for: profileWithTasks.identifier)
        // task and audit events have to be stored separately
        try erxTaskStore.add(tasks: profileWithTasks.erxTasks)

        // when fetching ...
        var receivedListAllProfileValues = [[Profile]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
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
        expect(profile.name) == profileWithTasks.name
        expect(profile.identifier) == profileWithTasks.identifier
        expect(profile.givenName) == profileWithTasks.givenName
        expect(profile.familyName) == profileWithTasks.familyName
        expect(profile.insurance) == profileWithTasks.insurance
        expect(profile.erxTasks).to(contain(profileWithTasks.erxTasks))
        cancellable.cancel()
    }
}

extension ProfileCoreDataStore {
    func add(profiles: [Profile]) throws {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
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
