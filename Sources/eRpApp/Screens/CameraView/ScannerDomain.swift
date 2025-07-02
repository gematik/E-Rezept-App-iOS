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
import eRpKit
import Foundation
import UIKit
import Vision

@Reducer
struct ImageGallery {}

@Reducer
struct ScannerDomain {
    typealias Store = StoreOf<Self>

    private enum CancelID {
        case saveErxTasks
        case loadErxTask
        case resetScanState
    }

    @ObservableState
    struct State: Equatable {
        /// Presents the current state of the scanning process. Errors are displayed as hints
        var scanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .idle
        /// Array of all accepted tasks which are ready for saving
        var acceptedTaskBatches = Set<[ScannedErxTask]>()
        /// Bool to handle the flashlight state
        var isFlashOn = false

        @Presents var destination: Destination.State?
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
        /// Toggles the flashlight
        case toggleFlashLight
        /// set isFlashOn to false
        case flashLightOff
        /// Opens an action sheet with options to open photo or document files
        case importButtonTapped

        case destination(PresentationAction<Destination.Action>)
        case resetNavigation
        case response(Response)

        enum Response: Equatable {
            /// Called if an error during save occurs
            case saveAndCloseReceived(Result<Bool, ErxRepositoryError>)
            /// Mutates the `scanState` after successful scan
            /// and calls `resetScannerState` after `messageInterval` passed
            case analyseReceived(LoadingState<[ScannedErxTask], ScannerDomain.Error>)

            case galleryImageReceived(UIImage?)
            case documentFileReceived(Result<[URL], Error>)
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = scanner_imageGallery
        case imageGallery(ImageGallery)
        // sourcery: AnalyticsScreen = scanner_documentImporter
        case documentImporter
        /// Used to present an alert
        @ReducerCaseEphemeral
        case alert(AlertState<Alert>)
        /// Present confirmation dialog
        case sheet(ConfirmationDialogState<Sheet>)

        enum Alert: Equatable {
            case closeAlertCancel
        }

        enum Sheet: Equatable {
            /// Opens the native image gallery
            case openImageGallery
            /// Opens the native document importer
            case openDocumentImporter
        }
    }

    var messageInterval: DispatchQueue.SchedulerTimeType.Stride = 2.0

    @Dependency(\.erxTaskRepository) var repository: ErxTaskRepository
    @Dependency(\.fhirDateFormatter) var dateFormatter: FHIRDateFormatter
    @Dependency(\.schedulers) var scheduler: Schedulers
    @Dependency(\.barcodeDetection) var barcodeDetection: BarcodeDetection
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.router) var router

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .saveAndClose(scannedBatches):
                let authoredOn = dateFormatter.stringWithLongUTCTimeZone(from: Date())
                let erxTasks = scannedBatches.flatMap { $0 }.asErxTasks(status: .ready, with: authoredOn)

                return .publisher(
                    repository.save(erxTasks: erxTasks)
                        .first()
                        .receive(on: scheduler.main)
                        .map { .response(.saveAndCloseReceived(.success($0))) }
                        .catch { error in
                            Just(Action.response(.saveAndCloseReceived(.failure(error))))
                        }
                        .eraseToAnyPublisher
                )
                .cancellable(id: CancelID.saveErxTasks)
            case .response(.saveAndCloseReceived(.failure)):
                state.destination = .alert(Self.savingAlertState)
                return .none
            case .response(.saveAndCloseReceived(.success)):
                return .run { _ in await dismiss() }
            case let .analyse(scanOutput):
                state.scanState = .loading(nil)
                do {
                    // [REQ:BSI-eRp-ePA:O.Source_1#2] analyse the input
                    let result = try CodeAnalyser.analyse(scanOutput: scanOutput, with: state.acceptedTaskBatches)
                    switch result {
                    case let .tasks(scannedTasks):
                        return checkForTaskDuplicatesInStore(scannedTasks)
                            .cancellable(id: CancelID.loadErxTask)
                    case let .url(universalLink):
                        return .run { _ in
                            @Dependency(\.dismiss) var dismiss

                            await dismiss()

                            await router.routeTo(.universalLink(universalLink))
                        }
                    }
                } catch let error as ScannerDomain.Error {
                    return Effect.send(.response(.analyseReceived(.error(error))))
                } catch let error as ScannedErxTask.Error {
                    return Effect.send(.response(.analyseReceived(.error(.scannedErxTask(error)))))
                } catch {
                    return Effect.send(.response(.analyseReceived(.error(.unknown))))
                }
            case let .response(.analyseReceived(loadingState)):
                if case let .value(scannedErxTask) = loadingState {
                    state.acceptedTaskBatches.insert(scannedErxTask)
                }
                state.scanState = loadingState
                return .run { send in
                    try await scheduler.main.sleep(for: messageInterval)
                    await send(.resetScannerState)
                }
                .cancellable(id: CancelID.resetScanState)
            case .resetScannerState:
                state.scanState = .idle
                return .none
            case .destination(.presented(.alert(.closeAlertCancel))):
                return .run { _ in await dismiss() }
            case .closeWithoutSave:
                if state.acceptedTaskBatches.isEmpty {
                    return .run { _ in await dismiss() }
                } else {
                    state.destination = .alert(Self.closeAlertState)
                    return .none
                }
            case .toggleFlashLight:
                state.isFlashOn.toggle()
                return .none
            case .flashLightOff:
                state.isFlashOn = false
                return .none
            case .importButtonTapped:
                state.destination = .sheet(Self.confirmationDialogState)
                return .none
            case .destination(.presented(.sheet(.openImageGallery))):
                state.destination = .imageGallery(.init())
                return .none
            case .destination(.presented(.sheet(.openDocumentImporter))):
                state.destination = .documentImporter
                return .none
            case let .response(.galleryImageReceived(image)):
                guard let image else { return .none }
                return .run { send in
                    await send(.analyse(scanOutput: try await barcodeDetection.detectImage(image)))
                }
            case let .response(.documentFileReceived(.success(result))):
                guard let documentURL = result.first else {
                    return .none
                }
                return .run { send in
                    await send(.analyse(scanOutput: try await barcodeDetection.detectDocument(documentURL)))
                }
            case .response(.documentFileReceived(.failure)):
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    static let closeAlertState: AlertState<Destination.Alert> = {
        AlertState {
            TextState(L10n.camTxtWarnCancelTitle)
        } actions: {
            ButtonState(role: .destructive, action: .send(.closeAlertCancel)) {
                TextState(L10n.camTxtWarnContinue)
            }
            ButtonState(role: .cancel, action: .send(.none)) {
                TextState(L10n.camTxtWarnCancel)
            }
        }
    }()

    static let savingAlertState: AlertState<Destination.Alert> = {
        AlertState {
            TextState(L10n.alertErrorTitle)
        } actions: {
            ButtonState(role: .cancel, action: .send(.none)) {
                TextState(L10n.alertBtnOk)
            }
        } message: {
            TextState(L10n.scnMsgSavingError)
        }
    }()

    static let confirmationDialogState: ConfirmationDialogState<Destination.Sheet> = {
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
                ButtonState(role: .cancel, action: .send(.none)) {
                    TextState(L10n.camBtnGallerySheetCancel)
                }
            }
        )
    }()
}

extension ScannerDomain {
    func checkForTaskDuplicatesInStore(_ scannedTasks: [ScannedErxTask]) -> Effect<ScannerDomain.Action> {
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

        return .publisher(
            Publishers.MergeMany(findPublishers)
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
                .eraseToAnyPublisher
        )
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
                flowType: ErxTask.FlowType(taskId: scannedTask.id),
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
        static let store = Store(initialState: Dummies.state) { ScannerDomain() }

        static func store(with state: State) -> StoreOf<ScannerDomain> {
            Store(initialState: state) {
                ScannerDomain()
            }
        }

        static let state = State()
    }
}
