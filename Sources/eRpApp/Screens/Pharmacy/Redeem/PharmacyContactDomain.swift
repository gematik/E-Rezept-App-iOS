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

enum PharmacyContactDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case shipmentInfoStore
    }

    struct State: Equatable {
        @BindableState var contactInfo: ContactInfo
        var alertState: AlertState<Action>?

        private let originalContactInfo: ContactInfo?
        var isNewContactInfo: Bool {
            contactInfo != originalContactInfo
        }

        init(shipmentInfo: ShipmentInfo?) {
            let shipmentInfo = shipmentInfo ?? ShipmentInfo()
            contactInfo = .init(shipmentInfo)
            originalContactInfo = .init(shipmentInfo)
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<PharmacyContactDomain.State>)

        case save
        case shipmentInfoSaved(Result<ShipmentInfo?, LocalStoreError>)
        case alertDismissButtonTapped
        case close
    }

    struct Environment {
        let schedulers: Schedulers
        let shipmentInfoStore: ShipmentInfoDataStore
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .binding:
            return .none
        case .save:
            return environment.shipmentInfoStore.save(shipmentInfo: state.contactInfo.shipmentInfo)
                .catchToEffect()
                .map(Action.shipmentInfoSaved)
                .first()
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .shipmentInfoSaved(.success(info)):
            if let identifier = info?.identifier {
                environment.shipmentInfoStore.set(selectedShipmentInfoId: identifier)
            }
            return Effect(value: .close)
        case let .shipmentInfoSaved(.failure(error)):
            state.alertState = AlertState(
                title: TextState(L10n.alertErrorTitle),
                message: TextState(error.localizedDescription),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
            )
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case .close:
            return cleanup()
        }
    }
    .binding()

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension PharmacyContactDomain.State {
    struct ContactInfo: Equatable {
        let identifier: UUID
        var name: String
        var street: String
        var addressDetail: String
        var zip: String
        var city: String
        var phone: String
        var mail: String
        var deliveryInfo: String

        init(_ shipmentInfo: ShipmentInfo?) {
            identifier = shipmentInfo?.identifier ?? UUID()
            name = shipmentInfo?.name ?? ""
            street = shipmentInfo?.street ?? ""
            addressDetail = shipmentInfo?.addressDetail ?? ""
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
                         addressDetail: addressDetail.isEmpty ? nil : addressDetail,
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
                                deliveryInfo: "im Hinterhaus")
        )

        static let environment = Environment(
            schedulers: Schedulers(),
            shipmentInfoStore: DemoShipmentInfoStore()
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PharmacyContactDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
