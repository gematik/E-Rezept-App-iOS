//
//  Copyright (c) 2021 gematik GmbH
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
import MapKit
import Pharmacy
import SwiftUI

enum PharmacyRedeemDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var redeemOption: RedeemOption
        var erxTasks: [ErxTask]
        var pharmacy: PharmacyLocation
        var selectedErxTasks: Set<ErxTask> = []
        var loadingState: LoadingState<Bool, ErxTaskRepositoryError> = .idle
        var alertState: AlertState<Action>?
        var successViewState: RedeemSuccessDomain.State?
    }

    enum Action: Equatable {
        /// Closes the details page
        case close
        case showRedeemAlert
        /// Redeem the selected prescriptions
        case redeem
        /// Called when redeem network call finishes
        case redeemReceived(LoadingState<Bool, ErxTaskRepositoryError>)
        /// Called when a prescription has been selected
        case didSelect(String)
        case alertDismissButtonTapped
        case redeemSuccessView(action: RedeemSuccessDomain.Action)
        case dismissRedeemSuccessView
    }

    struct Environment {
        var schedulers: Schedulers
        var userSession: UserSession
        var erxTaskRepository: ErxTaskRepositoryAccess
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case .close:
            state.alertState = nil
            // closing is handled in parent reducer
            return .none
        case .showRedeemAlert:
            state.alertState = askRedeemPermissionState
            return .none
        case .redeem:
            state.loadingState = .loading()
            let orders: [ErxTaskOrder] = state.selectedErxTasks.compactMap { task in
                guard let name = task.patient?.name,
                     let address = task.patient?.address,
                     let accessCode = task.accessCode
                     else { return nil }
                let payload = ErxTaskOrder.Payload(
                    supplyOptionsType: state.redeemOption,
                    name: name,
                    address: [address],
                    hint: "",
                    phone: task.patient?.phone ?? ""
                )
                return ErxTaskOrder(erxTaskId: task.id,
                                    accessCode: accessCode,
                                    pharmacyTelematikId: state.pharmacy.telematikID,
                                    payload: payload)
            }
            return environment.redeem(orders: orders)
                .map(Action.redeemReceived)
        case let .redeemReceived(loadingState):
            state.loadingState = loadingState
            if let isLoggedIn = loadingState.value, isLoggedIn == false {
                state.alertState = loginAlertState
                return .none
            }
            if let error = loadingState.error {
                state.alertState = AlertState(
                    title: TextState(L10n.alertErrorTitle),
                    message: TextState(error.localizedDescription),
                    dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
                )
                return .none
            }
            state.successViewState = RedeemSuccessDomain.State(redeemOption: state.redeemOption)
            return .none
        case let .didSelect(taskID):
            if let erxTask = state.erxTasks.first(where: { $0.id == taskID }) {
                if state.selectedErxTasks.contains(erxTask) {
                    state.selectedErxTasks.remove(erxTask)
                } else {
                    state.selectedErxTasks.insert(erxTask)
                }
            }
            return .none
        case .alertDismissButtonTapped:
            state.loadingState = .idle
            state.alertState = nil
            return .none
        case .dismissRedeemSuccessView:
            state.successViewState = nil
            return .none
        case .redeemSuccessView(action: .close):
            state.successViewState = nil
            return Effect(value: .close)
        }
    }

    static var loginAlertState: AlertState<Action> = {
            AlertState(
                title: TextState(L10n.alertErrorTitle),
                message: TextState(L10n.phaRedeemTxtNotLoggedIn),
                dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
            )
        }()

    static var askRedeemPermissionState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaRedeemTxtAlertTitle),
            message: TextState(L10n.phaRedeemTxtAlertMessage),
            primaryButton: .cancel(TextState(L10n.phaRedeemBtnAlertCancel), send: .alertDismissButtonTapped),
            secondaryButton: .default(TextState(L10n.phaRedeemBtnAlertApproval), send: .redeem)
        )
    }()
}

extension PharmacyRedeemDomain.Environment {
    func redeem(orders: [ErxTaskOrder]) -> Effect<LoadingState<Bool, ErxTaskRepositoryError>, Never> {
        userSession
            .isAuthenticated
            .mapError { ErxTaskRepositoryError.local(.initialization(error: $0)) }
            .first()
            .flatMap { isAuthenticated -> AnyPublisher<Bool, ErxTaskRepositoryError> in
                if isAuthenticated {
                  return erxTaskRepository.redeem(orders: orders)
                        .first()
                        .eraseToAnyPublisher()
                } else {
                    return Just(false)
                        .setFailureType(to: ErxTaskRepositoryError.self)
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: schedulers.main.animation())
            .catchToLoadingStateEffect()
    }
}

extension PharmacyRedeemDomain {
    enum Dummies {
        static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            houseNumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )

        static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )

        static let pharmacy = PharmacyLocation.Dummies.pharmacy

        static let state = State(
            redeemOption: .onPremise,
            erxTasks: ErxTask.Dummies.prescriptions,
            pharmacy: pharmacy
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DemoSessionContainer(),
            erxTaskRepository: DemoSessionContainer().erxTaskRepository
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PharmacyRedeemDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
