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
import MapKit
import Pharmacy
import SwiftUI

enum PharmacyRedeemDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: PharmacyRedeemDomain.Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case shipmentInfoStore
        case profileUpdates
    }

    struct State: Equatable {
        var redeemOption: RedeemOption
        var erxTasks: [ErxTask]
        var pharmacy: PharmacyLocation
        var selectedErxTasks: Set<ErxTask> = []
        var loadingState: LoadingState<Bool, ErxRepositoryError> = .idle
        var alertState: AlertState<Action>?
        var successViewState: RedeemSuccessDomain.State?
        var selectedShipmentInfo: ShipmentInfo?
        var profile: Profile?
        var pharmacyContactState: PharmacyContactDomain.State?
    }

    enum Action: Equatable {
        /// Register observing `ShipmentInfo`
        case registerSelectedShipmentInfoListener
        /// Called when any shipment info has changed
        case selectedShipmentInfoReceived(Result<ShipmentInfo?, LocalStoreError>)
        /// Register selected profile listener
        case registerSelectedProfileListener
        case selectedProfileReceived(Result<Profile, LocalStoreError>)
        /// Closes the details page
        case close
        /// Redeem the selected prescriptions
        case redeem
        /// Called when redeem network call finishes
        case redeemReceived(LoadingState<Bool, ErxRepositoryError>)
        /// Called when a prescription has been selected
        case didSelect(String)
        case alertDismissButtonTapped
        case alertShowPharmacyContactButtonTapped
        case redeemSuccessView(action: RedeemSuccessDomain.Action)
        case dismissRedeemSuccessView
        /// Called when contact has deen selected
        case showPharmacyContact
        case pharmacyContact(action: PharmacyContactDomain.Action)
        case dismissPharmacyContactView
    }

    struct Environment {
        var schedulers: Schedulers
        var userSession: UserSession
        var erxTaskRepository: ErxTaskRepository
        let shipmentInfoStore: ShipmentInfoDataStore
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerSelectedShipmentInfoListener:
            return environment.shipmentInfoStore.selectedShipmentInfo
                .catchToEffect()
                .map(Action.selectedShipmentInfoReceived)
                .cancellable(id: Token.shipmentInfoStore, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .selectedShipmentInfoReceived(.success(shipmentInfo)):
            if let selectedShipmentInfo = shipmentInfo {
                state.selectedShipmentInfo = selectedShipmentInfo
            } else {
                state.selectedShipmentInfo = state.erxTasks.compactMap { $0.patient?.shipmentInfo() }.first
            }
            return .none
        case .registerSelectedProfileListener:
            return environment.userSession.profile()
                .catchToEffect()
                .map(Action.selectedProfileReceived)
                .cancellable(id: Token.profileUpdates, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case .selectedProfileReceived(.failure):
            return .none
        case let .selectedProfileReceived(.success(profile)):
            state.profile = profile
            return .none
        case .selectedShipmentInfoReceived(.failure):
            state.selectedShipmentInfo = state.erxTasks.compactMap { $0.patient?.shipmentInfo() }.first
            return .none
        case .close:
            state.alertState = nil
            // closing is handled in parent reducer
            return cleanup()
        case .redeem:
            guard !state.selectedErxTasks.isEmpty else {
                return .none
            }
            state.loadingState = .loading()
            let orders = state.orders
            guard !orders.isEmpty else {
                state.alertState = missingPhoneState
                return .none
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
                    dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
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
        case .alertShowPharmacyContactButtonTapped:
            state.alertState = nil
            state.pharmacyContactState = .init(shipmentInfo: state.selectedShipmentInfo)
            return .none
        case .dismissRedeemSuccessView:
            state.successViewState = nil
            return .none
        case .redeemSuccessView(action: .close):
            state.successViewState = nil
            return Effect(value: .close)
        case .showPharmacyContact:
            state.pharmacyContactState = .init(shipmentInfo: state.selectedShipmentInfo)
            return .none
        case .pharmacyContact(.close),
             .dismissPharmacyContactView:
            state.pharmacyContactState = nil
            return .none
        case .pharmacyContact:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacyContactPullbackReducer,
        domainReducer
    )

    static let pharmacyContactPullbackReducer: Reducer =
        PharmacyContactDomain.reducer.optional().pullback(
            state: \.pharmacyContactState,
            action: /PharmacyRedeemDomain.Action.pharmacyContact(action:)
        ) { environment in
            PharmacyContactDomain.Environment(
                schedulers: environment.schedulers,
                shipmentInfoStore: environment.shipmentInfoStore
            )
        }

    static var loginAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.alertErrorTitle),
            message: TextState(L10n.phaRedeemTxtNotLoggedIn),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
    }()

    static var missingPhoneState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaRedeemAlertTitleMissingPhone),
            message: TextState(L10n.phaRedeemAlertMessageMissingPhone),
            primaryButton: .default(
                TextState(L10n.phaRedeemBtnAlertComplete),
                action: .send(.alertShowPharmacyContactButtonTapped)
            ),
            secondaryButton: .cancel(TextState(L10n.phaRedeemBtnAlertCancel), action: .send(.alertDismissButtonTapped))
        )
    }()
}

extension PharmacyRedeemDomain.State {
    var orders: [ErxTaskOrder] {
        if redeemOption.isPhoneRequired, selectedShipmentInfo?.phone == nil {
            return []
        }
        var address: [String] = []
        if let name = selectedShipmentInfo?.name {
            address.append(name)
        }
        if let street = selectedShipmentInfo?.street {
            address.append(street)
        }
        if let zip = selectedShipmentInfo?.zip {
            address.append(zip)
        }
        if let city = selectedShipmentInfo?.city {
            address.append(city)
        }
        if let detail = selectedShipmentInfo?.addressDetail {
            address.append(detail)
        }
        return selectedErxTasks.compactMap { task in
            let payload = ErxTaskOrder.Payload(
                supplyOptionsType: redeemOption,
                name: selectedShipmentInfo?.name ?? "",
                address: address,
                hint: selectedShipmentInfo?.deliveryInfo ?? "",
                phone: selectedShipmentInfo?.phone ?? ""
            )
            return ErxTaskOrder(
                erxTaskId: task.id,
                accessCode: task.accessCode ?? "",
                pharmacyTelematikId: pharmacy.telematikID,
                payload: payload
            )
        }
    }
}

extension PharmacyRedeemDomain.Environment {
    func redeem(orders: [ErxTaskOrder]) -> Effect<LoadingState<Bool, ErxRepositoryError>, Never> {
        userSession
            .isAuthenticated
            .mapError { ErxRepositoryError.local(.initialization(error: $0)) }
            .first()
            .flatMap { isAuthenticated -> AnyPublisher<Bool, ErxRepositoryError> in
                if isAuthenticated {
                    return erxTaskRepository.redeem(orders: orders)
                        .first()
                        .eraseToAnyPublisher()
                } else {
                    return Just(false)
                        .setFailureType(to: ErxRepositoryError.self)
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: schedulers.main.animation())
            .catchToLoadingStateEffect()
    }
}

extension ErxTask.Patient {
    func shipmentInfo(with identifier: UUID = UUID()) -> ShipmentInfo {
        guard let address = address else {
            return ShipmentInfo(name: name)
        }
        var street: String?
        var city: String?
        var zip: String?
        let splitAddress = address.split(separator: "\n")
        if splitAddress.count == 2 {
            street = String(splitAddress[0]).trimmed()
            let zipAndStreet = splitAddress[1].split(separator: " ")
            if zipAndStreet.count == 2 {
                zip = zipAndStreet[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                city = String(zipAndStreet[1]).trimmed()
            } else {
                city = String(splitAddress[1]).trimmed()
            }
        } else {
            street = String(address).trimmed()
        }

        return ShipmentInfo(identifier: identifier, name: name, street: street, zip: zip, city: city)
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
            redeemOption: .shipment,
            erxTasks: ErxTask.Dummies.erxTasks,
            pharmacy: pharmacy,
            selectedShipmentInfo: ShipmentInfo(
                name: "Marta Maquise",
                street: "Stahl und Holz Str.1",
                addressDetail: "Postfach 11222",
                zip: "12345",
                city: "Mozard",
                phone: "+117712345",
                mail: "marta@gematik.de",
                deliveryInfo: "Nicht im Treppenhaus oder bei Nachbarn abgeben"
            ),
            profile: Profile(name: "Marta Maquise")
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DemoSessionContainer(),
            erxTaskRepository: DemoSessionContainer().erxTaskRepository,
            shipmentInfoStore: DemoShipmentInfoStore()
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
