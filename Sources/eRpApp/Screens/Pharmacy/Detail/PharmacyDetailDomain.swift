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

@Reducer
struct PharmacyDetailDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<PharmacyRedeemDomain.State>)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case toast(ToastState<Toast>)

        enum Toast: Equatable {}
    }

    @ObservableState
    struct State: Equatable {
        /// A storage for the prescriptions that have been loaded from the repository
        @Shared var prescriptions: [Prescription]
        /// A storage for the prescriptions that have been selected to be redeemed or are loaded from this domain
        @Shared var selectedPrescriptions: [Prescription]
        /// View can be called within the redeeming process or from the tab-bar.
        /// Boolean is true when called within redeeming process
        var inRedeemProcess: Bool
        /// View can be shown as sheet inside order details
        var inOrdersMessage: Bool
        var pharmacyViewModel: PharmacyLocationViewModel
        var pharmacy: PharmacyLocation {
            pharmacyViewModel.pharmacyLocation
        }

        var hasRedeemableTasks = false
        /// Boolean for handling the different navigation paths
        var onMapView = false

        // Child domain states
        var serviceOptionState: ServiceOptionDomain.State

        @Presents var destination: Destination.State?

        init(
            prescriptions: Shared<[Prescription]>,
            selectedPrescriptions: Shared<[Prescription]>,
            inRedeemProcess: Bool,
            inOrdersMessage: Bool = false,
            pharmacyViewModel: PharmacyLocationViewModel,
            hasRedeemableTasks: Bool = false,
            availableServiceOptions: Set<RedeemOption> = [],
            onMapView: Bool = false,
            destination: Destination.State? = nil,
            serviceOptionState: ServiceOptionDomain.State? = nil
        ) {
            _prescriptions = prescriptions
            _selectedPrescriptions = selectedPrescriptions
            self.inRedeemProcess = inRedeemProcess
            self.inOrdersMessage = inOrdersMessage
            self.pharmacyViewModel = pharmacyViewModel
            self.hasRedeemableTasks = hasRedeemableTasks
            self.onMapView = onMapView
            self.destination = destination

            self.serviceOptionState = serviceOptionState ?? .init(
                prescriptions: prescriptions,
                selectedOption: nil,
                availableOptions: availableServiceOptions
            )
        }
    }

    enum Action: Equatable {
        /// load current profile & load local prescriptions
        case task
        /// Opens Map App with pharmacy location
        case openMapApp
        /// Opens the Phone App with pharmacy phone number
        case openPhoneApp
        /// Opens a Browser app with pharmacy website
        case openBrowserApp
        /// Opens Mail app with pharmacy email address
        case openMailApp
        /// Changes favorite state of pharmacy or creates a local pharmacy
        case toggleIsFavorite
        /// Changes favorite state of pharmacy or creates a local pharmacy
        case setIsFavorite(_ newState: Bool)
        /// Handles navigation
        case destination(PresentationAction<Destination.Action>)
        /// Internal actions
        case response(Response)
        /// delegate actions
        case delegate(Delegate)

        // Child Domain Actions
        case serviceOption(ServiceOptionDomain.Action)

        enum Response: Equatable {
            /// response of `toggleIsFavorite` action
            case toggleIsFavoriteReceived(Result<PharmacyLocationViewModel, PharmacyRepositoryError>)
            /// response of `prescriptionRepository.loadLocal()`
            case loadLocalPrescriptionsReceived(Result<[Prescription], PrescriptionRepositoryError>)
            /// response of `redeemOrderService.provider`
            case redeemOptionProviderReceived(RedeemOptionProvider)
        }

        enum Delegate: Equatable {
            /// Closes and stores the PharmacyRedeemDomain.State
            case changePharmacy(PharmacyRedeemDomain.State)
            /// Pushes PharmacyRedeemView on NavigationStack with required properties
            case redeem(
                prescriptions: [Prescription],
                selectedPrescriptions: [Prescription],
                pharmacy: PharmacyLocation,
                option: RedeemOption
            )
            /// Closes the details page
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.redeemOrderService) var redeemOrderService: RedeemOrderService
    @Dependency(\.feedbackReceiver) var feedbackReceiver
    @Dependency(\.prescriptionRepository) var prescriptionRepository: PrescriptionRepository
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar

    var body: some ReducerOf<Self> {
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
                loadPrescriptionsPublisher(),
                .run { [pharmacy = state.pharmacy] send in
                    let provider = try await redeemOrderService.redeemOptionProvider(pharmacy: pharmacy)
                    await send(.response(.redeemOptionProviderReceived(provider)))
                }
            )
        case let .response(.loadLocalPrescriptionsReceived(result)):
            switch result {
            case let .success(prescriptions):
                state.prescriptions = prescriptions.filter(\.isRedeemable)
                state.hasRedeemableTasks = !state.prescriptions.isEmpty
            case .failure:
                state.prescriptions = []
            }
            return .none
        case let .response(.redeemOptionProviderReceived(provider)):
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
            state.serviceOptionState.redeemOptionProvider = provider
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
        case let .serviceOption(.redeemOptionTapped(option)):
            if !state.hasRedeemableTasks {
                state.destination = .toast(ToastStates.noErxTask)
                return .none
            }

            state.destination = nil
            state.serviceOptionState.selectedOption = nil
            // swiftlint:disable closure_parameter_position
            return .run { [
                pharmacy = state.pharmacy,
                prescriptions = state.prescriptions,
                selectedPrescriptions = state.selectedPrescriptions
            ] send in
            // swiftlint:enable closure_parameter_position

            // disable navigation stack pop transition
            await UINavigationBar.setAnimationsEnabled(false)
            await send(.delegate(.redeem(
                prescriptions: prescriptions,
                selectedPrescriptions: selectedPrescriptions,
                pharmacy: pharmacy,
                option: option
            )))

            Task {
                try await schedulers.main.sleep(for: 0.01)
                // reenable navigation stack transition
                await UINavigationBar.setAnimationsEnabled(true)
            }
            }
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
        case .serviceOption,
             .destination,
             .delegate:
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

    enum ToastStates {
        typealias Action = PharmacyDetailDomain.Destination.Toast

        static let noErxTask: ToastState<Action> =
            .init(style: .simple(L10n.phaDetailTxtNoPrescriptionToast.key))
    }

    func loadPrescriptionsPublisher() -> Effect<PharmacyDetailDomain.Action> {
        .publisher(
            prescriptionRepository.loadLocal()
                .first()
                .receive(on: schedulers.main.animation())
                .catchToPublisher()
                .map { Action.response(.loadLocalPrescriptionsReceived($0)) }
                .eraseToAnyPublisher
        )
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

        static let prescriptions = [Prescription.Dummies.prescriptionReady]

        static let state = State(
            prescriptions: Shared(prescriptions),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyViewModel
        )

        static let store = Store(
            initialState: state
        ) { PharmacyDetailDomain()
        }
    }
}
