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
import UIKit
import Vision

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

        var galleryActionSheet: ConfirmationDialogState<Action>?

        var destination: Destinations.State?
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
        /// Opens an action sheet with options to open photo or document files
        case importButtonTapped
        /// Opens the nativ image gallery
        case openImageGallery
        /// Opens the nativ document importer
        case openDocumentImporter

        case closeImportActionSheet

        case destination(Destinations.Action)
        case setNavigation(tag: Destinations.State.Tag?)
        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            /// Called if an error during save occurs
            case saveAndCloseReceived(ErxRepositoryError)
            /// Mutates the `scanState` after successful scan
            /// and calls `resetScannerState` after `messageInterval` passed
            case analyseReceived(LoadingState<[ScannedErxTask], ScannerDomain.Error>)

            case galleryImageReceived(UIImage?)
            case documentFileReceived(Result<[URL], Error>)
        }

        enum Delegate: Equatable {
            /// Closes the scanner view
            case close
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = scanner_imageGallery
            case imageGallery
            // sourcery: AnalyticsScreen = scanner_documentImporter
            case documentImporter
        }

        enum Action: Equatable {}

        var body: some ReducerProtocolOf<Self> {
            EmptyReducer()
        }
    }

    var messageInterval: DispatchQueue.SchedulerTimeType.Stride = 2.0

    @Dependency(\.erxTaskRepository) var repository: ErxTaskRepository
    @Dependency(\.fhirDateFormatter) var dateFormatter: FHIRDateFormatter
    @Dependency(\.schedulers) var scheduler: Schedulers
    @Dependency(\.barcodeDetection) var barcodeDetection: BarcodeDetection

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
                // [REQ:BSI-eRp-ePA:O.Source_1#2] analyse the input
                let scannedTasks = try CodeAnalyser.analyse(scanOutput: scanOutput, with: state.acceptedTaskBatches)
                return checkForTaskDuplicatesInStore(scannedTasks)
                    .cancellable(id: Token.loadErxTask)
            } catch let error as ScannerDomain.Error {
                return EffectTask(value: .response(.analyseReceived(.error(error))))
            } catch let error as ScannedErxTask.Error {
                return EffectTask(value: .response(.analyseReceived(.error(.scannedErxTask(error)))))
            } catch {
                return EffectTask(value: .response(.analyseReceived(.error(.unknown))))
            }
        case let .response(.analyseReceived(loadingState)):
            if case let .value(scannedErxTask) = loadingState {
                state.acceptedTaskBatches.insert(scannedErxTask)
            }
            state.scanState = loadingState
            return EffectTask(value: .resetScannerState)
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
            return EffectTask(value: .delegate(.close))
        case .closeWithoutSave:
            if state.acceptedTaskBatches.isEmpty {
                return EffectTask(value: .delegate(.close))
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
        case .importButtonTapped:
            state.galleryActionSheet = Self.confirmationDialogState
            return .none
        case .openImageGallery:
            state.destination = .imageGallery
            return .none
        case .openDocumentImporter:
            state.destination = .documentImporter
            return .none
        case .closeImportActionSheet:
            state.galleryActionSheet = nil
            return .none
        case let .response(.galleryImageReceived(image)):
            guard let image else { return .none }
            return .task {
                .analyse(scanOutput:
                    try await barcodeDetection.detectImage(image))
            }
        case let .response(.documentFileReceived(.success(result))):
            guard let documentURL = result.first else {
                return .none
            }
            return .task {
                .analyse(scanOutput: try await barcodeDetection.detectDocument(documentURL))
            }
        case .response(.documentFileReceived(.failure)):
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .delegate:
            return .none
        case .destination,
             .setNavigation:
            return .none
        }
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    static let closeAlertState: AlertState<Action> = {
        AlertState {
            TextState(L10n.camTxtWarnCancelTitle)
        } actions: {
            ButtonState(role: .destructive, action: .send(.closeAlertCancelButtonTapped)) {
                TextState(L10n.camTxtWarnContinue)
            }
            ButtonState(role: .cancel, action: .send(.none)) {
                TextState(L10n.camTxtWarnCancel)
            }
        }
    }()

    static let savingAlertState: AlertState<Action> = {
        AlertState {
            TextState(L10n.alertErrorTitle)
        } actions: {
            ButtonState(role: .cancel, action: .send(.alertDismissButtonTapped)) {
                TextState(L10n.alertBtnOk)
            }
        } message: {
            TextState(L10n.scnMsgSavingError)
        }
    }()

    static let confirmationDialogState: ConfirmationDialogState<Action> = {
        ConfirmationDialogState(
            titleVisibility: .visible,
            title: {
                TextState(L10n.camTxtGallerySheetTitle)
            }, actions: {
                ButtonState(action: .send(.openImageGallery)) {
                    TextState(L10n.camBtnGallerySheetPicture)
                }
                ButtonState(action: .send(.openDocumentImporter)) {
                    TextState(L10n.camBtnGallerySheetDocument)
                }
                ButtonState(role: .cancel, action: .send(.closeImportActionSheet)) {
                    TextState(L10n.camBtnGallerySheetCancel)
                }
            }
        )
    }()
}

extension ScannerDomain {
    func checkForTaskDuplicatesInStore(_ scannedTasks: [ScannedErxTask]) -> EffectTask<ScannerDomain.Action> {
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
