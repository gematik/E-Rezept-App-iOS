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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation

struct PharmacyContactDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case shipmentInfoStore
    }

    struct State: Equatable {
        var contactInfo: ContactInfo
        var alertState: AlertState<Action>?
        let service: RedeemServiceOption

        private let originalContactInfo: ContactInfo?
        var isNewContactInfo: Bool {
            contactInfo != originalContactInfo
        }

        init(shipmentInfo: ShipmentInfo?, service: RedeemServiceOption) {
            let shipmentInfo = shipmentInfo ?? ShipmentInfo()
            self.service = service
            contactInfo = .init(shipmentInfo)
            originalContactInfo = .init(shipmentInfo)
        }
    }

    enum Action: Equatable {
        case setName(String)
        case setStreet(String)
        case setZip(String)
        case setCity(String)
        case setPhone(String)
        case setMail(String)
        case setDeliveryInfo(String)
        case save
        case alertDismissButtonTapped
        case closeButtonTapped
        case response(Response)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }

        enum Response: Equatable {
            case shipmentInfoSaved(Result<ShipmentInfo?, LocalStoreError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.shipmentInfoDataStore) var shipmentInfoStore: ShipmentInfoDataStore
    @Dependency(\.redeemInputValidator) var validator: RedeemInputValidator

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .save:
            if case let .invalid(errorMessage) = validator.validate(state.contactInfo) {
                state.alertState = Self.invalidInputAlert(with: errorMessage)
                return .none
            }
            return shipmentInfoStore.save(shipmentInfo: state.contactInfo.shipmentInfo)
                .catchToEffect()
                .map { Action.response(.shipmentInfoSaved($0)) }
                .first()
                .receive(on: schedulers.main)
                .eraseToEffect()
        case let .response(.shipmentInfoSaved(.success(info))):
            if let identifier = info?.identifier {
                shipmentInfoStore.set(selectedShipmentInfoId: identifier)
            }
            return EffectTask(value: .delegate(.close))
        case let .response(.shipmentInfoSaved(.failure(error))):
            state.alertState = AlertState(
                title: TextState(L10n.alertErrorTitle),
                message: TextState(error.localizedDescriptionWithErrorList),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
            )
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case .closeButtonTapped:
            return EffectTask(value: .delegate(.close))
        case .delegate:
            return .none
        case let .setName(name):
            if case let .invalid(error) = validator.isValid(name: name) {
                state.alertState = Self.invalidInputAlert(with: error)
                return .none
            }
            state.contactInfo.name = name
            return .none
        case let .setStreet(street):
            if case let .invalid(error) = validator.isValid(street: street) {
                state.alertState = Self.invalidInputAlert(with: error)
                return .none
            }
            state.contactInfo.street = street
            return .none
        case let .setZip(zip):
            if case let .invalid(error) = validator.isValid(zip: zip) {
                state.alertState = Self.invalidInputAlert(with: error)
                return .none
            }
            state.contactInfo.zip = zip
            return .none
        case let .setCity(city):
            if case let .invalid(error) = validator.isValid(city: city) {
                state.alertState = Self.invalidInputAlert(with: error)
                return .none
            }
            state.contactInfo.city = city
            return .none
        case let .setPhone(phone):
            state.contactInfo.phone = phone
            return .none
        case let .setMail(mail):
            state.contactInfo.mail = mail
            return .none
        case let .setDeliveryInfo(info):
            if case let .invalid(error) = validator.isValid(hint: info) {
                state.alertState = Self.invalidInputAlert(with: error)
                return .none
            }
            state.contactInfo.deliveryInfo = info
            return .none
        }
    }

    static func invalidInputAlert(with message: String) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.alertErrorTitle),
            message: TextState(message),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(Action.alertDismissButtonTapped))
        )
    }
}

extension RedeemInputValidator {
    func validate(_ contactInfo: PharmacyContactDomain.State.ContactInfo) -> Validity {
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

extension PharmacyContactDomain.State {
    struct ContactInfo: Equatable {
        static func ==(
            lhs: PharmacyContactDomain.State.ContactInfo,
            rhs: PharmacyContactDomain.State.ContactInfo
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
    }
}

extension PharmacyContactDomain {
    enum Dummies {
        static let state = State(
            shipmentInfo: .init(name: "Anna Vetter",
                                street: "Gartenstraße 5",
                                addressDetail: "",
                                zip: "102837",
                                city: "Berlin",
                                phone: "0987654321",
                                deliveryInfo: "im Hinterhaus"),
            service: DemoRedeemInputValidator().service
        )

        static let store = Store(
            initialState: state,
            reducer: PharmacyContactDomain()
        )
    }
}
