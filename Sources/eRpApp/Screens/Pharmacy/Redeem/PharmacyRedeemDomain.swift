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

import AVS
import Combine
import ComposableArchitecture
import eRpKit
import IdentifiedCollections
import MapKit
import OpenSSL
import Pharmacy
import SwiftUI

enum PharmacyRedeemDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.concatenate(
            PharmacyContactDomain.cleanup(),
            Effect.cancel(token: PharmacyRedeemDomain.Token.self)
        )
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
        var orderResponses: IdentifiedArrayOf<OrderResponse> = []
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
        case redeemReceived(Result<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)
        /// Called when a prescription has been selected
        case didSelect(String)
        case alertDismissButtonTapped
        case alertShowPharmacyContactButtonTapped
        case redeemSuccessView(action: RedeemSuccessDomain.Action)
        case dismissRedeemSuccessView
        /// Called when contact has been selected
        case showPharmacyContact
        case pharmacyContact(action: PharmacyContactDomain.Action)
        case dismissPharmacyContactView
    }

    struct Environment {
        var schedulers: Schedulers
        var userSession: UserSession
        let shipmentInfoStore: ShipmentInfoDataStore
        let redeemService: RedeemService
        let inputValidator: RedeemInputValidator
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
            state.orderResponses = []
            guard !state.selectedErxTasks.isEmpty else {
                return .none
            }

            if case let .invalid(error) = environment.inputValidator
                .validate(state.selectedShipmentInfo, for: state.redeemOption) {
                state.alertState = AlertStates.missingContactInfo(with: error)
                return .none
            }
            return environment.redeem(orders: state.orders)
                .map(Action.redeemReceived)
        case let .redeemReceived(.success(orderResponses)):
            state.orderResponses = orderResponses
            if orderResponses.arePartiallySuccessful || orderResponses.areFailing {
                state.alertState = AlertStates.failingRequest(count: orderResponses.failedCount)
                return .none
            } else if orderResponses.areSuccessful {
                state.successViewState = RedeemSuccessDomain.State(redeemOption: state.redeemOption)
            }
            return .none
        case let .redeemReceived(.failure(error)):
            state.alertState = AlertStates.alert(for: error)
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
            state.alertState = nil
            return .none
        case .alertShowPharmacyContactButtonTapped:
            state.alertState = nil
            state.pharmacyContactState = .init(
                shipmentInfo: state.selectedShipmentInfo,
                service: environment.inputValidator.service
            )
            return .none
        case .dismissRedeemSuccessView:
            state.successViewState = nil
            return .none
        case .redeemSuccessView(action: .close):
            state.successViewState = nil
            return Effect(value: .close)
        case .showPharmacyContact:
            state.pharmacyContactState = .init(
                shipmentInfo: state.selectedShipmentInfo,
                service: environment.inputValidator.service
            )
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
                shipmentInfoStore: environment.shipmentInfoStore,
                validator: environment.inputValidator
            )
        }
}

extension PharmacyRedeemDomain {
    enum AlertStates {
        static func alert(for error: RedeemServiceError) -> AlertState<Action> {
            guard let message = error.recoverySuggestion else {
                return AlertState(
                    title: TextState(error.localizedDescriptionWithErrorList),
                    dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
                )
            }
            return AlertState(
                title: TextState(error.localizedDescriptionWithErrorList),
                message: TextState(message),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
            )
        }

        static func missingContactInfo(with localizedMessage: String) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.phaRedeemAlertTitleMissingPhone),
                message: TextState(localizedMessage),
                primaryButton: .default(
                    TextState(L10n.phaRedeemBtnAlertComplete),
                    action: .send(.alertShowPharmacyContactButtonTapped)
                ),
                secondaryButton: .cancel(
                    TextState(L10n.phaRedeemBtnAlertCancel),
                    action: .send(.alertDismissButtonTapped)
                )
            )
        }

        static func failingRequest(count: Int) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.phaRedeemAlertTitleFailure(count)),
                message: TextState(L10n.phaRedeemAlertMessageFailure),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
            )
        }
    }
}

extension PharmacyRedeemDomain.State {
    var orders: [Order] {
        selectedErxTasks.map { task in
            let transactionId = UUID()
            return Order(
                redeemType: redeemOption,
                name: selectedShipmentInfo?.name,
                address: Address(
                    street: selectedShipmentInfo?.street,
                    zip: selectedShipmentInfo?.zip,
                    city: selectedShipmentInfo?.city
                ),
                hint: selectedShipmentInfo?.deliveryInfo,
                text: nil, // TODO: other ticket //swiftlint:disable:this todo
                phone: selectedShipmentInfo?.phone,
                mail: selectedShipmentInfo?.mail,
                transactionID: transactionId,
                taskID: task.id,
                accessCode: task.accessCode ?? "",
                endpoint: pharmacy.avsEndpoints?.url(
                    for: redeemOption,
                    transactionId: transactionId.uuidString,
                    telematikId: pharmacy.telematikID
                ),
                recipients: pharmacy.avsCertificates,
                telematikId: pharmacy.telematikID
            )
        }
    }
}

extension PharmacyRedeemDomain.Environment {
    func redeem(
        orders: [Order]
    ) -> Effect<Result<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>, Never> {
        redeemService.redeem(orders)
            .receive(on: schedulers.main.animation())
            .catchToEffect()
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

extension RedeemInputValidator {
    func validate(_ shipmentInfo: ShipmentInfo?, for redeemOption: RedeemOption) -> Validity {
        if isValid(name: shipmentInfo?.name) != .valid {
            return isValid(name: shipmentInfo?.name)
        }
        if isValid(street: shipmentInfo?.street) != .valid {
            return isValid(street: shipmentInfo?.street)
        }
        if isValid(zip: shipmentInfo?.zip) != .valid {
            return isValid(zip: shipmentInfo?.zip)
        }
        if isValid(city: shipmentInfo?.city) != .valid {
            return isValid(city: shipmentInfo?.city)
        }
        if isValid(hint: shipmentInfo?.deliveryInfo) != .valid {
            return isValid(hint: shipmentInfo?.deliveryInfo)
        }
        // TODO: Ticket ERA-5598 //swiftlint:disable:this todo
//        if isValid(text: shipmentInfo.text) != .valid {
//            return isValid(text: shipmentInfo.text)
//        }
        if isValid(phone: shipmentInfo?.phone) != .valid {
            return isValid(phone: shipmentInfo?.phone)
        }
        if isValid(mail: shipmentInfo?.mail) != .valid {
            return isValid(mail: shipmentInfo?.mail)
        }

        if ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: redeemOption,
            phone: shipmentInfo?.phone,
            mail: shipmentInfo?.mail
        ) != .valid {
            return ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                optionType: redeemOption,
                phone: shipmentInfo?.phone,
                mail: shipmentInfo?.mail
            )
        }
        return .valid
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
            erxTasks: ErxTask.Demo.erxTasks,
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
            userSession: DummySessionContainer(),
            shipmentInfoStore: DemoShipmentInfoStore(),
            redeemService: DemoRedeemService(),
            inputValidator: DemoRedeemInputValidator()
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
