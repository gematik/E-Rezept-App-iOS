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

@Reducer
struct PharmacyContactDomain {
    @ObservableState
    struct State: Equatable {
        var contactInfo: ContactInfo
        @Presents var alertState: AlertState<Action.Alert>?

        private let originalContactInfo: ContactInfo?
        var isNewContactInfo: Bool {
            contactInfo != originalContactInfo
        }

        var serviceOption: RedeemServiceOption?

        init(
            shipmentInfo: ShipmentInfo?,
            serviceOption: RedeemServiceOption? = nil
        ) {
            let shipmentInfo = shipmentInfo ?? ShipmentInfo()
            contactInfo = .init(shipmentInfo)
            originalContactInfo = .init(shipmentInfo)
            self.serviceOption = serviceOption
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case save

        case alert(PresentationAction<Alert>)
        case response(Response)
        case delegate(Delegate)

        enum Alert: Equatable {}

        enum Delegate: Equatable {
            case close
        }

        enum Response: Equatable {
            case shipmentInfoSaved(Result<ShipmentInfo?, LocalStoreError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.shipmentInfoDataStore) var shipmentInfoStore: ShipmentInfoDataStore
    @Dependency(\.redeemOrderInputValidator) var validator: RedeemOrderInputValidator

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce(core)
            .ifLet(\.$alertState, action: \.alert)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .save:
            if case let .invalid(errorMessage) = validator.type(state.serviceOption)?.validate(state.contactInfo) {
                state.alertState = Self.invalidInputAlert(with: errorMessage)
                return .none
            }
            return .publisher(
                shipmentInfoStore.save(shipmentInfo: state.contactInfo.shipmentInfo)
                    .catchToPublisher()
                    .map { Action.response(.shipmentInfoSaved($0)) }
                    .first()
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.shipmentInfoSaved(.success(info))):
            if let identifier = info?.identifier {
                shipmentInfoStore.set(selectedShipmentInfoId: identifier)
            }
            return Effect.send(.delegate(.close))
        case let .response(.shipmentInfoSaved(.failure(error))):
            state.alertState = AlertState(
                title: { TextState(L10n.alertErrorTitle) },
                actions: {
                    ButtonState(role: .cancel, action: .send(.none)) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(error.localizedDescriptionWithErrorList) }
            )
            return .none
        case .delegate:
            return .none
        case .binding(\.contactInfo.name):
            if case let .invalid(error) = validator.type(state.serviceOption)?.isValid(name: state.contactInfo.name) {
                state.alertState = Self.invalidInputAlert(with: error)
            }
            return .none
        case .binding(\.contactInfo.street):
            if case let .invalid(error) = validator.type(state.serviceOption)?
                .isValid(street: state.contactInfo.street) {
                state.alertState = Self.invalidInputAlert(with: error)
            }
            return .none
        case .binding(\.contactInfo.zip):
            if case let .invalid(error) = validator.type(state.serviceOption)?.isValid(zip: state.contactInfo.zip) {
                state.alertState = Self.invalidInputAlert(with: error)
            }
            return .none
        case .binding(\.contactInfo.city):
            if case let .invalid(error) = validator.type(state.serviceOption)?.isValid(city: state.contactInfo.city) {
                state.alertState = Self.invalidInputAlert(with: error)
            }
            return .none
        case .binding(\.contactInfo.deliveryInfo):
            if case let .invalid(error) = validator.type(state.serviceOption)?
                .isValid(hint: state.contactInfo.deliveryInfo) {
                state.alertState = Self.invalidInputAlert(with: error)
            }
            return .none
        case .alert, .binding:
            return .none
        }
    }

    static func invalidInputAlert(with message: String) -> AlertState<Action.Alert> {
        AlertState(
            title: { TextState(L10n.alertErrorTitle) },
            actions: {
                ButtonState(role: .cancel, action: .send(.none)) {
                    TextState(L10n.alertBtnOk)
                }
            },
            message: { TextState(message) }
        )
    }

    struct ContactInfo: Equatable {
        let identifier: UUID
        var name: String
        var street: String
        var zip: String
        var city: String
        var phone: String
        var mail: String
        var deliveryInfo: String

        init(_ shipmentInfo: ShipmentInfo?) {
            identifier = shipmentInfo?.identifier ?? UUID()
            name = shipmentInfo?.name ?? ""
            street = shipmentInfo?.street ?? ""
            zip = shipmentInfo?.zip ?? ""
            city = shipmentInfo?.city ?? ""
            phone = shipmentInfo?.phone ?? ""
            mail = shipmentInfo?.mail ?? ""
            deliveryInfo = shipmentInfo?.deliveryInfo ?? ""
        }

        var shipmentInfo: ShipmentInfo {
            ShipmentInfo(identifier: identifier,
                         name: name.isEmpty ? nil : name,
                         street: street.isEmpty ? nil : street,
                         zip: zip.isEmpty ? nil : zip,
                         city: city.isEmpty ? nil : city,
                         phone: phone.isEmpty ? nil : phone,
                         mail: mail.isEmpty ? nil : mail,
                         deliveryInfo: deliveryInfo.isEmpty ? nil : deliveryInfo)
        }

        static func ==(
            lhs: PharmacyContactDomain.ContactInfo,
            rhs: PharmacyContactDomain.ContactInfo
        ) -> Bool {
            lhs.identifier == rhs.identifier &&
                lhs.name == rhs.name &&
                lhs.street == rhs.street &&
                lhs.zip == rhs.zip &&
                lhs.city == rhs.city &&
                lhs.phone == rhs.phone &&
                lhs.mail == rhs.mail &&
                lhs.deliveryInfo == rhs.deliveryInfo
        }
    }
}

extension RedeemInputValidator {
    func validate(_ contactInfo: PharmacyContactDomain.ContactInfo) -> Validity {
        if isValid(name: contactInfo.name) != .valid {
            return isValid(name: contactInfo.name)
        }
        if isValid(street: contactInfo.street) != .valid {
            return isValid(street: contactInfo.street)
        }
        if isValid(zip: contactInfo.zip) != .valid {
            return isValid(zip: contactInfo.zip)
        }
        if isValid(city: contactInfo.city) != .valid {
            return isValid(city: contactInfo.city)
        }
        if isValid(hint: contactInfo.deliveryInfo) != .valid {
            return isValid(hint: contactInfo.deliveryInfo)
        }
        if isValid(phone: contactInfo.phone) != .valid {
            return isValid(phone: contactInfo.phone)
        }
        if isValid(mail: contactInfo.mail) != .valid {
            return isValid(mail: contactInfo.mail)
        }

        return .valid
    }
}

extension PharmacyContactDomain {
    enum Dummies {
        static let state = State(
            shipmentInfo: .init(
                name: "Anna Vetter",
                street: "Gartenstraße 5",
                addressDetail: "",
                zip: "102837",
                city: "Berlin",
                phone: "0987654321",
                deliveryInfo: "im Hinterhaus"
            )
        )

        static let store = Store(
            initialState: state
        ) {
            PharmacyContactDomain()
        }
    }
}
