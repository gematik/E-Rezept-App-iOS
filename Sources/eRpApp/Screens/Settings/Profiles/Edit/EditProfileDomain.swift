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

import AsyncHelpers
import Combine
import ComposableArchitecture
import ConsentService
import eRpKit
import eRpLocalStorage
import eRpResources
import FeatureCardWall
import FeatureEURedeem
import FeatureHelpers
import Foundation
import IDP

// swiftlint:disable type_body_length file_length
@Reducer
struct EditProfileDomain {
    @ObservableState
    struct State: Equatable {
        let profileId: UUID
        var name: String
        var acronym: String
        var fullName: String?
        var insurance: String?
        var can: String?
        var insuranceId: String?
        var image: ProfilePicture?
        var userImageData: Data?
        var color: ProfileColor
        var token: IDPToken?
        @Presents var destination: Destination.State?
        var insuranceType: Profile.InsuranceType
        var routeToChargeItemList = false
        var showCopySuccessInfo = false
        var insuranceName: String {
            if let insurance, !insurance.isEmpty {
                return insurance
            } else {
                switch insuranceType {
                case .gKV:
                    return L10n.stgTxtEditProfileLabelGkvInsurance.text
                case .pKV:
                    return L10n.stgTxtEditProfileLabelPkvInsurance.text
                case .federalKV:
                    return L10n.stgTxtEditProfileLabelFederalkvInsurance.text
                case .unknown:
                    return L10n.stgTxtEditProfileLabelUnknownInsurance.text
                }
            }
        }

        var isEURedeemable: Bool {
            @Shared(.euRedeemPrescriptionsFeature) var euRedeemPrescriptionsFeature: Bool
            return euRedeemPrescriptionsFeature
        }

        var euRedeemConsentCheck: ConsentService.CheckResult = .notGranted

        init(name: String,
             acronym: String,
             fullName: String?,
             insurance: String?,
             can: String?,
             insuranceId: String?,
             image: ProfilePicture?,
             userImageData _: Data?,
             color: ProfileColor,
             profileId: UUID,
             token: IDPToken? = nil,
             destination: EditProfileDomain.Destination.State? = nil,
             insuranceType: Profile.InsuranceType = .unknown) {
            self.name = name
            self.acronym = acronym
            self.fullName = fullName
            self.insurance = insurance
            self.can = can
            self.insuranceId = insuranceId
            self.image = image
            self.color = color
            self.profileId = profileId
            self.destination = destination
            self.token = token
            self.insuranceType = insuranceType
        }

        init(
            profile: UserProfile,
            routeToChargeItemList: Bool = false
        ) {
            profileId = profile.id
            name = profile.name
            acronym = profile.name.acronym()
            fullName = profile.fullName
            insurance = profile.insurance
            insuranceId = profile.insuranceId
            image = profile.image
            userImageData = profile.userImageData
            color = profile.color
            insuranceType = profile.profile.insuranceType
            self.routeToChargeItemList = routeToChargeItemList
        }
    }

    @Reducer
    enum Destination {
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = profile_auditEvents
        case auditEvents(AuditEventsDomain)
        // sourcery: AnalyticsScreen = profile_notificationChannels
        case notificationChannels(NotificationChannelsDomain)
        // sourcery: AnalyticsScreen = profile_registeredDevices
        case registeredDevices(RegisteredDevicesDomain)
        // sourcery: AnalyticsScreen = chargeItemList
        case chargeItemList(ChargeItemListDomain)
        // sourcery: AnalyticsScreen = cardWall
        case cardWall(CardWallIntroductionDomain)
        // sourcery: AnalyticsScreen = profile_insuranceDrawer
        case insuranceDrawer
        case euRedeemConsent(FeatureEURedeem.ConsentDomain)
        case editProfilePicture(EditProfilePictureDomain)

        enum Alert: Equatable {
            case dismiss
            case cardWall
            case confirmDeleteProfile
        }
    }

    enum Action: BindableAction, Equatable {
        case task
        case onAppear
        case binding(BindingAction<State>)
        case showDeleteProfileAlert
        case changeInsurance
        case copyKVNR(String)
        case copyCompleted
        case setUserToGKVInsured
        case setUserToPKVInsured
        case setUserToFederalInsured
        case login
        case relogin
        case showCardWall
        case showEURedeemConsent

        case destination(PresentationAction<Destination.Action>)
        case resetNavigation
        case registeredDevicesTapped
        case auditEventsTapped
        case pushNotificationsTapped
        case chargeItemListTapped
        case editProfilePictureTapped
        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case updateProfileReceived(Result<Bool, LocalStoreError>)
            case canReceived(String?)
            case tokenReceived(IDPToken?)
            case profileReceived(Result<Profile?, LocalStoreError>)
            case euConsentCheckReceived(Result<ConsentService.CheckResult, ConsentService.Error>)
        }

        enum Delegate {
            case close
            case logout
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore

    /// Use changebaleUserSesisonContainer to set the correct user session for demo mode
    var userDataStore: UserDataStore {
        changeableUserSessionContainer.userSession.localUserStore
    }

    @Dependency(\.changeableUserSessionContainer) var changeableUserSessionContainer
    @Dependency(\.profileSecureDataWiper) var profileSecureDataWiper: ProfileSecureDataWiper
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.router) var router: Routing
    @Dependency(\.pasteboardService) var pasteboardService: PasteboardService
    @Dependency(\.hapticFeedbackGenerator) var hapticFeedback
    @Dependency(\.consentService) var consentService: ConsentService

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                subscribeToTokenUpdates(for: state.profileId),
                subscribeToCanUpdates(with: state.profileId),
                .publisher(
                    profileDataStore.fetchProfile(by: state.profileId)
                        .first()
                        .catchToPublisher()
                        .map(Action.Response.profileReceived)
                        .map(Action.response)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                ),
                .run { [profileId = state.profileId] send in
                    do {
                        let result = try await consentService.checkForConsent(
                            category: .euDispense,
                            profileID: profileId
                        )
                        await send(.response(.euConsentCheckReceived(.success(result))))
                    } catch let error as ConsentService.Error {
                        await send(.response(.euConsentCheckReceived(.failure(error))))
                    }
                }
            )
        case .onAppear:
            // Routing needs to be split from EditProfileView on
            // downwards the navigation tree and delayed to work properly
            if state.routeToChargeItemList {
                state.routeToChargeItemList = false
                return .run { send in
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.chargeItemListTapped)
                }
            }
            return .none
        case let .response(.tokenReceived(token)):
            state.token = token
            return .none
        case let .response(.canReceived(can)):
            state.can = can
            return .none
        case let .response(.profileReceived(.success(profile))):
            state.image = profile?.image.viewModelPicture
            state.userImageData = profile?.userImageData
            state.color = profile?.color.viewModelColor ?? .grey
            state.insuranceId = profile?.insuranceId
            state.insurance = profile?.insurance
            state.fullName = profile?.fullName
            return .none
        case .response(.profileReceived(.failure)):
            return .none
        case .binding(\.name):
            let name = state.name.trimmed()
            state.name = name
            state.acronym = name.acronym()

            guard name.lengthOfBytes(using: .utf8) > 0 else { return .none }

            return .publisher(
                updateProfile(with: state.profileId) { profile in
                    profile.name = name
                    profile.shouldAutoUpdateNameAtNextLogin = false
                }
                .map(Action.Response.updateProfileReceived)
                .map(Action.response)
                .eraseToAnyPublisher
            )
        case .binding(\.color):
            let color = state.color.erxColor
            return .publisher(
                updateProfile(with: state.profileId) { profile in
                    profile.color = color
                }
                .map(Action.Response.updateProfileReceived)
                .map(Action.response)
                .eraseToAnyPublisher
            )
        case let .copyKVNR(kvnr):
            pasteboardService.copy(kvnr)
            hapticFeedback.success()
            state.showCopySuccessInfo = true
            return .run { send in
                // wait for 3 second to set showCopySuccessInfo to false
                try await schedulers.main.sleep(for: 3)
                await send(.copyCompleted)
            }
        case .copyCompleted:
            state.showCopySuccessInfo = false
            return .none
        case .changeInsurance:
            state.destination = .insuranceDrawer
            return .none
        case .showCardWall:
            state.destination = .cardWall(.init(isNFCReady: true, profileId: state.profileId))
            return .none
        case .showEURedeemConsent:
            let constentType: ConsentDomain.ConsentType = {
                switch state.euRedeemConsentCheck {
                case .granted:
                    return .granted
                case .notGranted:
                    return .notGranted
                case .notAuthenticated, .error:
                    return .unknown
                }
            }()
            state.destination = .euRedeemConsent(.init(
                profileID: state.profileId,
                consentType: constentType
            ))
            return .none
        case let .response(.euConsentCheckReceived(.success(result))):
            state.euRedeemConsentCheck = result
            return .none
        case let .response(.euConsentCheckReceived(.failure(error))):
            state.destination = .alert(.init(for: error, title: L10n.errTitleGeneric))
            return .none
        case let .destination(.presented(.euRedeemConsent(.delegate(action)))):
            switch action {
            case .consentAccepted, .consentDeclined, .close:
                state.destination = nil
                return .none
            case .showCardWall:
                state.destination = .alert(AlertStates.grantConsentServiceNotAuthenticated)
                return .none
            }
        case .destination(.presented(.alert(.cardWall))):
            return .run { send in
                await send(.showCardWall)
            }
        case .destination(.presented(.cardWall(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.dismiss):
            if case .cardWall = state.destination {
                return .run { [profileId = state.profileId] send in
                    do {
                        let result = try await consentService.checkForConsent(
                            category: .euDispense,
                            profileID: profileId
                        )
                        await send(.response(.euConsentCheckReceived(.success(result))))
                    } catch let error as ConsentService.Error {
                        await send(.response(.euConsentCheckReceived(.failure(error))))
                    }
                }
            }
            return .none
        case .setUserToGKVInsured:
            state.insuranceType = .gKV
            return changeInsurance(for: .gKV, with: state.profileId)
        case .setUserToPKVInsured:
            state.insuranceType = .pKV
            return changeInsurance(for: .pKV, with: state.profileId)
        case .setUserToFederalInsured:
            state.insuranceType = .federalKV
            return changeInsurance(for: .federalKV, with: state.profileId)
        case .showDeleteProfileAlert:
            state.destination = .alert(AlertStates.deleteProfile)
            return .none
        case .destination(.presented(.alert(.confirmDeleteProfile))):
            return .publisher(
                deleteProfile(with: state.profileId)
                    .map { result in
                        switch result {
                        case .success: return Action.delegate(.close)
                        case let .failure(error): return Action.response(.updateProfileReceived(.failure(error)))
                        }
                    }
                    .eraseToAnyPublisher
            )
        case .response(.updateProfileReceived(.success)):
            return .none
        case let .response(.updateProfileReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none
        // [REQ:BSI-eRp-ePA:O.Auth_14#3|6] The domain accepts the intent and wipes tokens and other login related data
        case .delegate(.logout):
            state.token = nil
            // [REQ:gemSpec_IDP_Frontend:A_20499-01#1] Call the SSO_TOKEN removal upon manual logout
            return .run { [profileId = state.profileId] _ in
                try await profileSecureDataWiper.wipeSecureData(of: profileId).async()
            }
        case .login:
            return .run { send in
                await send(.showCardWall)
            }
        case .relogin:
            state.token = nil
            return .run { [profileId = state.profileId] send in
                try await profileSecureDataWiper.wipeSecureData(of: profileId).async()
                await send(.showCardWall)
            }
        case .resetNavigation:
            state.destination = nil
            return .none
        case .registeredDevicesTapped:
            state.destination = .registeredDevices(.init(profileId: state.profileId))
            return .none
        case .auditEventsTapped:
            state.destination = .auditEvents(.init(profileUUID: state.profileId))
            return .none
        case .pushNotificationsTapped:
            // Registration is persisted per profile; derive `isRegistered` from it so a pusher
            // registered in a previous session is recognised (otherwise the consent dialog would
            // be shown again and channel states would not be loaded on entry).
            @Shared(.pushNotificationRegistrations) var registrations
            let isRegistered = registrations[state.profileId.uuidString] != nil
            state.destination = .notificationChannels(
                .init(profileId: state.profileId, isRegistered: isRegistered)
            )
            return .none
        case .chargeItemListTapped:
            state.destination = .chargeItemList(.init(profileId: state.profileId))
            return .none
        case .editProfilePictureTapped:
            state.destination = .editProfilePicture(.init(
                profileId: state.profileId,
                color: state.color,
                picture: state.image ?? .none,
                userImageData: state.userImageData ?? Data(),
                isFullScreenPresented: true
            ))
            return .none
        case .destination(.presented(.auditEvents)),
             .destination(.presented(.registeredDevices)),
             .destination(.presented(.chargeItemList)),
             .destination(.presented(.editProfilePicture)):
            return .none
        case .destination,
             .binding,
             .delegate:
            return .none
        }
    }
}

extension EditProfileDomain {
    func subscribeToTokenUpdates(for profileId: UUID) -> Effect<Action> {
        .publisher(
            userSessionProvider.userSession(for: profileId).secureUserStore.token
                .receive(on: schedulers.main.animation())
                .map(Action.Response.tokenReceived)
                .map(Action.response)
                .eraseToAnyPublisher
        )
    }

    func subscribeToCanUpdates(with profileId: UUID) -> Effect<Action> {
        .publisher(
            userSessionProvider.userSession(for: profileId).secureUserStore.can
                .receive(on: schedulers.main.animation())
                .map(Action.Response.canReceived)
                .map(Action.response)
                .eraseToAnyPublisher
        )
    }

    func changeInsurance(for type: Profile.InsuranceType, with profileId: UUID) -> Effect<Action> {
        .concatenate(
            .publisher(
                updateProfile(with: profileId) { profile in
                    profile.insuranceType = type
                    profile.insurance = nil
                    profile.insuranceId = nil
                    profile.insuranceIK = nil
                }
                .map(Action.Response.updateProfileReceived)
                .map(Action.response)
                .eraseToAnyPublisher
            ),
            .send(.relogin)
        )
    }

    func updateProfile(
        with profileId: UUID,
        mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Result<Bool, LocalStoreError>, Never> {
        profileDataStore
            .update(profileId: profileId, mutating: mutating)
            .receive(on: schedulers.main)
            .catchToPublisher()
    }

    func deleteProfile(
        with profileId: UUID
    ) -> AnyPublisher<Result<Bool, LocalStoreError>, Never> {
        let profile = Profile(name: "",
                              identifier: profileId,
                              insuranceId: nil,
                              color: .blue,
                              lastAuthenticated: nil,
                              erxTasks: [])

        return
            Just(true)
                .setFailureType(to: LocalStoreError.self)
                .createProfileIfOnlyOneProfileIsLeft(profileDataStore: profileDataStore)
                .setNewActiveProfileIfNecessary(profileId: profileId,
                                                profileDataStore: profileDataStore,
                                                userDataStore: userDataStore)
                .flatMap { _ in
                    self.profileSecureDataWiper.wipeSecureData(of: profile)
                }
                .flatMap { _ -> AnyPublisher<Bool, LocalStoreError> in
                    profileDataStore.delete(profiles: [profile])
                }
                .receive(on: schedulers.main)
                .catchToPublisher()
    }
}

extension Publisher where Failure == LocalStoreError, Output == Bool {
    func createProfileIfOnlyOneProfileIsLeft(profileDataStore: ProfileDataStore)
        -> AnyPublisher<Bool, LocalStoreError> {
        profileDataStore
            .listAllProfiles()
            .first()
            // Create a new profile, if this deletion would result in no profile available
            .flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
                if profiles.count == 1 {
                    let profile = Profile(name: L10n.onbProfileName.text,
                                          identifier: UUID(),
                                          insuranceId: nil,
                                          color: .blue,
                                          lastAuthenticated: nil,
                                          erxTasks: [],
                                          shouldAutoUpdateNameAtNextLogin: true)
                    return profileDataStore.save(profiles: [profile])
                }
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setNewActiveProfileIfNecessary(
        profileId: UUID,
        profileDataStore: ProfileDataStore,
        userDataStore: UserDataStore
    ) -> AnyPublisher<Bool, LocalStoreError> {
        // Select a new profile if the selected profile gets deleted
        flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
            userDataStore.selectedProfileId
                .first()
                .flatMap { selectedProfileId -> AnyPublisher<Bool, LocalStoreError> in
                    if selectedProfileId == profileId {
                        return profileDataStore
                            .listAllProfiles()
                            .first()
                            .flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
                                let profileIds = profiles
                                    .map(\.id)
                                    .filter { $0 != selectedProfileId }

                                guard let newSelectedProfileId = profileIds.first else {
                                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                                }
                                userDataStore.set(selectedProfileId: newSelectedProfileId)

                                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

extension EditProfileDomain {
    enum AlertStates {
        typealias Action = EditProfileDomain.Destination.Alert

        static let deleteProfile: ErpAlertState<Action> = .init(
            title: L10n.stgTxtEditProfileDeleteConfirmationTitle,
            actions: {
                ButtonState(role: .destructive, action: .confirmDeleteProfile) {
                    .init(L10n.dtlTxtDeleteYes)
                }
                ButtonState(role: .cancel) {
                    .init(L10n.stgBtnEditProfileDeleteAlertCancel)
                }
            },
            message: L10n.stgTxtEditProfileDeleteConfirmationMessage
        )

        static let grantConsentServiceNotAuthenticated = ErpAlertState<Action>(
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
    }
}

extension EditProfileDomain {
    enum Dummies {
        static let onlineState: State = {
            var state = State(profile: UserProfile.Dummies.profileA)
            state.token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "")
            return state
        }()

        static let store = Store(
            initialState: onlineState
        ) {
            EditProfileDomain()
        }
    }
}

extension EditProfileDomain.Destination.State: Equatable {}
extension EditProfileDomain.Destination.Action: Equatable {}
// swiftlint:enable type_body_length
