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
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import Nimble
import XCTest

@MainActor
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

    typealias TestStore = TestStoreOf<AppMigrationDomain>

//    let testScheduler = DispatchQueue.test
    private func testStore(with state: AppMigrationDomain.State = .init(migration: .none)) -> TestStore {
        TestStore(initialState: state) {
            AppMigrationDomain(
                fileManager: fileManager,
                finishedMigration: { [weak self] in
                    self?.finishedMigrationCalledCount += 1
                }
            )
        } withDependencies: { dependencies in
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

    func testMigrationWithMigratingOneStepHappyPath_short() async {
        let store = testStore()
        let startVersion: ModelVersion = .displayName
        let endVersion: ModelVersion = .shouldAutoUpdateNameAtNextLogin
        mockMigrationManager
            .startModelMigrationFromDefaultProfileNameReturnValue = CurrentValueSubject(endVersion)
            .setFailureType(to: MigrationError.self)
            .eraseToAnyPublisher()

        mockUserDataStore.underlyingLatestCompatibleModelVersion = startVersion
        await store.send(.loadCurrentModelVersion)
        expect(self.mockMigrationManager.startModelMigrationFromDefaultProfileNameCallsCount) == 1
        await store.receive(.startMigration(from: startVersion)) { state in
            state.migration = .inProgress
        }
        await store.receive(.startMigrationReceived(.success(endVersion))) { state in
            state.migration = .finished
        }
        expect(self.mockUserDataStore.latestCompatibleModelVersion) == endVersion
        expect(self.finishedMigrationCalledCount) == 1
    }

    func testMigratingWithErrorAndRetry() async {
        let store = testStore()
        let expectedError = MigrationError.initialization(error: LocalStoreError.notImplemented)
        mockMigrationManager.startModelMigrationFromDefaultProfileNameReturnValue = Fail(error: expectedError)
            .eraseToAnyPublisher()
        mockUserDataStore.underlyingLatestCompatibleModelVersion = .taskStatus

        await store.send(.startMigration(from: .taskStatus)) { state in
            state.migration = .inProgress
        }
        await store.receive(.startMigrationReceived(.failure(expectedError))) { state in
            state.migration = .failed
            state.destination = .alert(
                AppMigrationDomain.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: expectedError.localizedDescription
                )
            )
        }
        // retry after error
        await store.send(.loadCurrentModelVersion)
        await store.receive(.startMigration(from: .taskStatus)) { state in
            state.migration = .inProgress
        }
        await store.receive(.startMigrationReceived(.failure(expectedError))) { state in
            state.migration = .failed
            state.destination = .alert(
                AppMigrationDomain.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: expectedError.localizedDescription
                )
            )
        }
    }

    func testDeleteDatabaseWithError() async {
        let store =
            testStore(with: .init(migration: .failed,
                                  destination: .alert(AppMigrationDomain.alertState(title: "Error", message: "Error"))))

        await store.send(.destination(.presented(.alert(.deleteDatabase)))) { state in
            state.migration = .failed
            state.destination = .alert(AppMigrationDomain.deleteDatabaseAlertState())
        }
    }

    func testDeleteDatabaseSuccess() async throws {
        let store =
            testStore(with: .init(migration: .failed,
                                  destination: .alert(AppMigrationDomain.alertState(title: "Error", message: "Error"))))

        // when creating a core data base
        _ = try loadFactory().loadCoreDataController()

        await store.send(.destination(.presented(.alert(.deleteDatabase)))) { state in
            state.migration = .finished
            state.destination = nil
        }
    }
}
