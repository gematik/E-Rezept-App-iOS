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

import AVS
import Combine
import ComposableArchitecture
import eRpKit
import FHIRClient
import HTTPClient
import IdentifiedCollections
import IDP
import MapKit
import OpenSSL
import Pharmacy
import SwiftUI

struct PharmacyRedeemDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        Effect.concatenate(
            cleanupSubDomains(),
            Effect.cancel(id: PharmacyRedeemDomain.Token.self)
        )
    }

    static func cleanupSubDomains<T>() -> Effect<T, Never> {
        Effect.concatenate(
            PharmacyContactDomain.cleanup(),
            CardWallIntroductionDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case shipmentInfoStore
        case profileUpdates
        case redeem
        case savePharmacy
    }

    struct State: Equatable {
        var redeemOption: RedeemOption
        var erxTasks: [ErxTask]
        var pharmacy: PharmacyLocation
        var selectedErxTasks: Set<ErxTask> = []
        var orderResponses: IdentifiedArrayOf<OrderResponse> = []
        var selectedShipmentInfo: ShipmentInfo?
        var profile: Profile?
        var destination: Destinations.State?
    }

    enum Action: Equatable {
        /// Register observing `ShipmentInfo`
        case registerSelectedShipmentInfoListener
        /// Called when any shipment info has changed
        case selectedShipmentInfoReceived(Result<ShipmentInfo?, LocalStoreError>)
        /// Register selected profile listener
        case registerSelectedProfileListener
        /// Called when the selected profile changes
        case selectedProfileReceived(Result<Profile, LocalStoreError>)
        /// Redeem the selected prescriptions
        case redeem
        /// Called when redeem network call finishes
        case redeemReceived(Result<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)
        /// Called when a prescription has been selected or deselected
        case didSelect(String)
        /// Actions for subdomains and navigation
        case destination(Destinations.Action)
        case setNavigation(tag: Destinations.State.Tag?)
        /// Closes action used by parent domains to close the entire navigation stack
        case close
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.shipmentInfoDataStore) var shipmentInfoStore: ShipmentInfoDataStore
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.redeemInputValidator) var inputValidator: RedeemInputValidator
    @Dependency(\.redeemService) var redeemService: RedeemService
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                PharmacyRedeemDomain.Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerSelectedShipmentInfoListener:
            return shipmentInfoStore.selectedShipmentInfo
                .catchToEffect()
                .map(Action.selectedShipmentInfoReceived)
                .cancellable(id: Token.shipmentInfoStore, cancelInFlight: true)
                .receive(on: schedulers.main)
                .eraseToEffect()
        case let .selectedShipmentInfoReceived(result):
            if case let .success(shipmentInfo) = result, let selectedShipmentInfo = shipmentInfo {
                state.selectedShipmentInfo = selectedShipmentInfo
            } else {
                state.selectedShipmentInfo = state.erxTasks.compactMap { $0.patient?.shipmentInfo() }.first
            }
            return .none
        case .registerSelectedProfileListener:
            return userSession.profile()
                .catchToEffect()
                .map(Action.selectedProfileReceived)
                .cancellable(id: Token.profileUpdates, cancelInFlight: true)
                .receive(on: schedulers.main)
                .eraseToEffect()
        case .selectedProfileReceived(.failure):
            return .none
        case let .selectedProfileReceived(.success(profile)):
            state.profile = profile
            return .none
        case .redeem:
            state.orderResponses = []
            guard !state.selectedErxTasks.isEmpty else {
                return .none
            }

            if case let .invalid(error) = inputValidator
                .validate(state.selectedShipmentInfo, for: state.redeemOption) {
                state.destination = .alert(.info(AlertStates.missingContactInfo(with: error)))
                return .none
            }
            return redeem(orders: state.orders)
                .cancellable(id: Token.redeem, cancelInFlight: true)
        case let .redeemReceived(.success(orderResponses)):
            state.orderResponses = orderResponses
            if orderResponses.arePartiallySuccessful || orderResponses.areFailing {
                state.destination = .alert(.info(AlertStates.failingRequest(count: orderResponses.failedCount)))
            } else if orderResponses.areSuccessful {
                state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: state.redeemOption))
            }
            return save(pharmacy: state.pharmacy)
                .cancellable(id: Token.savePharmacy, cancelInFlight: true)
                .fireAndForget()
        case let .redeemReceived(.failure(error)):
            state.destination = .alert(.init(for: error))
            return save(pharmacy: state.pharmacy)
                .cancellable(id: Token.savePharmacy, cancelInFlight: true)
                .fireAndForget()
        case let .didSelect(taskID):
            if let erxTask = state.erxTasks.first(where: { $0.id == taskID }) {
                if state.selectedErxTasks.contains(erxTask) {
                    state.selectedErxTasks.remove(erxTask)
                } else {
                    state.selectedErxTasks.insert(erxTask)
                }
            }
            return .none
        case let .destination(.redeemSuccessView(action: .delegate(action))):
            switch action {
            case .close:
                state.destination = nil
                return Effect(value: .close)
            }
        case let .destination(.pharmacyContact(.delegate(action))):
            switch action {
            case .close:
                state.destination = nil
                return Self.cleanupSubDomains()
            }
        case .destination(.cardWall(.delegate(.close))):
            state.destination = nil
            return Self.cleanupSubDomains()
        case let .setNavigation(tag: tag):
            switch tag {
            case .contact:
                state.destination = .contact(
                    .init(shipmentInfo: state.selectedShipmentInfo, service: inputValidator.service)
                )
            case .redeemSuccess:
                state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: state.redeemOption))
            case .cardWall:
                state.destination = .cardWall(CardWallIntroductionDomain.State(
                    isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                    profileId: userSession.profileId
                ))
            case .alert: break
            case .none: state.destination = nil
            }
            return .none
        case .close:
            state.destination = nil
            // closing is handled in parent reducer
            return Self.cleanupSubDomains()
        case .destination:
            return .none
        }
    }
}

extension PharmacyRedeemDomain {
    enum AlertStates {
        static func alert(for error: RedeemServiceError) -> AlertState<Action> {
            guard let message = error.recoverySuggestion else {
                return AlertState(
                    title: TextState(error.localizedDescriptionWithErrorList),
                    dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: .none)))
                )
            }
            return AlertState(
                title: TextState(error.localizedDescriptionWithErrorList),
                message: TextState(message),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func missingContactInfo(with localizedMessage: String) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.phaRedeemAlertTitleMissingPhone),
                message: TextState(localizedMessage),
                primaryButton: .default(
                    TextState(L10n.phaRedeemBtnAlertComplete),
                    action: .send(.setNavigation(tag: .contact))
                ),
                secondaryButton: .cancel(
                    TextState(L10n.phaRedeemBtnAlertCancel),
                    action: .send(.setNavigation(tag: .none))
                )
            )
        }

        static func failingRequest(count: Int) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.phaRedeemAlertTitleFailure(count)),
                message: TextState(L10n.phaRedeemAlertMessageFailure),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: .none)))
            )
        }
    }
}

extension PharmacyRedeemDomain.State {
    var orders: [Order] {
        let orderId = UUID()
        return selectedErxTasks.asOrders(orderId: orderId, redeemOption, for: pharmacy, with: selectedShipmentInfo)
    }
}

extension PharmacyRedeemDomain {
    func redeem(
        orders: [Order]
    ) -> Effect<PharmacyRedeemDomain.Action, Never> {
        redeemService.redeem(orders) // -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>
            .receive(on: schedulers.main.animation())
            .map { orderResponses -> PharmacyRedeemDomain.Action in
                PharmacyRedeemDomain.Action.redeemReceived(.success(orderResponses))
            }
            .catch { redeemError -> Effect<PharmacyRedeemDomain.Action, Never> in
                if redeemError == .noTokenAvailable {
                    return Effect(value: PharmacyRedeemDomain.Action.setNavigation(tag: .cardWall))
                } else {
                    return Effect(value: PharmacyRedeemDomain.Action.redeemReceived(.failure(redeemError)))
                }
            }
            .eraseToEffect()
    }

    func save(pharmacy: PharmacyLocation) -> Effect<Bool, PharmacyRepositoryError> {
        var pharmacy = pharmacy
        pharmacy.lastUsed = Date()
        pharmacy.countUsage += 1
        return pharmacyRepository.save(pharmacy: pharmacy)
            .first()
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension ErxPatient {
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

        static let store = Store(initialState: state,
                                 reducer: PharmacyRedeemDomain())
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state, reducer: PharmacyRedeemDomain())
        }
    }
}
