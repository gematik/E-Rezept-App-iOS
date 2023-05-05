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
import XCTest

final class AppMigrationDomainTests: XCTestCase {
    private var mockMigrationManager = MockModelMigrating()
    private var mockUserDataStore = MockUserDataStore()
    private var finishedMigrationCalledCount: Int = 0
    private var finishedMigrationCalled: Bool {
        finishedMigrationCalledCount > 0
    }

    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var coreDataFactory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("Filename.txt")
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: databaseFile.path) {
            if let coreDataController = try? coreDataFactory?.loadCoreDataController() {
                expect(try coreDataController.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
            }
            let fileName = databaseFile.lastPathComponent
            let pathToFile = databaseFile.deletingLastPathComponent()
            let shmFileUrl = pathToFile.appendingPathComponent("\(fileName)-shm")
            let walFileUrl = pathToFile.appendingPathComponent("\(fileName)-wal")
            expect(try self.fileManager.removeItem(at: shmFileUrl)).toNot(throwError())
            expect(try self.fileManager.removeItem(at: walFileUrl)).toNot(throwError())
            expect(try self.fileManager.removeItem(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    typealias TestStore = ComposableArchitecture.TestStore<
        AppMigrationDomain.State,
        AppMigrationDomain.Action,
        AppMigrationDomain.State,
        AppMigrationDomain.Action,
        Void
    >

//    let testScheduler = DispatchQueue.test
    private func testStore(with state: AppMigrationDomain.State = .none) -> TestStore {
        TestStore(
            initialState: state,
            reducer: AppMigrationDomain(
                fileManager: fileManager,
                finishedMigration: { [weak self] in
                    self?.finishedMigrationCalledCount += 1
                }
            )
        ) { dependencies in
            dependencies.schedulers = Schedulers(
                uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler()
            )
            dependencies.migrationManager = mockMigrationManager
            dependencies.coreDataControllerFactory = loadFactory()
            dependencies.userDataStore = mockUserDataStore
        }
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

    func testMigrationWithMigratingOneStepHappyPath_short() {
        let store = testStore()
        let startVersion: ModelVersion = .auditEventsInProfile
        let endVersion: ModelVersion = .pKV
        mockMigrationManager.startModelMigrationFromReturnValue = CurrentValueSubject(startVersion.next()!)
            .setFailureType(to: MigrationError.self)
            .eraseToAnyPublisher()

        mockUserDataStore.underlyingLatestCompatibleModelVersion = startVersion
        store.send(.loadCurrentModelVersion)
        expect(self.mockMigrationManager.startModelMigrationFromCallsCount) == 1
        store.receive(.startMigration(from: startVersion)) { state in
            state = .inProgress
        }
        store.receive(.startMigrationReceived(.success(endVersion))) { state in
            state = .finished
        }
        expect(self.mockUserDataStore.latestCompatibleModelVersion) == endVersion
        expect(self.finishedMigrationCalledCount) == 1
    }

    func testMigratingWithErrorAndRetry() {
        let store = testStore()
        let expectedError = MigrationError.initialization(error: LocalStoreError.notImplemented)
        mockMigrationManager.startModelMigrationFromReturnValue = Fail(error: expectedError).eraseToAnyPublisher()
        mockUserDataStore.underlyingLatestCompatibleModelVersion = .taskStatus

        store.send(.startMigration(from: .taskStatus)) { state in
            state = .inProgress
        }
        store.receive(.startMigrationReceived(.failure(expectedError))) { state in
            state = .failed(
                AppMigrationDomain.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: expectedError.localizedDescription
                )
            )
        }
        // retry after error
        store.send(.loadCurrentModelVersion)
        store.receive(.startMigration(from: .taskStatus)) { state in
            state = .inProgress
        }
        store.receive(.startMigrationReceived(.failure(expectedError))) { state in
            state = .failed(
                AppMigrationDomain.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: expectedError.localizedDescription
                )
            )
        }
    }

    func testDeleteDatabaseWithError() {
        let store = testStore()

        store.send(.deleteDatabase) { state in
            state = .failed(AppMigrationDomain.deleteDatabaseAlertState())
        }
    }

    func testDeleteDatabaseSuccess() throws {
        let store = testStore(with: .failed(AppMigrationDomain.alertState(title: "Error", message: "Error")))

        // when creating a core data base
        _ = try loadFactory().loadCoreDataController()

        store.send(.deleteDatabase) { state in
            state = .finished
        }
    }
}
