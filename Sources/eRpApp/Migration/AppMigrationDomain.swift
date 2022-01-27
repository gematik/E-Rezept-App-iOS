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
import eRpKit
import eRpLocalStorage

enum AppMigrationDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case migration
    }

    enum State: Equatable {
        case none
        case inProgress
        case finished
        case failed(AlertState<Action>)

        var failedValue: AlertState<Action>? {
            guard case let .failed(alertState) = self else {
                return nil
            }
            return alertState
        }
    }

    enum Action: Equatable {
        case loadCurrentModelVersion
        case startMigration(from: ModelVersion)
        case startMigrationReceived(Result<ModelVersion, MigrationError>)
        case deleteDatabase
        case close
        case nothing
    }

    struct Environment {
        let schedulers: Schedulers
        let migrationManager: ModelMigrating
        let factory: CoreDataControllerFactory
        let userDataStore: UserDataStore
        let fileManager: FileManager
        var finishedMigration: () -> Void
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadCurrentModelVersion:
            let currentVersion = environment.userDataStore.latestCompatibleModelVersion
            return Effect(value: .startMigration(from: currentVersion))
        case let .startMigration(from: currentVersion):
            state = .inProgress
            return environment.migrationManager.startModelMigration(from: currentVersion)
                .first()
                .catchToEffect()
                .map(Action.startMigrationReceived)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .startMigrationReceived(.success(newVersion)):
            state = .finished
            environment.userDataStore.latestCompatibleModelVersion = newVersion

            if !newVersion.isLastVersion {
                return Effect(value: .startMigration(from: newVersion))
            }

            environment.finishedMigration()
            return .none
        case let .startMigrationReceived(.failure(error)):
            if error == .isLatestVersion {
                assertionFailure("MigrationManager should not have been called when the latest version is reached")
                state = .finished
                environment.finishedMigration()
                return .none
            }

            state = .failed(
                alertState(
                    title: NSLocalizedString("amg_btn_alert_title", comment: ""),
                    message: error.localizedDescription
                )
            )
            return .none
        case .deleteDatabase:
            let databaseUrl = environment.factory.databaseUrl
            guard environment.fileManager.fileExists(atPath: databaseUrl.path) else {
                state = .failed(deleteDatabaseAlertState())
                return .none
            }
            do {
                let databaseUrl = environment.factory.databaseUrl
                if let coreDataController = try? environment.factory.loadCoreDataController() {
                    // Don't let deleting the persistent store stop deleting the database file
                    try? coreDataController.destroyPersistentStore(at: databaseUrl)
                }
                let fileName = databaseUrl.lastPathComponent
                let folderUrl = databaseUrl.deletingLastPathComponent()
                let shmFileUrl = folderUrl.appendingPathComponent("\(fileName)-shm")
                let walFileUrl = folderUrl.appendingPathComponent("\(fileName)-wal")
                try environment.fileManager.removeItem(at: shmFileUrl)
                try environment.fileManager.removeItem(at: walFileUrl)
                try environment.fileManager.removeItem(at: databaseUrl)
                state = .finished
                environment.finishedMigration()
            } catch {
                state = .failed(deleteDatabaseAlertState())
            }
            return .none
        case .close:
            state = .finished
            environment.finishedMigration()
            return .none
        case .nothing:
            return .none
        }
    }

    static let reducer: Reducer = domainReducer

    static func deleteDatabaseAlertState() -> AlertState<Action> {
        AlertState<Action>(
            title: TextState(L10n.amgTxtAlertTitleDeleteDatabase),
            message: TextState(L10n.amgTxtAlertMessageDeleteDatabase),
            primaryButton: .destructive(TextState(L10n.amgBtnAlertDeleteDatabase), action: .send(.deleteDatabase)),
            secondaryButton: .cancel(TextState(L10n.amgBtnAlertCancel), action: .send(.close))
        )
    }

    static func alertState(title: String, message: String) -> AlertState<Action> {
        AlertState<Action>(
            title: TextState(title),
            message: TextState(message),
            primaryButton: .destructive(TextState(L10n.amgBtnAlertDeleteDatabase), action: .send(.deleteDatabase)),
            secondaryButton: .default(TextState(L10n.amgBtnAlertRetry), action: .send(.loadCurrentModelVersion))
        )
    }
}

extension AppMigrationDomain {
    enum Dummies {
        static func store(for state: AppMigrationDomain.State) -> AppMigrationDomain.Store {
            AppMigrationDomain.Store(
                initialState: state,
                reducer: .empty,
                environment: AppMigrationDomain.Environment(
                    schedulers: Schedulers(),
                    migrationManager: MigrationManager.failing,
                    factory: LocalStoreFactory.failing,
                    userDataStore: DemoUserDefaultsStore(),
                    fileManager: FileManager.default
                ) {}
            )
        }
    }
}

extension MigrationManager {
    static var failing = MigrationManager(
        factory: LocalStoreFactory.failing,
        erxTaskCoreDataStore: .failing,
        userDataStore: DemoUserDefaultsStore()
    )
}
