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
import FHIRClient
import HTTPClient
import IDP
import Pharmacy
import SwiftUI
import ZXingObjC

enum PrescriptionDetailDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case cancelMatrixCodeGeneration
        case deleteErxTask
        case saveErxTask
    }

    // sourcery: CodedError = "016"
    enum LoadingImageError: Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case matrixCodeGenerationFailed
    }

    enum Route: Equatable {
        case alert(AlertState<Action>)
        case pharmacySearch(PharmacySearchDomain.State)
        case sharePrescription(URL)
        case directAssignment

        var tag: Tag {
            switch self {
            case .alert:
                return .alert
            case .pharmacySearch:
                return .pharmacySearch
            case .sharePrescription:
                return .sharePrescription
            case .directAssignment:
                return .directAssignment
            }
        }

        enum Tag: Int {
            case alert
            case pharmacySearch
            case sharePrescription
            case directAssignment
        }
    }

    struct State: Equatable {
        var prescription: GroupedPrescription.Prescription
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var isArchived: Bool
        var isDeleting = false
        var isSubstitutionReadMorePresented = false

        var userActivity: NSUserActivity?

        var route: Route?

        func createReportEmail(body: String) -> URL? {
            var urlString = URLComponents(string: "mailto:app-feedback@gematik.de")
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "subject", value: "Fehlerreport iOS App"))
            queryItems.append(URLQueryItem(name: "body", value: body))

            urlString?.queryItems = queryItems

            return urlString?.url
        }
    }

    enum Action: Equatable {
        /// Closes the details page
        case close
        /// starts generation of data matrix code
        case loadMatrixCodeImage(screenSize: CGSize)
        /// When a new data matrix code was generated
        case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
        /// Initial delete action
        case delete
        /// User has confirmed to delete task
        case confirmedDelete
        /// When user chooses to not delete
        case taskDeletedReceived(Result<Bool, ErxRepositoryError>)
        /// Responds after save
        case redeemedOnSavedReceived(Bool)
        /// Toggle medication redeem state
        case toggleRedeemPrescription
        /// Open substitution info
        case openSubstitutionInfo
        /// Dismiss substitution info
        case dismissSubstitutionInfo
        /// Show pharmacy search view
        case showPharmacySearch
        /// Child view actions for the `PharmacySearch`
        case pharmacySearch(action: PharmacySearchDomain.Action)

        case showDirectAssignment
        case errorBannerButtonPressed
        case openEmailClient(body: String)

        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        let schedulers: Schedulers
        let taskRepository: ErxTaskRepository
        let matrixCodeGenerator = DefaultErxTaskMatrixCodeGenerator(matrixCodeGenerator: ZXDataMatrixWriter())
        let fhirDateFormatter: FHIRDateFormatter
        let pharmacyRepository: PharmacyRepository
        let userSession: UserSession

        var dateProvider: (() -> Date) = Date.init
    }

    static let domainReducer = Reducer { state, action, environment in

        switch action {
        case .close:
            // Note: successful deletion is handled in parent reducer!
            return cleanup()

        // Matrix Code
        case let .loadMatrixCodeImage(screenSize):
            state.userActivity = environment.updateActivity(with: state.prescription.erxTask)

            return environment.matrixCodeGenerator.publishedMatrixCode(
                for: [state.prescription.erxTask],
                with: environment.calcMatrixCodeSize(screenSize: screenSize)
            )
            .mapError { _ in
                LoadingImageError.matrixCodeGenerationFailed
            }
            .catchToLoadingStateEffect()
            .map(PrescriptionDetailDomain.Action.matrixCodeImageReceived)
            .cancellable(id: Token.cancelMatrixCodeGeneration, cancelInFlight: true)
            .receive(on: environment.schedulers.main)
            .eraseToEffect()

        case let .matrixCodeImageReceived(loadingState):
            state.loadingState = loadingState
            return .none

        // Delete
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .delete:
            state.route = .alert(confirmDeleteAlertState)
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .confirmedDelete:
            state.route = nil
            state.isDeleting = true
            return environment.taskRepository.delete(erxTasks: [state.prescription.erxTask])
                .first()
                .receive(on: environment.schedulers.main)
                .catchToEffect()
                .map(Action.taskDeletedReceived)
                .cancellable(id: Token.deleteErxTask)
        case let .taskDeletedReceived(.failure(fail)):
            state.isDeleting = false
            if fail == .remote(.fhirClientError(IDPError.tokenUnavailable)) {
                state.route = .alert(missingTokenAlertState())
            } else if case let ErxRepositoryError.remote(error) = fail,
                      let outcome = error.fhirClientOperationOutcome {
                state.route = .alert(deleteFailedAlertState(outcome))
            } else {
                state.route = .alert(deleteFailedAlertState(L10n.dtlTxtDeleteFallbackMessage.text))
            }
            return cleanup()
        case let .taskDeletedReceived(.success(success)):
            state.isDeleting = false
            if success {
                return Effect(value: .close)
            }
            return .none

        // Redeem
        case .toggleRedeemPrescription:
            state.isArchived.toggle()
            var erxTask = state.prescription.erxTask
            if state.isArchived {
                let redeemedOn = environment.fhirDateFormatter.stringWithLongUTCTimeZone(
                    from: environment.dateProvider()
                )
                erxTask.update(with: redeemedOn)
            } else {
                erxTask.update(with: nil)
            }
            state.prescription = GroupedPrescription.Prescription(erxTask: erxTask)
            return environment.saveErxTasks(erxTasks: [erxTask])
        case let .redeemedOnSavedReceived(success):
            if !success {
                state.isArchived.toggle()
            }
            return .none
        case .openSubstitutionInfo:
            state.isSubstitutionReadMorePresented = true
            return .none
        case .dismissSubstitutionInfo:
            state.isSubstitutionReadMorePresented = false
            return .none

        // Pharmacy
        case .showPharmacySearch:
            state.route = .pharmacySearch(.init(
                erxTasks: [state.prescription.erxTask],
                pharmacies: []
            ))
            return .none
        case .pharmacySearch(action: .close):
            state.route = nil
            return PharmacySearchDomain.cleanup()
        case .pharmacySearch(action:):
            return .none
        case .errorBannerButtonPressed:
            return .init(value: .openEmailClient(body: state.prescription.errorString))
        case let .openEmailClient(body):
            state.route = nil
            guard let email = state.createReportEmail(body: body) else { return .none }
            if UIApplication.shared.canOpenURL(email) {
                UIApplication.shared.open(email)
            }
            return .none

        case .setNavigation(tag: .sharePrescription):
            guard let url = state.prescription.erxTask.shareUrl() else { return .none }

            state.route = .sharePrescription(url)
            return .none
        case .setNavigation(tag: nil):
            state.route = nil
            return .none
        case .setNavigation:
            return .none
        case .showDirectAssignment:
            state.route = .directAssignment
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacySearchPullbackReducer,
        domainReducer
    )

    static let pharmacySearchPullbackReducer: Reducer =
        PharmacySearchDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.pharmacySearch),
            action: /PrescriptionDetailDomain.Action.pharmacySearch(action:)
        ) { environment in
            PharmacySearchDomain.Environment(
                schedulers: environment.schedulers,
                pharmacyRepository: environment.pharmacyRepository,
                fhirDateFormatter: environment.fhirDateFormatter,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: nil,
                userSession: environment.userSession
            )
        }

    static var confirmDeleteAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.dtlTxtDeleteAlertTitle),
            message: TextState(L10n.dtlTxtDeleteAlertMessage),
            primaryButton: .destructive(TextState(L10n.dtlTxtDeleteYes), action: .send(.confirmedDelete)),
            secondaryButton: .cancel(TextState(L10n.dtlTxtDeleteNo), action: .send(.setNavigation(tag: nil)))
        )
    }()

    static func deleteFailedAlertState(_ localizedError: String) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.dtlTxtDeleteMissingTokenAlertTitle),
            message: TextState(localizedError),
            primaryButton: .default(TextState(L10n.prscFdBtnErrorBanner),
                                    action: .send(.openEmailClient(body: localizedError))),
            secondaryButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }

    static func missingTokenAlertState() -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.dtlTxtDeleteMissingTokenAlertTitle),
            message: TextState(L10n.dtlTxtDeleteMissingTokenAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }
}

extension RemoteStoreError {
    var fhirClientOperationOutcome: String? {
        guard case let .fhirClientError(error) = self,
              let fhirClientError = error as? FHIRClient.Error,
              case let .operationOutcome(outcome) = fhirClientError else {
            return nil
        }
        return outcome.issue.first?.details?.text?.value?.string
    }
}

extension PrescriptionDetailDomain.Environment {
    // TODO: Same func is in RedeemMatrixCodeDomain. swiftlint:disable:this todo
    // Maybe find a way to have only one implementation!
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func saveErxTasks(erxTasks: [ErxTask])
        -> Effect<PrescriptionDetailDomain.Action, Never> {
        taskRepository.save(erxTasks: erxTasks)
            .first()
            .receive(on: schedulers.main.animation())
            .replaceError(with: false)
            .map(PrescriptionDetailDomain.Action.redeemedOnSavedReceived)
            .eraseToEffect()
            .cancellable(id: PrescriptionDetailDomain.Token.saveErxTask)
    }
}

extension ErxTask {
    func shareUrl() -> URL? {
        let sharedTask = SharedTask(with: self)
        guard let encoded = try? JSONEncoder().encode([sharedTask]),
              var urlComponents = URLComponents(string: "https://das-e-rezept-fuer-deutschland.de/prescription") else {
            return nil
        }
        urlComponents.fragment = String(data: encoded, encoding: .utf8)

        return urlComponents.url
    }
}

extension PrescriptionDetailDomain.Environment {
    func updateActivity(with task: ErxTask) -> NSUserActivity? {
        guard let url = task.shareUrl() else {
            return nil
        }

        let activity = NSUserActivity(activityType: "de.gematik.erp4ios.eRezept.Share")
        activity.title = "Share with other stuff"
        activity.isEligibleForHandoff = true
        activity.webpageURL = url
        activity.becomeCurrent()

        return activity
    }
}

extension PrescriptionDetailDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State(
            prescription: GroupedPrescription.Prescription.Dummies.prescriptionReady,
            isArchived: false
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            taskRepository: demoSessionContainer.userSession.erxTaskRepository,
            fhirDateFormatter: FHIRDateFormatter.shared,
            pharmacyRepository: DummySessionContainer().pharmacyRepository,
            userSession: DummySessionContainer()
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PrescriptionDetailDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
