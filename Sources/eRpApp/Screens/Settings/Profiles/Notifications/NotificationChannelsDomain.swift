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

import CasePaths
import ComposableArchitecture
import eRpKit
import eRpResources
import Foundation
import UIKit // for UIApplication.openSettingsURLString

@Reducer
struct NotificationChannelsDomain {
    @ObservableState
    struct State: Equatable {
        let profileId: UUID
        var channels: [NotificationChannel]
        var isRegistered: Bool
        var isProcessing = false
        @Presents var alert: AlertState<Action.Alert>?

        init(
            profileId: UUID,
            isRegistered: Bool = false,
            channels: [NotificationChannel] = NotificationChannel.defaultChannels
        ) {
            self.profileId = profileId
            self.isRegistered = isRegistered
            self.channels = channels
        }

        struct NotificationChannel: Equatable, Identifiable {
            let id: ChannelID
            var value: Bool

            var name: String {
                id.displayName
            }

            static let defaultChannels: [NotificationChannel] = ChannelID.allCases
                .map { .init(id: $0, value: false) }
        }
    }

    /// User-facing notification toggle. The Fachdienst exposes 13 granular event-level channels
    /// (`GET /channels/v1`); we group them under 5 friendly toggles. Toggling a group applies the
    /// same subscription state to every Fachdienst `channel_id` it maps to.
    enum ChannelID: String, CaseIterable, Equatable {
        case newPrescription
        case newMessage
        case statusChange
        case newPharmacyInvoice
        case externalAccess

        /// The Fachdienst `channel_id`s controlled by this toggle. Every id here receives the same
        /// enabled/disabled state when the toggle is switched, and the toggle reads as "on" only when
        /// all of its channels are enabled server-side. Covers the full 13-channel FD contract.
        var fachdienstChannelIds: [String] {
            switch self {
            case .newPrescription:
                return ["erp.task.activate"]
            case .newMessage:
                return ["erp.communication.new"]
            case .statusChange:
                return [
                    "erp.task.accept",
                    "erp.task.close",
                    "erp.task.dispense",
                    "erp.task.reject",
                    "erp.task.abort",
                ]
            case .newPharmacyInvoice:
                return ["erp.chargeitem.create", "erp.chargeitem.update"]
            case .externalAccess:
                return [
                    "erp.task.vertreter",
                    "erp.eu.prescription.close",
                    "erp.eu.prescription.get",
                    "erp.eu.prescription.redeem",
                ]
            }
        }

        var displayName: String {
            switch self {
            case .newPrescription: return L10n.stgTxtNotificationChannelNewPrescription.text
            case .newMessage: return L10n.stgTxtNotificationChannelNewMessage.text
            case .statusChange: return L10n.stgTxtNotificationChannelStatusChange.text
            case .newPharmacyInvoice: return L10n.stgTxtNotificationChannelNewPharmacyInvoice.text
            case .externalAccess: return L10n.stgTxtNotificationChannelExternalAccess.text
            }
        }
    }

    enum Action: Equatable {
        case task
        /// A channel toggle was changed by the user.
        case channelToggled(id: ChannelID, enabled: Bool)
        case response(Response)
        case alert(PresentationAction<Alert>)

        enum Response: Equatable {
            /// Result of evaluating which consent dialog to present on entry.
            case presentConsent(authorizationDenied: Bool)
            case registered(NotificationChannelsDomain.RegistrationOutcome)
            /// Channel configuration finished; `success` reflects the outcome for the given channel.
            case channelConfigured(id: ChannelID, enabled: Bool, success: Bool)
            /// Current channel subscription states loaded from the Fachdienst on entry.
            case channelsLoaded([ChannelState])
        }

        @CasePathable
        enum Alert: Equatable {
            /// [REQ:gemF_PushNotification:A_27183] User consents to receiving push notifications
            case confirmEnable
            case decline
            /// [REQ:gemF_PushNotification:A_27183] User opens the system settings to enable notifications
            case openSettings
        }
    }

    /// Mirrors `PushNotificationRegistrationService.RegistrationResult` for use in `Equatable` actions.
    enum RegistrationOutcome: Equatable {
        case registered
        case notAuthenticated
        case permissionDenied
        case failed
    }

    @Dependency(\.pushNotificationRegistrationService) var registrationService
    @Dependency(\.apnsRegistrationService) var apnsRegistrationService
    @Dependency(\.openURLHandler) var openURLHandler

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                // [REQ:gemF_PushNotification:A_27182] Push notifications are disabled by default; the user
                // must actively consent via the dialog shown on entry per profile.
                let profileId = state.profileId
                if state.isRegistered {
                    // Already registered: load the current channel subscription states from the Fachdienst
                    // (GET /channels/{pushkey}) so the toggles reflect the server-side configuration.
                    return .run { send in
                        let states = try await registrationService.loadChannels(profileId)
                        await send(.response(.channelsLoaded(states)))
                    } catch: { _, _ in
                        // Fail silently for now: keep the last known toggle values on error/timeout.
                        // TODO: surface channel-load errors/timeouts to the user once error handling is defined // swiftlint:disable:this todo line_length
                    }
                }
                return .run { send in
                    let denied = await apnsRegistrationService.isAuthorizationDenied()
                    await send(.response(.presentConsent(authorizationDenied: denied)))
                }

            case let .response(.presentConsent(authorizationDenied)):
                // If the user previously denied notifications at the OS level, the app can no longer
                // re-prompt; point them to the system settings instead of the consent dialog.
                state.alert = authorizationDenied ? Self.settingsAlert : Self.consentAlert
                return .none

            case .alert(.presented(.confirmEnable)):
                state.isProcessing = true
                let profileId = state.profileId
                return .run { send in
                    let outcome: RegistrationOutcome
                    do {
                        switch try await registrationService.register(profileId) {
                        case .registered: outcome = .registered
                        case .notAuthenticated: outcome = .notAuthenticated
                        case .permissionDenied: outcome = .permissionDenied
                        }
                    } catch {
                        outcome = .failed
                    }
                    await send(.response(.registered(outcome)))
                }

            case .alert(.presented(.openSettings)):
                return .run { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        _ = await openURLHandler.open(url)
                    }
                }

            case .alert(.presented(.decline)), .alert(.dismiss):
                return .none

            case let .response(.registered(outcome)):
                state.isProcessing = false
                state.isRegistered = outcome == .registered
                // The user denied the OS-level prompt: guide them to the system settings.
                if outcome == .permissionDenied {
                    state.alert = Self.settingsAlert
                }
                return .none

            case let .channelToggled(id, enabled):
                guard let index = state.channels.firstIndex(where: { $0.id == id }) else { return .none }
                // Registration is gated by the consent dialog; if not registered, re-evaluate which to show.
                guard state.isRegistered else {
                    return .run { send in
                        let denied = await apnsRegistrationService.isAuthorizationDenied()
                        await send(.response(.presentConsent(authorizationDenied: denied)))
                    }
                }
                state.channels[index].value = enabled // optimistic
                let profileId = state.profileId
                let channelIds = id.fachdienstChannelIds
                return .run { send in
                    do {
                        try await registrationService.configureChannel(profileId, channelIds, enabled)
                        await send(.response(.channelConfigured(id: id, enabled: enabled, success: true)))
                    } catch {
                        await send(.response(.channelConfigured(id: id, enabled: enabled, success: false)))
                    }
                }

            case let .response(.channelConfigured(id, enabled, success)):
                // Revert the optimistic toggle only when the configure call failed.
                if !success, let index = state.channels.firstIndex(where: { $0.id == id }) {
                    state.channels[index].value = !enabled
                }
                return .none

            case let .response(.channelsLoaded(states)):
                // Reflect the server-side subscription state on the grouped toggles. A toggle reads as
                // "on" only when every Fachdienst channel it maps to is enabled; any disabled / not_set /
                // missing channel keeps it off (matching how toggling applies one state to the whole group).
                let statusById = Dictionary(states.map { ($0.id, $0.status) }) { first, _ in first }
                for index in state.channels.indices {
                    let groupIds = state.channels[index].id.fachdienstChannelIds
                    state.channels[index].value = groupIds.allSatisfy { statusById[$0] == .enabled }
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension NotificationChannelsDomain {
    static let consentAlert: AlertState<Action.Alert> = AlertState {
        TextState(L10n.stgTxtNotificationsConsentTitle)
    } actions: {
        ButtonState(role: .cancel, action: .decline) {
            TextState(L10n.stgBtnNotificationsConsentNo)
        }
        ButtonState(action: .confirmEnable) {
            TextState(L10n.stgBtnNotificationsConsentYes)
        }
    } message: {
        TextState(L10n.stgTxtNotificationsConsentMessage)
    }

    /// Shown when the user has already denied notifications at the OS level and must enable them in
    /// the system settings (the app can no longer present the permission prompt itself).
    static let settingsAlert: AlertState<Action.Alert> = AlertState {
        TextState(L10n.stgTxtNotificationsSettingsTitle)
    } actions: {
        ButtonState(role: .cancel, action: .decline) {
            TextState(L10n.stgBtnNotificationsConsentNo)
        }
        ButtonState(action: .openSettings) {
            TextState(L10n.stgBtnNotificationsSettingsOpen)
        }
    } message: {
        TextState(L10n.stgTxtNotificationsSettingsMessage)
    }
}

extension NotificationChannelsDomain {
    enum Dummies {
        static let state = State(profileId: UUID())

        static let store = Store(
            initialState: state
        ) {
            NotificationChannelsDomain()
        }
    }
}
