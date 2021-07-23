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
import Contacts
import eRpKit
import MapKit
import Pharmacy
import SwiftUI

enum PharmacyDetailDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var erxTasks: [ErxTask]
        // TODO: Change pharmacy detail model to also use pharmacyLocationViewModel
        // swiftlint:disable:previous todo
        var pharmacyViewModel: PharmacyLocationViewModel
        var pharmacy: PharmacyLocation {
            pharmacyViewModel.pharmacyLocation
        }

        var pharmacyRedeemState: PharmacyRedeemDomain.State?
        var isPharmacyRedeemViewPresented: Bool { pharmacyRedeemState != nil }
    }

    enum Action: Equatable {
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
        /// Shows `PharmacyRedeemView` in one of the available `RedeemOption` flavours
        case showPharmacyRedeemView(RedeemOption)
        /// Closes the `PharmacyRedeemView`
        case dismissPharmacyRedeemView
        /// Actions for PharmacyRedeemView
        case pharmacyRedeem(action: PharmacyRedeemDomain.Action)
    }

    struct Environment {
        var schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, _ in
        switch action {
        case .close:
            // Note: closing is handled in parent reducer
            return .none
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
               let number = state.pharmacy.address?.housenumber {
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
        case let .showPharmacyRedeemView(method):
            state.pharmacyRedeemState = PharmacyRedeemDomain.State(
                redeemOption: method,
                erxTasks: state.erxTasks,
                pharmacy: state.pharmacy,
                selectedErxTasks: Set(state.erxTasks)
            )
            return .none
        case .dismissPharmacyRedeemView:
            state.pharmacyRedeemState = nil
            return .none
        case .pharmacyRedeem(action: .close):
            state.pharmacyRedeemState = nil
            return Effect(value: .close)
        case .pharmacyRedeem:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacyRedeemPullbackReducer,
        domainReducer
    )

    static let pharmacyRedeemPullbackReducer: Reducer =
        PharmacyRedeemDomain.reducer.optional().pullback(
            state: \.pharmacyRedeemState,
            action: /PharmacyDetailDomain.Action.pharmacyRedeem(action:)
        ) { environment in
            PharmacyRedeemDomain.Environment(
                schedulers: environment.schedulers,
                userSession: AppContainer.shared.userSessionContainer.userSession,
                erxTaskRepository: AppContainer.shared.userSessionSubject.erxTaskRepository
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

extension PharmacyDetailDomain {
    enum Dummies {
        static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            housenumber: "6",
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

        static let state = State(
            erxTasks: ErxTask.Dummies.prescriptions,
            pharmacyViewModel: pharmacyViewModel
        )
        static let environment = Environment(
            schedulers: Schedulers()
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
