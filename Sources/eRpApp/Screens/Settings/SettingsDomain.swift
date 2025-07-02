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
import IDP
import UIKit

// sourcery: CodedError = "039"
enum SettingsDomainError: Swift.Error, Equatable {
    // sourcery: errorCode = "01"
    case organDonorJumpError(OrganDonorJumpServiceError)
    // sourcery: errorCode = "02"
    case organDonorUnknownError
}

@Reducer // swiftlint:disable:next type_body_length
struct SettingsDomain {
    @ObservableState
    struct State: Equatable {
        var isDemoMode: Bool
        var profiles = ProfilesDomain.State(profiles: [], selectedProfileId: nil)
        var appVersion = AppVersion.current
        var trackerOptIn = false

        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case debug(DebugDomain)
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Destination.Alert>)
        // sourcery: AnalyticsScreen = healthCardPassword_forgotPin
        case healthCardPasswordForgotPin(HealthCardPasswordIntroductionDomain)
        // sourcery: AnalyticsScreen = healthCardPassword_setCustomPin
        case healthCardPasswordSetCustomPin(HealthCardPasswordIntroductionDomain)
        // sourcery: AnalyticsScreen = healthCardPassword_unlockCard
        case healthCardPasswordUnlockCard(HealthCardPasswordIntroductionDomain)
        //
        case appSecurity(AppSecurityDomain)
        // sourcery: AnalyticsScreen = settings_productImprovements_complyTracking
        case complyTracking(EmptyDomain)
        // sourcery: AnalyticsScreen = settings_legalNotice
        case legalNotice(EmptyDomain)
        // sourcery: AnalyticsScreen = settings_dataProtection
        case dataProtection(EmptyDomain)
        // sourcery: AnalyticsScreen = settings_openSourceLicence
        case openSourceLicence(EmptyDomain)
        // sourcery: AnalyticsScreen = settings_termsOfUse
        case termsOfUse(EmptyDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        case egk(OrderHealthCardDomain)
        // sourcery: AnalyticsScreen = profile
        case editProfile(EditProfileDomain)
        // sourcery: AnalyticsScreen = settings_newProfile
        case newProfile(NewProfileDomain)
        // sourcery: AnalyticsScreen = settings_medicationReminderList
        case medicationReminderList(MedicationReminderListDomain)

        enum Alert: Equatable {
            case dismiss
            case profile(SettingsDomain.Action)
            case openSettings
            case openDonorRegister
        }
    }

    enum Action: Equatable {
        case close
        case task
        case toggleTrackingTapped(Bool)
        case confirmedOptInTracking
        case toggleDemoModeSwitch(Bool)
        case profiles(action: ProfilesDomain.Action)
        case showChargeItemListFor(profileId: UserProfile.ID)
        case popToRootView
        case response(Response)
        case destination(PresentationAction<Destination.Action>)
        case showDebug
        case showMedicationReminderList
        case showAppSecurity

        case tappedLegalNotice
        case tappedDataProtection
        case tappedFOSS
        case tappedTermsOfUse

        case tappedEgk
        case tappedForgotPin
        case tappedCustomPin
        case tappedUnlockCard

        case tappedOpenOrganspenderegister

        case resetNavigation
        case languageSettingsTapped

        enum Response: Equatable {
            case trackerStatusReceived(Bool)
            case demoModeStatusReceived(Bool)
            case showChargeItemListReceived(UserProfile)
            case showAlert(SettingsDomainError)
        }
    }

    @Dependency(\.changeableUserSessionContainer) var changeableUserSessionContainer: UsersSessionContainer
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.tracker) var tracker: Tracker
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.organDonorJumpService) var organDonorJumpService: OrganDonorJumpService

    var body: some Reducer<State, Action> {
        Scope(state: \.profiles, action: \.profiles) {
            ProfilesDomain()
        }

        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .publisher(
                    tracker.optInPublisher
                        .map { .response(.trackerStatusReceived($0)) }
                        .eraseToAnyPublisher
                ),
                .publisher(
                    changeableUserSessionContainer.isDemoMode
                        .map { .response(.demoModeStatusReceived($0)) }
                        .eraseToAnyPublisher
                )
            )
        case let .response(.demoModeStatusReceived(isDemo)):
            state.isDemoMode = isDemo
            return .none
        case let .response(.trackerStatusReceived(value)):
            state.trackerOptIn = value
            return .none
        case .close:
            return .none
        // Demo-Mode
        case let .toggleDemoModeSwitch(isDemo):
            state.destination = .alert(.info(state.isDemoMode ? Self.demoModeOffAlertState : Self.demoModeOnAlertState))
            if isDemo {
                changeableUserSessionContainer.switchToDemoMode()
            } else {
                changeableUserSessionContainer.switchToStandardMode()
            }
            return .none

        // Tracking
        // [REQ:gemSpec_eRp_FdV:A_19088, A_19089-01#5, A_19092-01#4, A_19097-01#1] React to later opt-in or deactivation
        // of usage analytics
        // [REQ:BSI-eRp-ePA:O.Purp_5#2] Actual disabling of analytics
        // [REQ:gemSpec_eRp_FdV:A_19982#2] Opt out of analytics
        case let .toggleTrackingTapped(optIn):
            if optIn {
                // [REQ:gemSpec_eRp_FdV:A_19091-01#3] Show comply route to display analytics usage within settings
                state.destination = .complyTracking(.init())
            } else {
                // [REQ:gemSpec_eRp_FdV:A_20185,A_20187] OptOut for user
                state.trackerOptIn = false
                tracker.optIn = false
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090-01,A_19091-01#4] User confirms the opt in within settings
        // [REQ:BSI-eRp-ePA:O.Purp_5#4] User confirms the opt in within settings
        case .confirmedOptInTracking:
            state.trackerOptIn = true
            tracker.optIn = true
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.openSettings))):
            if let url = URL(string: UIApplication.openSettingsURLString) {
                resourceHandler.open(url)
            }
            return .none
        case .destination(.presented(.healthCardPasswordUnlockCard(.delegate(.navigateToSettings)))),
             .destination(.presented(.healthCardPasswordForgotPin(.delegate(.navigateToSettings)))),
             .destination(.presented(.healthCardPasswordSetCustomPin(.delegate(.navigateToSettings)))):
            state.destination = nil
            return .none
        case .destination(.presented(.healthCardPasswordUnlockCard)),
             .destination(.presented(.healthCardPasswordForgotPin)),
             .destination(.presented(.healthCardPasswordSetCustomPin)):
            return .none
        case .showMedicationReminderList:
            state.destination = .medicationReminderList(.init())
            return .none
        case .showDebug:
            state.destination = .debug(DebugDomain.State(trackingOptIn: tracker.optIn))
            return .none
        case .showAppSecurity:
            state.destination = .appSecurity(.init(availableSecurityOptions: []))
            return .none
        case .tappedLegalNotice:
            state.destination = .legalNotice(.init())
            return .none
        case .tappedDataProtection:
            state.destination = .dataProtection(.init())
            return .none
        case .tappedFOSS:
            state.destination = .openSourceLicence(.init())
            return .none
        case .tappedTermsOfUse:
            state.destination = .termsOfUse(.init())
            return .none
        case .tappedEgk:
            state.destination = .egk(.init())
            return .none
        case .tappedForgotPin:
            state.destination = .healthCardPasswordForgotPin(
                .init(
                    mode: .forgotPin
                )
            )
            return .none
        case .tappedCustomPin:
            state.destination = .healthCardPasswordSetCustomPin(
                .init(
                    mode: .setCustomPin
                )
            )
            return .none
        case .tappedUnlockCard:
            state.destination = .healthCardPasswordUnlockCard(
                .init(
                    mode: .unlockCard
                )
            )
            return .none
        case .tappedOpenOrganspenderegister:
            state.destination = .alert(.info(SettingsDomain.donorRegisterAlertState))
            return .none
        case .destination(.presented(.alert(.openDonorRegister))):
            return .run { send in
                do {
                    try await organDonorJumpService.jump()
                } catch let error as OrganDonorJumpServiceError {
                    await send(.response(.showAlert(SettingsDomainError.organDonorJumpError(error))))
                } catch {
                    await send(.response(.showAlert(SettingsDomainError.organDonorUnknownError)))
                }
            }
        case .resetNavigation:
            state.destination = nil
            return .none
        case .languageSettingsTapped:
            state.destination = .alert(.info(SettingsDomain.languageSettingsAlertState))
            return .none
        case .destination(.presented(.egk(.delegate(.close)))):
            state.destination = nil
            return .none
        case let .profiles(action: .delegate(delegateAction)):
            switch delegateAction {
            case let .showEditProfile(editProfileState):
                state.destination = .editProfile(editProfileState)
            case .showNewProfile:
                state.destination = .newProfile(.init(name: "", color: .blue))
            case let .alert(alert):
                state.destination = .alert(
                    alert.pullback { action in
                        .profile(.profiles(action: action))
                    }
                )
            }
            return .none
        case let .showChargeItemListFor(profileId):
            return .run { send in
                guard let profile = try await userProfileService.userProfilesPublisher()
                    .async(\.self)
                    .first(where: { $0.id == profileId })
                else { return }
                await send(.response(.showChargeItemListReceived(profile)))
            }
        case let .response(.showChargeItemListReceived(profile)):
            state.destination = .editProfile(.init(
                profile: profile,
                routeToChargeItemList: true
            ))
            return .none
        case let .response(.showAlert(error)):
            state.destination = .alert(.init(for: error))
            return .none
        case let .destination(.presented(.editProfile(.delegate(action)))):
            switch action {
            case .logout:
                return .send(.profiles(action: .registerListener))
            case .close:
                state.destination = nil
                return .none
            }
        case let .destination(.presented(.newProfile(.delegate(action)))):
            switch action {
            case .close:
                state.destination = nil
                return .none
            }
        case .popToRootView:
            state.destination = nil
            return .none
        case .destination,
             .profiles:
            return .none
        }
    }
}

extension SettingsDomain {
    static var languageSettingsAlertState: AlertState<Destination.Alert> =
        AlertState(
            title: { TextState(L10n.stgTxtLanguageSettingsAlertTitle) },
            actions: {
                ButtonState(action: .send(.openSettings)) {
                    TextState(L10n.stgBtnLanguageSettingsAlertOpenSettings)
                }
                ButtonState(role: .cancel, action: .send(.dismiss)) {
                    TextState(L10n.alertBtnOk)
                }
            },
            message: { TextState(L10n.stgTxtLanguageSettingsAlertDescription) }
        )

    static var demoModeOnAlertState: AlertState<Destination.Alert> = {
        AlertState(
            title: { TextState(L10n.stgTxtAlertTitleDemoMode) },
            actions: {
                ButtonState(role: .cancel, action: .send(.dismiss)) {
                    TextState(L10n.alertBtnOk)
                }
            },
            message: { TextState(L10n.stgTxtAlertMessageDemoModeOn) }
        )
    }()

    static var demoModeOffAlertState: AlertState<Destination.Alert> = {
        AlertState(
            title: { TextState(L10n.stgTxtAlertTitleDemoModeOff) },
            actions: {
                ButtonState(role: .cancel, action: .send(.dismiss)) {
                    TextState(L10n.alertBtnOk)
                }
            },
            message: { TextState(L10n.stgTxtAlertMessageDemoModeOff) }
        )
    }()

    static var donorRegisterAlertState: AlertState<Destination.Alert> =
        AlertState(
            title: { TextState(L10n.stgTxtDonorRegisterAlertTitle) },
            actions: {
                ButtonState(role: .cancel, action: .send(.dismiss)) {
                    TextState(L10n.stgConBtnOrganDonorAlertCancel)
                }
                ButtonState(action: .send(.openDonorRegister)) {
                    TextState(L10n.stgBtnDonorRegisterAlertOpen)
                }
            },
            message: { TextState(L10n.stgTxtDonorRegisterAlertMessage) }
        )
}

extension SettingsDomain {
    enum Dummies {
        static let state = State(
            isDemoMode: false,
            profiles: ProfilesDomain.Dummies.state,
            appVersion: AppVersion(productVersion: "1.0",
                                   buildNumber: "LOCAL BUILD",
                                   buildHash: "LOCAL BUILD")
        )

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<SettingsDomain> {
            Store(
                initialState: state
            ) {
                SettingsDomain()
            }
        }
    }
}
