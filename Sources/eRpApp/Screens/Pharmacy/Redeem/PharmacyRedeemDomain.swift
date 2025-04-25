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

// swiftlint:disable type_body_length file_length
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
        @Shared var prescriptions: [Prescription]
        @Shared var selectedPrescriptions: [Prescription]
        var pharmacy: PharmacyLocation?
        var serviceOption: RedeemServiceOption?
        var redeemInProgress = false
        var orderResponses: IdentifiedArrayOf<OrderResponse>
        var selectedShipmentInfo: ShipmentInfo?
        var profile: Profile?

        var serviceOptionState: ServiceOptionDomain.State
        @Presents var destination: Destination.State?

        var orders: [OrderRequest] {
            if let pharmacy, let redeemOption = serviceOptionState.selectedOption {
                return selectedPrescriptions.map(\.erxTask)
                    .asOrders(orderId: UUID(),
                              option: redeemOption,
                              for: pharmacy,
                              with: selectedShipmentInfo)
            }
            return []
        }

        init(
            prescriptions: Shared<[Prescription]>,
            selectedPrescriptions: Shared<[Prescription]>,
            pharmacy: PharmacyLocation? = nil,
            serviceOption: RedeemServiceOption? = nil,
            selectedShipmentInfo: ShipmentInfo? = nil,
            redeemInProgress: Bool = false,
            orderResponses: IdentifiedArrayOf<OrderResponse> = [],
            profile: Profile? = nil,
            serviceOptionState: ServiceOptionDomain.State? = nil,
            destination: Destination.State? = nil
        ) {
            _prescriptions = prescriptions
            _selectedPrescriptions = selectedPrescriptions
            self.pharmacy = pharmacy
            self.serviceOption = serviceOption
            self.selectedShipmentInfo = selectedShipmentInfo
            self.redeemInProgress = redeemInProgress
            self.orderResponses = orderResponses
            self.profile = profile
            self.serviceOptionState = serviceOptionState ?? .init(prescriptions: prescriptions)
            self.destination = destination
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
        case redeemOptionProviderReceived(RedeemOptionProvider)
        /// Navigation actions
        case showContact
        case showRedeemSuccess
        case showCardWall
        case showPrescriptionSelection
        /// Actions for subdomains and navigation
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        case resetNavigation
        /// Child domain actions
        case serviceOption(ServiceOptionDomain.Action)

        enum Delegate: Equatable {
            /// Close all
            case close
            /// Change selected pharmacy
            case changePharmacy
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.shipmentInfoDataStore) var shipmentInfoStore: ShipmentInfoDataStore
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.redeemOrderInputValidator) var validator: RedeemOrderInputValidator
    @Dependency(\.redeemOrderService) var redeemOrderService: RedeemOrderService
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar

    var body: some Reducer<State, Action> {
        Scope(state: \State.serviceOptionState, action: \.serviceOption) {
            ServiceOptionDomain()
        }
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .send(.registerSelectedShipmentInfoListener),
                .send(.registerSelectedProfileListener),
                .run { [pharmacy = state.pharmacy] send in
                    if let pharmacy {
                        let provider = try await redeemOrderService.redeemOptionProvider(pharmacy: pharmacy)
                        await send(.redeemOptionProviderReceived(provider))
                    }
                }
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
        case let .redeemOptionProviderReceived(provider):
            var options = Set<RedeemOption>()
            if provider.reservationService.hasService {
                options.insert(.onPremise)
            }
            if provider.deliveryService.hasService {
                options.insert(.delivery)
            }
            if provider.shipmentService.hasService {
                options.insert(.shipment)
            }
            state.serviceOptionState.availableOptions = options

            guard let redeemOption = state.serviceOptionState.selectedOption
            else { return .none }
            var serviceOption: RedeemServiceOption?
            switch redeemOption {
            case .onPremise:
                serviceOption = provider.reservationService
            case .delivery:
                serviceOption = provider.deliveryService
            case .shipment:
                serviceOption = provider.shipmentService
            }
            state.serviceOption = serviceOption

            return .none
        case .redeem,
             .destination(.presented(.alert(.retryRedeem))):
            state.orderResponses = []
            guard let redeemOption = state.serviceOptionState.selectedOption,
                  !state.selectedPrescriptions.isEmpty, !state.redeemInProgress
            else { return .none }

            if case let .invalid(error) = validator.type(state.serviceOption)?
                .validate(state.selectedShipmentInfo, for: redeemOption) {
                state.destination = .alert(.info(AlertStates.missingContactInfo(with: error)))
                return .none
            }
            state.redeemInProgress = true

            return .run { [orderRequests = state.orders, serviceOption = state.serviceOption] send in
                do {
                    switch serviceOption {
                    case .avs:
                        let orderResponses = try await redeemOrderService.redeemViaAVS(orderRequests)
                        await send(.redeemReceived(.success(orderResponses)))
                    case .erxTaskRepository, .erxTaskRepositoryAvailable:
                        let orderResponses = try await redeemOrderService
                            .redeemViaErxTaskRepository(orderRequests)
                        await send(.redeemReceived(.success(orderResponses)))
                    case .noService, .none:
                        break
                    }
                } catch RedeemServiceError.noTokenAvailable {
                    await send(.showCardWall)
                } catch let RedeemOrderServiceError.redeem(error) {
                    await send(.redeemReceived(.failure(error)))
                } catch let error as RedeemServiceError {
                    await send(.redeemReceived(.failure(error)))
                }
            }
        case let .redeemReceived(.success(orderResponses)):
            guard let redeemOption = state.serviceOptionState.selectedOption,
                  let pharmacy = state.pharmacy
            else { return .none }

            state.redeemInProgress = false
            state.orderResponses = orderResponses
            if orderResponses.arePartiallySuccessful || orderResponses.areFailing {
                state.destination = .alert(.info(AlertStates.failingRequest(count: orderResponses.failedCount)))
            } else if orderResponses.areSuccessful {
                state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: redeemOption))
            }
            return .run { _ in
                _ = try await save(pharmacy: pharmacy).async()
            }
        case let .redeemReceived(.failure(error)):
            guard let pharmacy = state.pharmacy
            else { return .none }

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

            return .run { _ in
                for try await _ in save(pharmacy: pharmacy).values {}
            }
        case .destination(.presented(.redeemSuccess(.delegate(.close)))),
             .destination(.presented(.alert(.closeRedeem))):
            state.destination = nil
            return .run { send in
                // allow the state.destination to be recognized by SwiftUI, otherwise the dialog pops up again after
                // dismissal
                try await schedulers.main.sleep(for: 1.0)

                await send(.delegate(.close))
            }
        case .destination(.presented(.contact(.delegate(.close)))),
             .destination(.presented(.cardWall(.delegate(.close)))):
            state.destination = nil
            return .none
        case .showContact,
             .destination(.presented(.alert(.contact))):
            state.destination = .contact(.init(
                shipmentInfo: state.selectedShipmentInfo,
                serviceOption: state.serviceOption
            ))
            return .none
        case .showRedeemSuccess:
            guard let redeemOption = state.serviceOptionState.selectedOption
            else { return .none }
            state.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: redeemOption))
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
        case .serviceOption,
             .destination,
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
        static let prescriptions = [Prescription.Dummies.prescriptionReady]

        static let state = State(
            prescriptions: Shared(prescriptions),
            selectedPrescriptions: Shared(prescriptions),
            pharmacy: pharmacy,
            serviceOption: .erxTaskRepository,
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
            profile: Profile(name: "Marta Maquise"),
            serviceOptionState: .init(
                prescriptions: Shared(prescriptions),
                selectedOption: .shipment
            )
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

// swiftlint:enable type_body_length file_length
