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

import Combine
import ComposableArchitecture
import Dependencies
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import Nimble
import TestUtils
import XCTest

final class SceneDelegateTests: XCTestCase {
    private var databaseFile: URL!
    private let userDefaultsStore = UserDefaultsStore(userDefaults: .standard)
    private let fileManager = FileManager.default
    private var coreDataFactory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("testDB_SceneDelegateTests")
    }

    override func tearDown() {
        // important to destory the store so that each test starts with an empty database
        if let controller = try? coreDataFactory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
        }

        userDefaultsStore.wipeAll()
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

    private func loadProfileCoreDataStore() -> ProfileCoreDataStore {
        ProfileCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: AnyScheduler.main
        )
    }

    func testSanitizingDatabaseShouldWipeUserDefaultsIfThereIsNoProfile() throws {
        let factory = loadFactory()
        try withDependencies {
            $0.userDataStore = userDefaultsStore
            $0.coreDataControllerFactory = factory
            $0.tracker = PlaceholderTracker()
        } operation: {
            let sut = SceneDelegate()
            let initialUUID = UUID()
            sut.userDataStore.set(selectedProfileId: initialUUID)
            sut.userDataStore.set(hideOnboarding: true)

            let profileCoreDataStore = ProfileCoreDataStore(
                coreDataControllerFactory: factory,
                backgroundQueue: AnyScheduler.main
            )
            let hadProfile = try profileCoreDataStore.hasProfile()
            expect(hadProfile) == false
            expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true

            try sut.sanitizeDatabases(store: profileCoreDataStore)

            let isProfileExisting = try profileCoreDataStore.hasProfile()
            expect(isProfileExisting) == true
            expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == false
            let currentProfileId = try awaitPublisher(sut.userDataStore.selectedProfileId.first())
            expect(currentProfileId) != initialUUID
            expect(currentProfileId).notTo(beNil())
        }
    }

    func testSanatizingDatabaseShouldNotWipeUserDefaultsIfThereIsAProfile() throws {
        let factory = loadFactory()
        try withDependencies {
            $0.userDataStore = UserDefaultsStore(userDefaults: UserDefaults())
            $0.coreDataControllerFactory = factory
        } operation: {
            let sut = SceneDelegate()
            sut.userDataStore.set(hideOnboarding: true)
            expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true

            let profileCoreDataStore = ProfileCoreDataStore(
                coreDataControllerFactory: factory,
                backgroundQueue: AnyScheduler.main
            )
            let profile = try profileCoreDataStore.createProfile(name: "Test Name")
            sut.userDataStore.set(selectedProfileId: profile.id)
            let hasProfile = try profileCoreDataStore.hasProfile()
            expect(hasProfile) == true

            try sut.sanitizeDatabases(store: profileCoreDataStore)

            expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true
            let currentProfileId = try awaitPublisher(sut.userDataStore.selectedProfileId.first())
            expect(currentProfileId) == profile.id
        }
    }
}
