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

import ComposableArchitecture
import ConsentService
import eRpKit
import eRpStyleKit
import ErxTaskRepository
import FeatureCardWall
import FeatureHelpers
import Foundation
import Profiles

// MARK: - EURedeemSelectionDomain

/// Domain for EU prescription redemption selection screen
@Reducer
public struct EURedeemSelectionDomain {
    /// Validation states for redeeming
    public enum Validation {
        /// Empty prescription selection
        case emptyPrescription
        /// Empty country selection
        case emptyCountry
        /// valid selection
        case valid
    }

    /// State for EU redemption selection
    @ObservableState
    public struct State: Equatable {
        /// Available prescriptions for redemption
        @Shared public var prescriptions: [EUPrescription]
        /// Currently selected prescriptions
        @Shared public var selectedPrescriptions: [EUPrescription]
        /// Currently selected country
        public var selectedCountry: Country?
        /// Validation state
        public var validation: Validation = .valid
        /// Destination for navigation and modals
        @Presents public var destination: Destination.State?

        /// Selected user profile ID
        @Shared(.selectedProfileId) var profileID

        public init(
            prescriptions: Shared<[EUPrescription]> = Shared(value: []),
            selectedCountry: Country? = nil,
            validation: Validation = .valid

        ) {
            _prescriptions = prescriptions
            _selectedPrescriptions = Shared(value: prescriptions.wrappedValue.filter {
                $0.isSetEURedeemableByPatient && $0.status == .ready
            })
            self.selectedCountry = selectedCountry
            self.validation = validation
        }
    }

    /// Actions for EU redemption selection
    public enum Action: Equatable {
        /// Checks state of the users consent
        case task
        /// Destination actions
        /// Redeem button was tapped
        case redeemButtonTapped
        case destination(PresentationAction<Destination.Action>)
        /// Delegate actions
        case delegate(Delegate)
        case response(Response)
    }

    public enum Delegate: Equatable {
        /// Select country button was tapped
        case selectCountryButtonTapped
        /// Select prescriptions button was tapped
        case selectPrescriptionsButtonTapped
        /// Select instruction button was tapped
        case selectInstructionButtonTapped(countryCode: String?)
        /// Redeem prescriptions after validation
        case redeemPrescriptions
        /// Close button was tapped
        case close
        /// Back button was tapped
        case back
        /// Unlock card from settings
        case unlockCardClose
    }

    public enum Response: Equatable {
        case consentCheckReceived(ConsentService.CheckResult)
        case prescriptionReceived(Result<[EUPrescription], ErxRepositoryError>)
    }

    /// Navigation and modal destinations
    @Reducer
    public enum Destination {
        /// Consent screen
        case consent(ConsentDomain)
        // sourcery: AnalyticsScreen = cardWall
        /// CardWall screen
        case cardWall(CardWallIntroductionDomain)
        // sourcery: AnalyticsScreen = alert
        /// Alert screen
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        public enum Alert: Equatable {
            case dismiss
            case cardWall
            case selectCountry
        }
    }

    /// Initialize the domain
    public init() {}

    @Dependency(\.consentService) var consentService: ConsentService
    @Dependency(\.profilesStore) var profileStore: ProfilesStore
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.validation = .valid
            return .run { [profileID = state.profileID] send in
                let result = try await consentService.checkForConsent(category: .euDispense, profileID: profileID)
                await send(.response(.consentCheckReceived(result)))

                do {
                    let prescriptions = try await erxTaskRepository.loadLocalAllTasks(profileId: profileID).async()
                    await send(.response(.prescriptionReceived(.success(
                        prescriptions.map { EUPrescription(erxTask: $0) }
                    ))))
                } catch let error as ErxRepositoryError {
                    await send(.response(.prescriptionReceived(.failure(error))))
                }
            }
        case .redeemButtonTapped:
            if state.selectedPrescriptions.isEmpty {
                state.validation = .emptyPrescription
                return .none
            }
            if state.selectedCountry == nil {
                state.validation = .emptyCountry
                return .none
            }
            state.validation = .valid
            return .send(.delegate(.redeemPrescriptions))
        case let .response(.consentCheckReceived(result)):
            switch result {
            case .granted:
                state.destination = nil
            case .notGranted:
                state.destination = .consent(.init(profileID: state.profileID))
            case .notAuthenticated:
                state.destination = .alert(AlertStates.grantConsentServiceNotAuthenticated)
            case let .error(error):
                state.destination = .alert(.init(for: error, title: L10n.errTitleGeneric))
            }
            return .none
        case let .response(.prescriptionReceived(.success(euPrescriptions))):
            state.$prescriptions.withLock { $0 = euPrescriptions }
            state.$selectedPrescriptions.withLock {
                $0 = euPrescriptions.filter {
                    $0.isSetEURedeemableByPatient && $0.status == .ready
                }
            }
            return .none
        case let .response(.prescriptionReceived(.failure(error))):
            state.destination = .alert(.init(for: error, title: L10n.errTitleGeneric))
            return .none
        case let .destination(.presented(.consent(.delegate(action)))):
            switch action {
            case .consentAccepted:
                state.destination = nil
                return .none
            case .consentDeclined, .close:
                state.destination = nil
                return .send(.delegate(.close))
            case .showCardWall:
                state.destination = .cardWall(.init(isNFCReady: true, profileId: state.profileID))
                return .none
            }
        case .destination(.presented(.alert(.cardWall))):
            state.destination = .cardWall(.init(isNFCReady: true, profileId: state.profileID))
            return .none
        case .destination(.presented(.alert(.dismiss))):
            return .run { send in
                await send(.delegate(.close))
            }
        case .destination(.dismiss):
            if case .consent = state.destination {
                state.destination = nil
                return .run { send in
                    await send(.delegate(.back))
                }
            }
            return .none
        case let .destination(.presented(.cardWall(action: .delegate(delegate)))):
            switch delegate {
            case .close:
                state.destination = nil
                return .run { [profileID = state.profileID] send in
                    let result = try await consentService.checkForConsent(category: .euDispense, profileID: profileID)
                    await send(.response(.consentCheckReceived(result)))
                }
            case .unlockCardClose:
                return .send(.delegate(.unlockCardClose))
            }
        case .destination(.presented(.alert(.selectCountry))):
            return .send(.delegate(.selectCountryButtonTapped))
        case .destination,
             .delegate:
            return .none
        }
    }

    /// states of possible alerts
    public enum AlertStates {
        /// not logged in alert
        public static let grantConsentServiceNotAuthenticated = ErpAlertState<Destination.Alert>(
            title: L10n.euredeemSelectionTxtConsentNotLoggedInTitle,
            actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.errBtnCancel)
                }
                ButtonState(action: .cardWall) {
                    .init(L10n.erxBtnAlertLogin)
                }
            },
            message: L10n.euredeemSelectionTxtConsentNotLoggedInMessage
        )
        /// this alert shouldnt normally show, its only when the server didnt return a countryCode for selected country
        public static let noCountryCode = ErpAlertState<Destination.Alert>(
            title: { TextState(L10n.euredeemSelectionAlertNoCountryTitle) },
            actions: {
                ButtonState(role: .cancel) {
                    TextState(L10n.alertBtnOk)
                }
                ButtonState(action: .selectCountry) {
                    TextState(L10n.euredeemSelectionAlertNoCountrySelectCountry)
                }
            },
            message: {
                TextState(L10n.euredeemSelectionAlertNoCountryMessage)
            }
        )
    }
}

// MARK: - Dummies

extension EURedeemSelectionDomain {
    /// Mock data for testing and previews
    public enum Dummies {
        /// Sample prescriptions for testing
        public static let prescriptions: [EUPrescription] = [
            EUPrescription(erxTask: ErxTask(
                identifier: "1",
                status: .ready,
                flowType: .tPrescription,
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180).ISO8601Format(.iso8601),
                medication: ErxMedication(name: "Ibuprofen 600"),
                isEURedeemable: true
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "2",
                status: .ready,
                flowType: .tPrescription,
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180).ISO8601Format(.iso8601),
                medication: ErxMedication(name: "Acnatac Lösung 3mg/g"),
                isEURedeemable: true
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "3",
                status: .ready,
                flowType: .tPrescription,
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180).ISO8601Format(.iso8601),
                medication: ErxMedication(name: "Ibuprofen 10mg/g"),
                isEURedeemable: true
            )),
        ]

        /// Sample selected prescriptions for testing
        public static let selectedPrescriptions: [EUPrescription] = [
            prescriptions[0],
        ]

        /// Sample countries for testing
        public static let countries = [
            Country(id: "DE", name: "Deutschland", telematikId: "12312321"),
            Country(id: "ES", name: "Spanien", telematikId: "12312322"),
            Country(id: "FR", name: "Frankreich", telematikId: "12312323"),
        ]

        /// Sample state for testing
        public static let state = EURedeemSelectionDomain.State(
            prescriptions: Shared(value: prescriptions),
            selectedCountry: countries[1]
        )

        /// Sample store for testing
        public static let store = Store(initialState: state) {
            EURedeemSelectionDomain()
        }
    }
}

extension EURedeemSelectionDomain.Destination.State: Equatable {}
extension EURedeemSelectionDomain.Destination.Action: Equatable {}
