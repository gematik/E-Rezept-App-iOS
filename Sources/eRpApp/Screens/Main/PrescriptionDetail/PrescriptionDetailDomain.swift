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
import IDP
import Pharmacy
import SwiftUI

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

    enum LoadingImageError: Error, Equatable, LocalizedError {
        case matrixCodeGenerationFailed
    }

    struct State: Equatable {
        var prescription: GroupedPrescription.Prescription
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var alertState: AlertState<Action>?
        var isArchived: Bool
        var isSubstitutionReadMorePresented = false
        // pharmacy state
        var pharmacySearchState: PharmacySearchDomain.State?

        var auditEventsLastUpdated: String? {
            prescription.auditEvents.first?.timestamp
        }

        var auditEventsErrorText: String? {
            prescription.auditEvents
                .isEmpty ? L10n.prscFdTxtProtocolDownloadError.text : nil
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
        case cancelDelete
        /// Response when deletion was executed
        case taskDeletedReceived(Result<Bool, ErxRepositoryError>)
        /// Sets the `alertState` back to nil (which hides the alert)
        case alertDismissButtonTapped
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
        /// Dismiss pharmacy search domain
        case dismissPharmacySearch
    }

    struct Environment {
        let schedulers: Schedulers
        let taskRepository: ErxTaskRepository
        let matrixCodeGenerator = DefaultErxTaskMatrixCodeGenerator()
        let fhirDateFormatter: FHIRDateFormatter
        let pharmacyRepository: PharmacyRepository
        let userSession: UserSession
    }

    static let domainReducer = Reducer { state, action, environment in

        switch action {
        case .close:
            // Note: successful deletion is handled in parent reducer!
            return cleanup()

        // Matrix Code
        case let .loadMatrixCodeImage(screenSize):
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

        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none

        // Delete
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .delete:
            state.alertState = confirmDeleteAlertState
            return .none
        case .cancelDelete:
            state.alertState = nil
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .confirmedDelete:
            state.alertState = nil
            return environment.taskRepository.delete(erxTasks: [state.prescription.erxTask])
                .first()
                .receive(on: environment.schedulers.main)
                .catchToEffect()
                .map(Action.taskDeletedReceived)
                .cancellable(id: Token.deleteErxTask)
        case let .taskDeletedReceived(.failure(fail)):
            if case ErxRepositoryError.local(.delete(IDPError.tokenUnavailable)) = fail {
                // Only show error message when token is not available
                state.alertState = deleteFailedAlertState(fail.localizedDescription)
            }
            return cleanup()
        case let .taskDeletedReceived(.success(success)):
            if success {
                return Effect(value: .close)
            }
            return .none

        // Redeem
        case .toggleRedeemPrescription:
            state.isArchived.toggle()
            var erxTask = state.prescription.erxTask
            if state.isArchived {
                let redeemedOn = environment.fhirDateFormatter.stringWithLongUTCTimeZone(from: Date())
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
            state.pharmacySearchState = PharmacySearchDomain.State(
                erxTasks: [state.prescription.erxTask],
                pharmacies: []
            )
            return .none
        case .dismissPharmacySearch, .pharmacySearch(action: .close):
            state.pharmacySearchState = nil
            return PharmacySearchDomain.cleanup()
        case .pharmacySearch(action:):
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacySearchPullbackReducer,
        domainReducer
    )

    static let pharmacySearchPullbackReducer: Reducer =
        PharmacySearchDomain.reducer.optional().pullback(
            state: \.pharmacySearchState,
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
            secondaryButton: .cancel(TextState(L10n.dtlTxtDeleteNo), action: .send(.cancelDelete))
        )
    }()

    static func deleteFailedAlertState(_: String) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.dtlTxtDeleteMissingTokenAlertTitle),
            message: TextState(L10n.dtlTxtDeleteMissingTokenAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
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
            .receive(on: schedulers.main)
            .replaceError(with: false)
            .map(PrescriptionDetailDomain.Action.redeemedOnSavedReceived)
            .eraseToEffect()
            .cancellable(id: PrescriptionDetailDomain.Token.saveErxTask)
    }
}

extension PrescriptionDetailDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State(
            prescription: GroupedPrescription.Prescription(erxTask: ErxTask.Dummies.erxTaskReady),
            isArchived: false
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            taskRepository: demoSessionContainer.userSession.erxTaskRepository,
            fhirDateFormatter: FHIRDateFormatter.shared,
            pharmacyRepository: DemoSessionContainer().pharmacyRepository,
            userSession: DemoSessionContainer()
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
