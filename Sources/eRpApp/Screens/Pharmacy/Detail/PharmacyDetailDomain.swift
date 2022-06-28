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
import Contacts
import eRpKit
import eRpLocalStorage
import MapKit
import Pharmacy
import SwiftUI

enum PharmacyDetailDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.concatenate(
            PharmacyRedeemDomain.cleanup(),
            Effect.cancel(token: Token.self)
        )
    }

    /// Tokens for Cancellables
    enum Token: CaseIterable, Hashable {
        case loadProfile
    }

    enum Route: Equatable {
        case redeemViaAVS(PharmacyRedeemDomain.State)
        case redeemViaErxTaskRepository(PharmacyRedeemDomain.State)

        enum Tag: Int {
            case redeemViaAVS
            case redeemViaErxTaskRepository
        }

        var tag: Tag {
            switch self {
            case .redeemViaAVS: return .redeemViaAVS
            case .redeemViaErxTaskRepository: return .redeemViaErxTaskRepository
            }
        }
    }

    struct State: Equatable {
        var erxTasks: [ErxTask]
        var pharmacyViewModel: PharmacyLocationViewModel
        var pharmacy: PharmacyLocation {
            pharmacyViewModel.pharmacyLocation
        }

        var reservationService: RedeemServiceOption = .noService
        var shipmentService: RedeemServiceOption = .noService
        var deliveryService: RedeemServiceOption = .noService
        var route: Route?
    }

    enum Action: Equatable {
        /// load current profile
        case loadCurrentProfile
        /// receive current Profile
        case currentProfileReceived(Profile?)
        /// Closes the details page
        case close
        /// Opens Map App with pharmacy location
        case openMapApp
        /// Opens the Phone App with pharmacy phone number
        case openPhoneApp
        /// Opens a Browser app with pharmacy website
        case openBrowserApp
        /// Opens Mail app with pharmacy email address
        case openMailApp
        /// Selects  the `RedeemOption` to use and set the navigation tag accordingly
        case showPharmacyRedeemOption(RedeemOption)
        /// Actions for PharmacyRedeemView with the `ErxTaskRepositoryRedeemService`
        case pharmacyRedeemViaErxTaskRepository(action: PharmacyRedeemDomain.Action)
        /// Actions for PharmacyRedeemView with the `AVSRedeemService`
        case pharmacyRedeemViaAVS(action: PharmacyRedeemDomain.Action)
        /// Handles navigation
        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        var schedulers: Schedulers
        let userSession: UserSession
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadCurrentProfile:
            return environment.userSession.profile()
                .first()
                .catchToEffect()
                .map { result in
                    if case let .success(profile) = result {
                        return Action.currentProfileReceived(profile)
                    }
                    return Action.currentProfileReceived(nil)
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.loadProfile, cancelInFlight: true)
        case let .currentProfileReceived(profile):
            let provider = RedeemOptionProvider(
                wasAuthenticatedBefore: profile?.insuranceId != nil,
                pharmacy: state.pharmacy
            )
            state.reservationService = provider.reservationService
            state.shipmentService = provider.shipmentService
            state.deliveryService = provider.deliveryService
            return .none
        case .close:
            // Note: closing is handled in parent reducer
            return cleanup()
        case .openMapApp:
            guard let longitude = state.pharmacy.position?.longitude?.doubleValue,
                  let latitude = state.pharmacy.position?.latitude?.doubleValue else {
                // TODO: Try to use `CLGeocoder` with the address to recover swiftlint:disable:this todo
                return .none
            }
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)

            var address: [String: Any] = [:]
            if let city = state.pharmacy.address?.city,
               let zip = state.pharmacy.address?.zip,
               let street = state.pharmacy.address?.street,
               let number = state.pharmacy.address?.houseNumber {
                address = [
                    CNPostalAddressStreetKey: "\(street) \(number)",
                    CNPostalAddressCityKey: city,
                    CNPostalAddressPostalCodeKey: zip,
                    CNPostalAddressISOCountryCodeKey: "DE",
                ]
            }

            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: address))
            mapItem.name = state.pharmacy.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            return .none
        case .openPhoneApp:
            if let phone = state.pharmacy.telecom?.phone,
               let number = URL(string: "tel://\(phone)") {
                UIApplication.shared.open(number)
            }
            return .none
        case .openBrowserApp:
            if let web = state.pharmacy.telecom?.web,
               let url = URL(string: web) {
                UIApplication.shared.open(url)
            }
            return .none
        case .openMailApp:
            if let email = state.pharmacy.telecom?.email,
               let url = createEmailUrl(to: email) {
                UIApplication.shared.open(url)
            }
            return .none
        case let .showPharmacyRedeemOption(option):
            let redeemState = PharmacyRedeemDomain.State(
                redeemOption: option,
                erxTasks: state.erxTasks,
                pharmacy: state.pharmacy,
                selectedErxTasks: Set(state.erxTasks)
            )
            var route: Route
            switch option {
            case .onPremise:
                state.route = state.reservationService.route(with: redeemState)
            case .delivery:
                state.route = state.deliveryService.route(with: redeemState)
            case .shipment:
                state.route = state.shipmentService.route(with: redeemState)
            }
            return .none
        case .pharmacyRedeemViaErxTaskRepository(action: .close), .pharmacyRedeemViaAVS(action: .close):
            state.route = nil
            return Effect(value: .close)
                // swiftlint:disable:next todo
                // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                .delay(for: .seconds(0.1), scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .pharmacyRedeemViaErxTaskRepository, .setNavigation, .pharmacyRedeemViaAVS:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacyRedeemViaAVSPullbackReducer,
        pharmacyRedeemViaRepositoryPullback,
        domainReducer
    )

    static let pharmacyRedeemViaAVSPullbackReducer: Reducer =
        PharmacyRedeemDomain.reducer._pullback(
            state: (\State.route).appending(path: /PharmacyDetailDomain.Route.redeemViaAVS),
            action: /PharmacyDetailDomain.Action.pharmacyRedeemViaAVS(action:)
        ) { environment in
            PharmacyRedeemDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession,
                shipmentInfoStore: environment.userSession.shipmentInfoDataStore,
                redeemService: AVSRedeemService(avsSession: environment.userSession.avsSession)
            )
        }

    static let pharmacyRedeemViaRepositoryPullback: Reducer =
        PharmacyRedeemDomain.reducer._pullback(
            state: (\State.route).appending(path: /PharmacyDetailDomain.Route.redeemViaErxTaskRepository),
            action: /PharmacyDetailDomain.Action.pharmacyRedeemViaErxTaskRepository(action:)
        ) { environment in
            PharmacyRedeemDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession,
                shipmentInfoStore: environment.userSession.shipmentInfoDataStore,
                redeemService: ErxTaskRepositoryRedeemService(
                    erxTaskRepository: environment.userSession.erxTaskRepository,
                    isAuthenticated: environment.userSession.isAuthenticated
                )
            )
        }

    private static func createEmailUrl(to email: String, subject: String? = nil, body: String? = nil) -> URL? {
        var gmailUrlString = "googlegmail://co?to=\(email)"
        var outlookIUrlString = "ms-outlook://compose?to=\(email)"
        var yahooUrlString = "ymail://mail/compose?to=\(email)"
        var defaultUrlString = "mailto:\(email)"

        if let subject = subject,
           let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            gmailUrlString += "&subject=\(subjectEncoded)"
            outlookIUrlString += "&subject=\(subjectEncoded)"
            yahooUrlString += "&subject=\(subjectEncoded)"
            defaultUrlString += "&subject=\(subjectEncoded)"
        }

        if let body = body,
           let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            gmailUrlString += "&body=\(bodyEncoded)"
            outlookIUrlString += "&body=\(bodyEncoded)"
            yahooUrlString += "&body=\(bodyEncoded)"
            defaultUrlString += "&body=\(bodyEncoded)"
        }

        if let gmailUrl = URL(string: gmailUrlString),
           UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = URL(string: outlookIUrlString),
                  UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = URL(string: yahooUrlString),
                  UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        }

        return URL(string: defaultUrlString)
    }
}

extension RedeemServiceOption {
    func route(with state: PharmacyRedeemDomain.State) -> PharmacyDetailDomain.Route? {
        switch self {
        case .avs:
            return .redeemViaAVS(state)
        case .erxTaskRepository, .erxTaskRepositoryAvailable:
            return .redeemViaErxTaskRepository(state)
        case .noService:
            return nil
        }
    }
}

extension PharmacyDetailDomain {
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

        static let pharmacyViewModel = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Dummies.pharmacy
        )

        static let pharmacyInactiveViewModel = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Dummies.pharmacyInactive
        )

        static let prescriptions = ErxTask.Demo.erxTasks

        static let state = State(
            erxTasks: prescriptions,
            pharmacyViewModel: pharmacyViewModel,
            reservationService: .erxTaskRepository,
            shipmentService: .erxTaskRepository,
            deliveryService: .erxTaskRepository
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DemoSessionContainer()
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PharmacyDetailDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
