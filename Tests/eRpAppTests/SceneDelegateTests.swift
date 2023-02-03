//
//  Copyright (c) 2023 gematik GmbH
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
@testable import eRpApp
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
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("testDB")
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

    func testSanatizingDatabaseShouldWipeUserDefaultsIfThereIsNoProfile() throws {
        let sut = SceneDelegate()
        sut.userDataStore = userDefaultsStore
        sut.coreDataControllerFactory = loadFactory()

        let initialUUID = UUID()
        sut.userDataStore.set(selectedProfileId: initialUUID)
        sut.userDataStore.set(hideOnboarding: true)

        let profileCoreDataStore = ProfileCoreDataStore(
            coreDataControllerFactory: sut.coreDataControllerFactory,
            backgroundQueue: AnyScheduler.main
        )
        let hadProfile = try profileCoreDataStore.hasProfile()
        expect(hadProfile) == false
        expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true

        try sut.sanatizeDatabases(store: profileCoreDataStore)

        let isProfileExisting = try profileCoreDataStore.hasProfile()
        expect(isProfileExisting) == true
        expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == false
        let currentProfileId = try awaitPublisher(sut.userDataStore.selectedProfileId.first())
        expect(currentProfileId) != initialUUID
        expect(currentProfileId).notTo(beNil())
    }

    func testSanatizingDatabaseShouldNotWipeUserDefaultsIfThereIsAProfile() throws {
        let sut = SceneDelegate()
        sut.userDataStore = UserDefaultsStore(userDefaults: UserDefaults())
        sut.coreDataControllerFactory = loadFactory()

        sut.userDataStore.set(hideOnboarding: true)
        expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true

        let profileCoreDataStore = ProfileCoreDataStore(
            coreDataControllerFactory: sut.coreDataControllerFactory,
            backgroundQueue: AnyScheduler.main
        )
        let profile = try profileCoreDataStore.createProfile(with: "Test Name")
        sut.userDataStore.set(selectedProfileId: profile.id)
        let hasProfile = try profileCoreDataStore.hasProfile()
        expect(hasProfile) == true

        try sut.sanatizeDatabases(store: profileCoreDataStore)

        expect(try self.awaitPublisher(sut.userDataStore.hideOnboarding.first())) == true
        let currentProfileId = try awaitPublisher(sut.userDataStore.selectedProfileId.first())
        expect(currentProfileId) == profile.id
    }
}
