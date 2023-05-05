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
import Foundation

struct ScannerDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil.
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case saveErxTasks
        case resetScanState
        case loadErxTask
    }

    struct State: Equatable {
        /// Presents the current state of the scanning process. Errors are displayed as hints
        var scanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .idle
        /// Array of all accepted tasks which are ready for saving
        var acceptedTaskBatches = Set<[ScannedErxTask]>()
        /// Used to present an alert
        var alertState: AlertState<Action>?
        /// Bool to handle the flashlight state
        var isFlashOn = false
    }

    enum Action: Equatable {
        /// Closes if there are no scanned tasks, otherwise presents an alert
        case closeWithoutSave
        /// Saves all scanned tasks and closes after successful save. In case of failure `showError` is called
        case saveAndClose(Set<[ScannedErxTask]>)
        /// Analyses the scan output and add calls  `analysesReceived` with the result
        case analyse(scanOutput: [ScanOutput])
        /// Changes the `scanState` to `idle`
        case resetScannerState
        /// Sets the `alertState` back to nil (which hides the alert)
        case alertDismissButtonTapped
        /// Delegates the parent to close the scanner view
        case closeAlertCancelButtonTapped
        /// Toggles the flashlight
        case toggleFlashLight
        /// set isFlashOn to false
        case flashLightOff

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            /// Called if an error during save occurs
            case saveAndCloseReceived(ErxRepositoryError)
            /// Mutates the `scanState` after successful scan
            /// and calls `resetScannerState` after `messageInterval` passed
            case analyseReceived(LoadingState<[ScannedErxTask], ScannerDomain.Error>)
        }

        enum Delegate: Equatable {
            /// Closes the scanner view
            case close
        }
    }

    var messageInterval: DispatchQueue.SchedulerTimeType.Stride = 2.0

    @Dependency(\.erxTaskRepository) var repository: ErxTaskRepository
    @Dependency(\.fhirDateFormatter) var dateFormatter: FHIRDateFormatter
    @Dependency(\.schedulers) var scheduler: Schedulers

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .saveAndClose(scannedBatches):
            let authoredOn = dateFormatter.stringWithLongUTCTimeZone(from: Date())
            let erxTasks = scannedBatches.flatMap { $0 }.asErxTasks(status: .ready, with: authoredOn)

            return repository.save(erxTasks: erxTasks)
                .first()
                .receive(on: scheduler.main)
                .map { _ in Action.delegate(.close) }
                .catch { error in
                    Just(Action.response(.saveAndCloseReceived(error)))
                }
                .eraseToEffect()
                .cancellable(id: Token.saveErxTasks)
        case .response(.saveAndCloseReceived):
            state.alertState = Self.savingAlertState
            return .none
        case let .analyse(scanOutput):
            state.scanState = .loading(nil)
            do {
                let scannedTasks = try CodeAnalyser.analyse(scanOutput: scanOutput, with: state.acceptedTaskBatches)
                return checkForTaskDuplicatesInStore(scannedTasks)
                    .cancellable(id: Token.loadErxTask)
            } catch let error as ScannerDomain.Error {
                return Effect(value: .response(.analyseReceived(.error(error))))
            } catch let error as ScannedErxTask.Error {
                return Effect(value: .response(.analyseReceived(.error(.scannedErxTask(error)))))
            } catch {
                return Effect(value: .response(.analyseReceived(.error(.unknown))))
            }
        case let .response(.analyseReceived(loadingState)):
            if case let .value(scannedErxTask) = loadingState {
                state.acceptedTaskBatches.insert(scannedErxTask)
            }
            state.scanState = loadingState
            return Effect(value: .resetScannerState)
                .delay(for: messageInterval, scheduler: scheduler.main)
                .receive(on: scheduler.main)
                .eraseToEffect()
                .cancellable(id: Token.resetScanState, cancelInFlight: true)
        case .resetScannerState:
            state.scanState = .idle
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case .closeAlertCancelButtonTapped:
            state.alertState = nil
            return Effect(value: .delegate(.close))
        case .closeWithoutSave:
            if state.acceptedTaskBatches.isEmpty {
                return Effect(value: .delegate(.close))
            } else {
                state.alertState = Self.closeAlertState
                return .none
            }
        case .toggleFlashLight:
            state.isFlashOn.toggle()
            return .none
        case .flashLightOff:
            state.isFlashOn = false
            return .none
        case .delegate:
            return .none
        }
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    static let closeAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.camTxtWarnCancelTitle),
            primaryButton: .destructive(TextState(L10n.camTxtWarnContinue), action: nil),
            secondaryButton: .cancel(TextState(L10n.camTxtWarnCancel), action: .send(.closeAlertCancelButtonTapped))
        )
    }()

    static let savingAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.alertErrorTitle),
            message: TextState(L10n.scnMsgSavingError),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
    }()
}

extension ScannerDomain {
    func checkForTaskDuplicatesInStore(_ scannedTasks: [ScannedErxTask]) -> Effect<ScannerDomain.Action, Never> {
        let findPublishers: [AnyPublisher<ScannedErxTask?, Never>] = scannedTasks.map { scannedTask in
            self.repository.loadLocal(by: scannedTask.id, accessCode: scannedTask.accessCode)
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
                    return .response(.analyseReceived(.error(.storeDuplicate)))
                } else {
                    return .response(.analyseReceived(.value(tasks)))
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
                author: L10n.scnTxtAuthor.text,
                source: .scanner,
                medication: ErxMedication(name: L10n.scnTxtMedication(String(prescriptionCount)).text)
            )
            tasks.append(task)
            prescriptionCount += 1
        }

        return tasks
    }
}

extension ScannerDomain {
    enum Dummies {
        static let store = Store(initialState: Dummies.state,
                                 reducer: ScannerDomain())

        static func store(with state: State) -> StoreOf<ScannerDomain> {
            Store(initialState: state,
                  reducer: ScannerDomain())
        }

        static let state = State()
    }
}
