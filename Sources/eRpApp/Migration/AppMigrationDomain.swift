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
import eRpKit
import eRpLocalStorage
import Foundation

struct AppMigrationDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var migration: MigrationState

        @PresentationState var destination: Destinations.State?

        init(
            migration: MigrationState,
            destination: Destinations.State? = nil
        ) {
            self.migration = migration
            self.destination = destination
        }
    }

    enum MigrationState: Equatable {
        case none
        case inProgress
        case finished
        case failed
    }

    enum Action: Equatable {
        case loadCurrentModelVersion
        case startMigration(from: ModelVersion)
        case startMigrationReceived(Result<ModelVersion, MigrationError>)

        case destination(PresentationAction<Destinations.Action>)
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case alert(AlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case alert(Alert)

            enum Alert: Equatable {
                case loadCurrentModelVersion
                case deleteDatabase
                case close
            }
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.migrationManager) var migrationManager: ModelMigrating
    @Dependency(\.coreDataControllerFactory) var factory: CoreDataControllerFactory
    @Dependency(\.userDataStore) var userDataStore: UserDataStore

    var fileManager: FileManager = .default
    var finishedMigration: () -> Void

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadCurrentModelVersion,
             .destination(.presented(.alert(.loadCurrentModelVersion))):
            let currentVersion = userDataStore.latestCompatibleModelVersion
            return EffectTask.send(.startMigration(from: currentVersion))
        case let .startMigration(from: currentVersion):
            state.migration = .inProgress
            return .publisher(
                migrationManager.startModelMigration(from: currentVersion)
                    .first()
                    .catchToPublisher()
                    .map(Action.startMigrationReceived)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .startMigrationReceived(.success(newVersion)):
            state.migration = .finished
            userDataStore.latestCompatibleModelVersion = newVersion

            if !newVersion.isLastVersion {
                return EffectTask.send(.startMigration(from: newVersion))
            }

            finishedMigration()
            return .none
        case let .startMigrationReceived(.failure(error)):
            if error == .isLatestVersion {
                assertionFailure("MigrationManager should not have been called when the latest version is reached")
                state.migration = .finished
                finishedMigration()
                return .none
            }

            state.migration = .failed
            state.destination = .alert(
                Self.alertState(
                    title: L10n.amgBtnAlertTitle.text,
                    message: error.localizedDescription
                )
            )
            return .none
        case .destination(.presented(.alert(.deleteDatabase))):
            let databaseUrl = factory.databaseUrl
            guard fileManager.fileExists(atPath: databaseUrl.path) else {
                state.migration = .failed
                state.destination = .alert(Self.deleteDatabaseAlertState())
                return .none
            }
            do {
                let databaseUrl = factory.databaseUrl
                if let coreDataController = try? factory.loadCoreDataController() {
                    // Don't let deleting the persistent store stop deleting the database file
                    try? coreDataController.destroyPersistentStore(at: databaseUrl)
                }
                let fileName = databaseUrl.lastPathComponent
                let folderUrl = databaseUrl.deletingLastPathComponent()
                let shmFileUrl = folderUrl.appendingPathComponent("\(fileName)-shm")
                let walFileUrl = folderUrl.appendingPathComponent("\(fileName)-wal")
                try fileManager.removeItem(at: shmFileUrl)
                try fileManager.removeItem(at: walFileUrl)
                try fileManager.removeItem(at: databaseUrl)
                state.migration = .finished
                finishedMigration()
            } catch {
                state.migration = .failed
                state.destination = .alert(Self.deleteDatabaseAlertState())
            }
            return .none
        case .destination(.presented(.alert(.close))):
            state.migration = .finished
            finishedMigration()
            return .none
        case .destination:
            return .none
        }
    }

    static func deleteDatabaseAlertState() -> AlertState<Destinations.Action.Alert> {
        AlertState(
            title: TextState(L10n.amgTxtAlertTitleDeleteDatabase),
            message: TextState(L10n.amgTxtAlertMessageDeleteDatabase),
            primaryButton: .destructive(TextState(L10n.amgBtnAlertDeleteDatabase), action: .send(.deleteDatabase)),
            secondaryButton: .cancel(TextState(L10n.amgBtnAlertCancel), action: .send(.close))
        )
    }

    static func alertState(title: String, message: String) -> AlertState<Destinations.Action.Alert> {
        AlertState(
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
                initialState: state
            ) {
                AppMigrationDomain {}
            }
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
