//
//  Copyright (c) 2024 gematik GmbH
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

@Reducer
struct PharmacyRedeemDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = redeem_success
        case redeemSuccess(RedeemSuccessDomain)
        // sourcery: AnalyticsScreen = redeem_editContactInformation
        case contact(PharmacyContactDomain)
        // sourcery: AnalyticsScreen = cardWall
        case cardWall(CardWallIntroductionDomain)
        // sourcery: AnalyticsScreen = redeem_prescriptionSelection
        case prescriptionSelection(PharmacyPrescriptionSelectionDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)

        enum Alert {
            case contact
            case closeRedeem
            case retryRedeem
        }
    }

    @ObservableState
    struct State: Equatable {
        var redeemOption: RedeemOption
        @Shared var prescriptions: [Prescription]
        var pharmacy: PharmacyLocation
        @Shared var selectedPrescriptions: Set<Prescription>
        var redeemInProgress = false
        var orderResponses: IdentifiedArrayOf<OrderResponse> = []
        var selectedShipmentInfo: ShipmentInfo?
        var profile: Profile?
        @Presents var destination: Destination.State?

        var orders: [OrderRequest] {
            selectedPrescriptions.map(\.erxTask)
                .asOrders(orderId: UUID(),
                          option: redeemOption,
                          for: pharmacy,
                          with: selectedShipmentInfo)
        }
    }

    enum Action: Equatable {
        case task
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
        /// Navigation actions
        case showContact
        case showRedeemSuccess
        case showCardWall
        case showPrescriptionSelection
        /// Actions for subdomains and navigation
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        case resetNavigation

        enum Delegate: Equatable {
            /// Close all
            case close
            /// Only closes the redeem view
            case closeRedeemView
            /// Save the current State when changing Pharmacy
            case changePharmacy(PharmacyRedeemDomain.State)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.shipmentInfoDataStore) var shipmentInfoStore: ShipmentInfoDataStore
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.redeemInputValidator) var inputValidator: RedeemInputValidator
    @Dependency(\.redeemService) var redeemService: RedeemService
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .send(.registerSelectedShipmentInfoListener),
                .send(.registerSelectedProfileListener)
            )
        case .registerSelectedShipmentInfoListener:
            return .publisher(
                shipmentInfoStore.selectedShipmentInfo
                    .catchToPublisher()
                    .map(Action.selectedShipmentInfoReceived)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .selectedShipmentInfoReceived(result):
            if case let .success(shipmentInfo) = result, let selectedShipmentInfo = shipmentInfo {
                state.selectedShipmentInfo = selectedShipmentInfo
            } else {
                state.selectedShipmentInfo = state.prescriptions.map(\.erxTask)
                    .compactMap { $0.patient?.shipmentInfo() }.first
            }
            return .none
        case .registerSelectedProfileListener:
            return .publisher(
                userSession.profile()
                    .catchToPublisher()
                    .map(Action.selectedProfileReceived)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case .selectedProfileReceived(.failure):
            return .none
        case let .selectedProfileReceived(.success(profile)):
            state.profile = profile
            return .none
        case .redeem,
             .destination(.presented(.alert(.retryRedeem))):
            state.orderResponses = []
            guard !state.selectedPrescriptions.isEmpty, !state.redeemInProgress else {
                return .none
            }

            if case let .invalid(error) = inputValidator
                .validate(state.selectedShipmentInfo, for: state.redeemOption) {
                state.destination = .alert(.info(AlertStates.missingContactInfo(with: error)))
                return .none
            }
            state.redeemInProgress = true
            return redeem(orders: state.orders)
        case let .redeemReceived(.success(orderResponses)):
            state.redeemInProgress = false
            state.orderResponses = orderResponses
            if orderResponses.arePartiallySuccessful || orderResponses.areFailing {
                state.destination = .alert(.info(AlertStates.failingRequest(count: orderResponses.failedCount)))
            } else if orderResponses.areSuccessful {
                state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: state.redeemOption))
            }
            let pharmacy = state.pharmacy
            return .run { _ in
                _ = try await save(pharmacy: pharmacy).async()
            }
        case let .redeemReceived(.failure(error)):
            state.redeemInProgress = false
            if case let RedeemServiceError.prescriptionAlreadyRedeemed(prescriptions) = error {
                let failedPrescriptionIds = prescriptions.map(\.id)
                state.selectedPrescriptions = state.selectedPrescriptions
                    .filter { !failedPrescriptionIds.contains($0.id) }

                if state.selectedPrescriptions.isEmpty {
                    state.destination = .alert(ErpAlertState<Destination.Alert>(for: error, actions: {
                        ButtonState(action: .send(.closeRedeem)) {
                            TextState(L10n.phaRedeemBtnPrescriptionAlreadyRedeemedAlertDismiss)
                        }
                        ButtonState(role: .cancel) {
                            TextState(L10n.amgBtnAlertCancel)
                        }
                    }))
                } else {
                    state.destination = .alert(ErpAlertState(for: error, actions: {
                        ButtonState(action: .send(.retryRedeem)) {
                            TextState(L10n.phaRedeemBtnPrescriptionAlreadyRedeemedAlertProceedWithout)
                        }
                        ButtonState(role: .cancel) {
                            TextState(L10n.amgBtnAlertCancel)
                        }
                    }))
                }
            } else {
                state.destination = .alert(.init(for: error))
            }

            return .run { [pharmacy = state.pharmacy] _ in
                for try await _ in save(pharmacy: pharmacy).values {}
            }
        case .destination(.presented(.redeemSuccess(.delegate(.close)))),
             .destination(.presented(.alert(.closeRedeem))):
            state.destination = nil
            return .run { send in
                // allow the state.destination to be recognized by SwiftUI, otherwise the dialog pops up again after
                // dismissal
                try await schedulers.main.sleep(for: 0.1)

                await send(.delegate(.close))
            }
        case .destination(.presented(.contact(.delegate(.close)))),
             .destination(.presented(.cardWall(.delegate(.close)))):
            state.destination = nil
            return .none
        case .showContact,
             .destination(.presented(.alert(.contact))):
            state.destination = .contact(
                .init(shipmentInfo: state.selectedShipmentInfo, service: inputValidator.service)
            )
            return .none
        case .showRedeemSuccess:
            state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: state.redeemOption))
            return .none
        case .showCardWall:
            state.redeemInProgress = false
            state.destination = .cardWall(CardWallIntroductionDomain.State(
                isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                profileId: userSession.profileId
            ))
            return .none
        case .showPrescriptionSelection:
            state.destination = .prescriptionSelection(PharmacyPrescriptionSelectionDomain
                .State(prescriptions: state.$prescriptions,
                       selectedPrescriptions: state.$selectedPrescriptions,
                       profile: state.profile))
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension PharmacyRedeemDomain {
    enum AlertStates {
        static func alert(for error: RedeemServiceError) -> AlertState<Destination.Alert> {
            guard let message = error.recoverySuggestion else {
                return AlertState(
                    title: { TextState(error.localizedDescriptionWithErrorList) },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState(L10n.alertBtnOk)
                        }
                    }
                )
            }
            return AlertState(
                title: { TextState(error.localizedDescriptionWithErrorList) },
                actions: {
                    ButtonState(role: .cancel) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(message) }
            )
        }

        static func missingContactInfo(with localizedMessage: String) -> AlertState<Destination.Alert> {
            AlertState(
                title: { TextState(L10n.phaRedeemAlertTitleMissingPhone) },
                actions: {
                    ButtonState(action: .send(.contact)) {
                        TextState(L10n.phaRedeemBtnAlertComplete)
                    }
                    ButtonState(role: .cancel) {
                        TextState(L10n.phaRedeemBtnAlertCancel)
                    }
                },
                message: { TextState(localizedMessage) }
            )
        }

        static func failingRequest(count: Int) -> AlertState<Destination.Alert> {
            AlertState(
                title: { TextState(L10n.phaRedeemAlertTitleFailure(count)) },
                actions: {
                    ButtonState(role: .cancel) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(L10n.phaRedeemAlertMessageFailure) }
            )
        }
    }
}

extension PharmacyRedeemDomain {
    func redeem(
        orders: [OrderRequest]
    ) -> Effect<PharmacyRedeemDomain.Action> {
        .publisher(
            redeemService.redeem(orders) // -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>
                .receive(on: schedulers.main.animation())
                .map { orderResponses -> PharmacyRedeemDomain.Action in
                    PharmacyRedeemDomain.Action.redeemReceived(.success(orderResponses))
                }
                .catch { redeemError -> AnyPublisher<PharmacyRedeemDomain.Action, Never> in
                    if redeemError == .noTokenAvailable {
                        return Just(PharmacyRedeemDomain.Action.showCardWall)
                            .eraseToAnyPublisher()
                    } else {
                        return Just(PharmacyRedeemDomain.Action.redeemReceived(.failure(redeemError)))
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher
        )
    }

    func save(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        var pharmacy = pharmacy
        pharmacy.lastUsed = Date()
        pharmacy.countUsage += 1
        return pharmacyRepository.save(pharmacy: pharmacy)
            .first()
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
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
            prescriptions: Shared([Prescription.Dummies.prescriptionReady]),
            pharmacy: pharmacy,
            selectedPrescriptions: Shared(Set([Prescription.Dummies.prescriptionReady])),
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

        static let store = Store(
            initialState: state
        ) {
            PharmacyRedeemDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<PharmacyRedeemDomain> {
            Store(
                initialState: state
            ) {
                PharmacyRedeemDomain()
            }
        }
    }
}
