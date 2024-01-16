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
import Contacts
import eRpKit
import eRpLocalStorage
import IDP
import MapKit
import OpenSSL
import Pharmacy
import SwiftUI

struct PharmacyDetailDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = redeem_viaAVS
            case redeemViaAVS(PharmacyRedeemDomain.State)
            // sourcery: AnalyticsScreen = redeem_viaTI
            case redeemViaErxTaskRepository(PharmacyRedeemDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<PharmacyRedeemDomain.State>)
        }

        enum Action: Equatable {
            /// Actions for PharmacyRedeemView with the `ErxTaskRepositoryRedeemService`
            case pharmacyRedeemViaErxTaskRepository(action: PharmacyRedeemDomain.Action)
            /// Actions for PharmacyRedeemView with the `AVSRedeemService`
            case pharmacyRedeemViaAVS(action: PharmacyRedeemDomain.Action)
        }

        @Dependency(\.erxTaskOrderValidator) var erxTaskOrderValidator
        @Dependency(\.erxTaskRepositoryRedeemService) var erxTaskRepositoryRedeemService
        @Dependency(\.avsMessageValidator) var avsMessageValidator
        @Dependency(\.avsRedeemService) var avsRedeemService

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.redeemViaAVS,
                action: /Action.pharmacyRedeemViaAVS
            ) {
                PharmacyRedeemDomain()
                    .dependency(\.redeemInputValidator, avsMessageValidator)
                    .dependency(\.redeemService, avsRedeemService)
            }
            Scope(
                state: /State.redeemViaErxTaskRepository,
                action: /Action.pharmacyRedeemViaErxTaskRepository
            ) {
                PharmacyRedeemDomain()
                    .dependency(\.redeemInputValidator, erxTaskOrderValidator)
                    .dependency(\.redeemService, erxTaskRepositoryRedeemService)
            }
        }
    }

    struct State: Equatable {
        var erxTasks: [ErxTask]
        var pharmacyViewModel: PharmacyLocationViewModel
        var pharmacy: PharmacyLocation {
            pharmacyViewModel.pharmacyLocation
        }

        var pharmacyRedeemState: PharmacyRedeemDomain.State?
        // If there was a login before the profile is locked to that
        var wasProfileAuthenticatedBefore = false
        var reservationService: RedeemServiceOption = .noService
        var shipmentService: RedeemServiceOption = .noService
        var deliveryService: RedeemServiceOption = .noService
        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        /// load current profile
        case loadCurrentProfile
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
        /// Changes favorite state of pharmacy or creates a local pharmacy
        case toggleIsFavorite
        /// Changes favorite state of pharmacy or creates a local pharmacy
        case setIsFavorite(_ newState: Bool)
        /// Handles navigation
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)
        /// Internal actions
        case response(Response)
        /// delegate actions
        case delegate(Delegate)

        enum Response: Equatable {
            /// response of `loadCurrentProfile` action
            case currentProfileReceived(Profile?)
            /// response of loading certificates (loaded in `currentProfileReceived`)
            case avsCertificatesReceived(Result<[X509], PharmacyRepositoryError>)
            /// response of `toggleIsFavorite` action
            case toggleIsFavoriteReceived(Result<PharmacyLocationViewModel, PharmacyRepositoryError>)
        }

        enum Delegate: Equatable {
            /// Closes and stores the PharmacyRedeemDomain.State
            case changePharmacy(PharmacyRedeemDomain.State)
            /// Closes the details page
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.feedbackReceiver) var feedbackReceiver

    var body: some ReducerProtocolOf<Self> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadCurrentProfile:
            return .publisher(
                userSession.profile()
                    .first()
                    .catchToPublisher()
                    .map { result in
                        if case let .success(profile) = result {
                            return Action.response(.currentProfileReceived(profile))
                        }
                        return Action.response(.currentProfileReceived(nil))
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.currentProfileReceived(profile)):
            state.wasProfileAuthenticatedBefore = profile?.isLinkedToInsuranceId ?? false
            if state.pharmacy.hasAVSEndpoints {
                // load certificate for avs service
                return .publisher(
                    pharmacyRepository.loadAvsCertificates(for: state.pharmacyViewModel.id)
                        .first()
                        .receive(on: schedulers.main)
                        .catchToPublisher()
                        .map { result in Action.response(.avsCertificatesReceived(result)) }
                        .eraseToAnyPublisher
                )
            } else {
                let provider = RedeemOptionProvider(
                    wasAuthenticatedBefore: state.wasProfileAuthenticatedBefore,
                    pharmacy: state.pharmacy
                )
                state.reservationService = provider.reservationService
                state.shipmentService = provider.shipmentService
                state.deliveryService = provider.deliveryService
                return .none
            }
        case let .response(.avsCertificatesReceived(result)):
            switch result {
            case let .success(certificates):
                state.pharmacyViewModel.pharmacyLocation.avsCertificates = certificates
            default:
                break
            }

            let provider = RedeemOptionProvider(
                wasAuthenticatedBefore: state.wasProfileAuthenticatedBefore,
                pharmacy: state.pharmacy
            )
            state.reservationService = provider.reservationService
            state.shipmentService = provider.shipmentService
            state.deliveryService = provider.deliveryService
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
               let number = URL(phoneNumber: phone) {
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
               let url = Self.createEmailUrl(to: email) {
                UIApplication.shared.open(url)
            }
            return .none
        case let .showPharmacyRedeemOption(option):
            let redeemState = PharmacyRedeemDomain.State(
                redeemOption: option,
                erxTasks: state.pharmacyRedeemState?.erxTasks ?? state.erxTasks,
                pharmacy: state.pharmacy,
                selectedErxTasks: state.pharmacyRedeemState?.selectedErxTasks ?? Set(state.erxTasks)
            )
            switch option {
            case .onPremise:
                state.destination = state.reservationService.destination(with: redeemState)
            case .delivery:
                state.destination = state.deliveryService.destination(with: redeemState)
            case .shipment:
                state.destination = state.shipmentService.destination(with: redeemState)
            }
            state.pharmacyRedeemState = nil
            return .none
        case .destination(.presented(.pharmacyRedeemViaErxTaskRepository(action: .close))),
             .destination(.presented(.pharmacyRedeemViaAVS(action: .close))):
            state.destination = nil
            return .run { send in
                // swiftlint:disable:next todo
                // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                try await schedulers.main.sleep(for: 0.1)
                await send(.delegate(.close))
            }
        case let .destination(.presented(.pharmacyRedeemViaAVS(action: .changePharmacy(saveState)))),
             let .destination(.presented(.pharmacyRedeemViaErxTaskRepository(action: .changePharmacy(saveState)))):
            state.destination = nil
            return .send(.delegate(.changePharmacy(saveState)))
        case .toggleIsFavorite:
            var pharmacyViewModel = state.pharmacyViewModel
            pharmacyViewModel.pharmacyLocation.isFavorite.toggle()
            return .publisher(
                pharmacyRepository.save(pharmacy: pharmacyViewModel.pharmacyLocation)
                    .first()
                    .receive(on: schedulers.main.animation())
                    .map { _ in pharmacyViewModel }
                    .catchToPublisher()
                    .map { .response(.toggleIsFavoriteReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .setIsFavorite(value):
            var pharmacyViewModel = state.pharmacyViewModel
            guard value != pharmacyViewModel.pharmacyLocation.isFavorite else {
                // give haptic feedback even if nothing actually changed
                feedbackReceiver.hapticFeedbackSuccess()
                return .none
            }
            pharmacyViewModel.pharmacyLocation.isFavorite = value
            return .publisher(
                pharmacyRepository.save(pharmacy: pharmacyViewModel.pharmacyLocation)
                    .first()
                    .receive(on: schedulers.main.animation())
                    .map { _ in pharmacyViewModel }
                    .catchToPublisher()
                    .map { .response(.toggleIsFavoriteReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .response(.toggleIsFavoriteReceived(result)):
            switch result {
            case let .success(viewModel):
                feedbackReceiver.hapticFeedbackSuccess()
                state.pharmacyViewModel = viewModel
            case let .failure(error):
                state.destination = .alert(.init(for: error))
            }
            return .none
        case .destination,
             .delegate,
             .setNavigation:
            return .none
        }
    }
}

extension PharmacyDetailDomain {
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
    func destination(with state: PharmacyRedeemDomain.State) -> PharmacyDetailDomain.Destinations.State? {
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
        static let store = Store(
            initialState: state
        ) { PharmacyDetailDomain()
        }
    }
}
