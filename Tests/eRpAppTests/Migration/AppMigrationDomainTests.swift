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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import Nimble
import XCTest

final class AppMigrationDomainTests: XCTestCase {
    private var mockMigrationManager = MockMigrationManager()
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
        AppMigrationDomain.State,
        AppMigrationDomain.Action,
        AppMigrationDomain.Action,
        AppMigrationDomain.Environment
    >

//    let testScheduler = DispatchQueue.test
    private func testStore(with state: AppMigrationDomain.State = .none) -> TestStore {
        TestStore(
            initialState: state,
            reducer: AppMigrationDomain.reducer,
            environment: AppMigrationDomain.Environment(
                schedulers: Schedulers(
                    uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler()
                ),
                migrationManager: mockMigrationManager,
                factory: loadFactory(),
                userDataStore: mockUserDataStore,
                fileManager: fileManager,
                finishedMigration: { [weak self] in
                    self?.finishedMigrationCalledCount += 1
                }
            )
        )
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

//    func testMigrationWithMigratingOneStepHappyPath() {
//        let store = testStore()
//        let startVersion: ModelVersion = .taskStatus
//        let endVersion: ModelVersion = .auditEventsInProfile
//        mockMigrationManager.startModelMigrationReturnValue = CurrentValueSubject(startVersion.next()!)
//            .setFailureType(to: MigrationError.self)
//            .eraseToAnyPublisher()
//
//        mockUserDataStore.underlyingLastCompatibleCoreDataModelVersion = startVersion
//        store.send(.loadCurrentModelVersion) { state in
//            state = .none
//        }
//        expect(self.mockUserDataStore.latestCompatibleCoreDataModelVersionCallsCount) == 1
//        expect(self.mockMigrationManager.startModelMigrationCallsCount) == 1
//        testScheduler.advance()
//        store.receive(.startMigration(from: startVersion)) { state in
//            state = .inProgress
//        }
//        mockUserDataStore.underlyingLastCompatibleCoreDataModelVersion = .profiles
//        testScheduler.advance()
//        store.receive(.startMigrationReceived(.success(.profiles))) { state in
//            state = .finished
//        }
//        testScheduler.advance()
//        store.receive(.startMigration(from: .profiles)) { state in
//            state = .inProgress
//        }
//        mockUserDataStore.underlyingLastCompatibleCoreDataModelVersion = .auditEventsInProfile
//        testScheduler.advance()
//        store.receive(.startMigrationReceived(.success(.auditEventsInProfile))) { state in
//            state = .finished
//        }
//        testScheduler.advance()
//        expect(self.mockUserDataStore.latestCompatibleModelVersion) == endVersion
//        expect(self.mockUserDataStore.latestCompatibleCoreDataModelVersionCallsCount) == 2
//        expect(self.finishedMigrationCalledCount) == 1
//    }

    func testMigrationWithMigratingOneStepHappyPath_short() {
        let store = testStore()
        let startVersion: ModelVersion = .profiles
        let endVersion: ModelVersion = .auditEventsInProfile
        mockMigrationManager.startModelMigrationReturnValue = CurrentValueSubject(startVersion.next()!)
            .setFailureType(to: MigrationError.self)
            .eraseToAnyPublisher()

        mockUserDataStore.underlyingLastCompatibleCoreDataModelVersion = startVersion
        store.send(.loadCurrentModelVersion) { state in
            state = .none
        }
        expect(self.mockUserDataStore.latestCompatibleCoreDataModelVersionCallsCount) == 1
        expect(self.mockMigrationManager.startModelMigrationCallsCount) == 1
        store.receive(.startMigration(from: startVersion)) { state in
            state = .inProgress
        }
        store.receive(.startMigrationReceived(.success(endVersion))) { state in
            state = .finished
        }
        expect(self.mockUserDataStore.latestCompatibleModelVersion) == endVersion
        expect(self.mockUserDataStore.latestCompatibleCoreDataModelVersionCallsCount) == 2
        expect(self.finishedMigrationCalledCount) == 1
    }

    func testMigratingWithErrorAndRetry() {
        let store = testStore()
        let expectedError = MigrationError.initialization(error: LocalStoreError.notImplemented)
        mockMigrationManager.startModelMigrationReturnValue = Fail(error: expectedError).eraseToAnyPublisher()

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
        store.send(.loadCurrentModelVersion) { state in
            state = .failed(
                AppMigrationDomain.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: expectedError.localizedDescription
                )
            )
        }
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
