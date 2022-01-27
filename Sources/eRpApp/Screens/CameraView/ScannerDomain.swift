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

enum ScannerDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil.
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case saveErxTasks
        case resetScanState
        case loadErxTask
    }

    struct Environment {
        let repository: ErxTaskRepositoryAccess
        let dateFormatter: FHIRDateFormatter
        var messageInterval: DispatchQueue.SchedulerTimeType.Stride = 2.0
        let scheduler: Schedulers
    }

    struct State: Equatable {
        /// Presents the current state of the scanning process. Errors are displayed as hints
        var scanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .idle
        /// Array of all accepted tasks which are ready for saving
        var acceptedTaskBatches = Set<[ScannedErxTask]>()
        /// Used to present an alert
        var alertState: AlertState<Action>?
    }

    enum Action: Equatable {
        /// Closes the scanner view
        case close
        /// Closes if there are no scanned tasks, otherwise presents an alert
        case closeWithoutSave
        /// Saves all scanned tasks and closes after successful save. In case of failure `showError` is called
        case saveAndClose(Set<[ScannedErxTask]>)
        /// Called if an error during save occurs
        case saveAndCloseReceived(ErxTaskRepositoryError)
        /// Analyses the scan output and add calls  `analysesReceived` with the result
        case analyse(scanOutput: [ScanOutput])
        /// Mutates the `scanState` after successful scan and calls `resetScannerState` after `messageInterval` passed
        case analyseReceived(LoadingState<[ScannedErxTask], ScannerDomain.Error>)
        /// Changes the `scanState` to `idle`
        case resetScannerState
        /// Sets the `alertState` back to nil (which hides the alert)
        case alertDismissButtonTapped
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .close:
            // view is closed by parent view
            return .none
        case let .saveAndClose(scannedBatches):
            let authoredOn = environment.dateFormatter.stringWithLongUTCTimeZone(from: Date())
            let erxTasks = scannedBatches.flatMap { $0 }.asErxTasks(status: .ready, with: authoredOn)

            return environment.repository.save(erxTasks)
                .receive(on: environment.scheduler.main)
                .map { _ in Action.close }
                .catch { error in
                    Just(Action.saveAndCloseReceived(error))
                }
                .eraseToEffect()
                .cancellable(id: Token.saveErxTasks)
        case let .saveAndCloseReceived(error):
            state.alertState = savingAlertState
            return .none
        case let .analyse(scanOutput):
            state.scanState = .loading(nil)
            do {
                let scannedTasks = try CodeAnalyser.analyse(scanOutput: scanOutput, with: state.acceptedTaskBatches)
                return environment.checkForDuplicatesInStore(scannedTasks)
                    .cancellable(id: Token.loadErxTask)
            } catch let error as ScannerDomain.Error {
                return Effect(value: .analyseReceived(.error(error)))
            } catch let error as ScannedErxTask.Error {
                return Effect(value: .analyseReceived(.error(.scannedErxTask(error))))
            } catch {
                return Effect(value: .analyseReceived(.error(.unknown)))
            }
        case let .analyseReceived(loadingState):
            if case let .value(scannedErxTask) = loadingState {
                state.acceptedTaskBatches.insert(scannedErxTask)
            }
            state.scanState = loadingState
            return Effect(value: .resetScannerState)
                .delay(for: environment.messageInterval, scheduler: environment.scheduler.main)
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .cancellable(id: Token.resetScanState, cancelInFlight: true)
        case .resetScannerState:
            state.scanState = .idle
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case .closeWithoutSave:
            if state.acceptedTaskBatches.isEmpty {
                return Effect(value: .close)
            } else {
                state.alertState = closeAlertState
                return .none
            }
        }
    }

    static var closeAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.camTxtWarnCancelTitle),
            primaryButton: .destructive(TextState(L10n.camTxtWarnContinue), send: nil),
            secondaryButton: .default(TextState(L10n.camTxtWarnCancel), send: .close)
        )
    }()

    static var savingAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.alertErrorTitle),
            message: TextState(L10n.scnMsgSavingError),
            dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
        )
    }()
}

extension ScannerDomain.Environment {
    func checkForDuplicatesInStore(_ scannedTasks: [ScannedErxTask]) -> Effect<ScannerDomain.Action, Never> {
        let findPublishers: [AnyPublisher<ScannedErxTask?, Never>] = scannedTasks.map { scannedTask in
            self.repository.find(by: scannedTask.id, accessCode: scannedTask.accessCode)
                .map { erxTask -> ScannedErxTask? in
                    if erxTask != nil {
                        return nil // by returning nil we sort out previously stored tasks
                    } else {
                        return scannedTask
                    }
                }
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(findPublishers)
            .collect(findPublishers.count)
            .map { optionalTasks in
                let tasks = optionalTasks.compactMap { $0 }
                if tasks.isEmpty {
                    return .analyseReceived(.error(.storeDuplicate))
                } else {
                    return .analyseReceived(.value(tasks))
                }
            }
            .receive(on: scheduler.main)
            .eraseToEffect()
    }
}

extension Sequence where Element == ScannedErxTask {
    func asErxTasks(status: ErxTask.Status, with authoredOn: String) -> [ErxTask] {
        var prescriptionCount = 1
        var tasks = [ErxTask]()
        for scannedTask in self {
            let task = ErxTask(
                identifier: scannedTask.id,
                status: status,
                accessCode: scannedTask.accessCode,
                authoredOn: authoredOn,
                author: NSLocalizedString("scn_txt_author", comment: ""),
                source: .scanner,
                medication: ErxTask.Medication(name: String(format: medicationStringFormat, String(prescriptionCount)))
            )
            tasks.append(task)
            prescriptionCount += 1
        }

        return tasks
    }

    private var medicationStringFormat: String {
        NSLocalizedString("scn_txt_medication_%@", comment: "")
    }
}

extension ScannerDomain {
    enum Dummies {
        static func store(with state: State) -> Store {
            Store(initialState: state,
                  reducer: domainReducer,
                  environment: Dummies.environment)
        }

        static let store = Store(initialState: Dummies.state,
                                 reducer: domainReducer,
                                 environment: Dummies.environment)

        static let state = State()

        static let environment = Environment(repository: DemoSessionContainer().erxTaskRepository,
                                             dateFormatter: globals.fhirDateFormatter,
                                             scheduler: Schedulers())
    }
}
