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
import ConcurrencyExtras
@testable import eRpFeatures
import Nimble
import UIKit
import XCTest

@MainActor
final class NotificationChannelsDomainTests: XCTestCase {
    let testProfileId = UUID()

    private static func index(
        of channelId: NotificationChannelsDomain.ChannelID,
        in state: NotificationChannelsDomain.State
    ) -> Int {
        state.channels.firstIndex { $0.id == channelId }! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Entry: which alert to present

    func testTask_notRegistered_authorizationNotDenied_presentsConsentAlert() async {
        let store = TestStore(initialState: NotificationChannelsDomain.State(profileId: testProfileId)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.apnsRegistrationService.isAuthorizationDenied = { false }
        }

        await store.send(.task)
        await store.receive(.response(.presentConsent(authorizationDenied: false))) { state in
            state.alert = NotificationChannelsDomain.consentAlert
        }
    }

    func testTask_notRegistered_authorizationDenied_presentsSettingsAlert() async {
        let store = TestStore(initialState: NotificationChannelsDomain.State(profileId: testProfileId)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.apnsRegistrationService.isAuthorizationDenied = { true }
        }

        await store.send(.task)
        await store.receive(.response(.presentConsent(authorizationDenied: true))) { state in
            state.alert = NotificationChannelsDomain.settingsAlert
        }
    }

    func testTask_alreadyRegistered_loadsChannelStatesAndUpdatesToggles() async {
        // A grouped toggle reads as "on" only when ALL of its Fachdienst channels are enabled:
        // - newPrescription (all its channels enabled) -> on
        // - statusChange (only one of its channels enabled) -> stays off
        let loaded: [ChannelState] =
            NotificationChannelsDomain.ChannelID.newPrescription.fachdienstChannelIds
                .map { ChannelState(id: $0, status: .enabled) }
                + [ChannelState(
                    id: NotificationChannelsDomain.ChannelID.statusChange.fachdienstChannelIds[0],
                    status: .enabled
                )]

        let store = TestStore(initialState: .init(profileId: testProfileId, isRegistered: true)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.loadChannels = { _ in loaded }
        }

        await store.send(.task)
        await store.receive(.response(.channelsLoaded(loaded))) { state in
            state.channels[Self.index(of: .newPrescription, in: state)].value = true
        }
    }

    func testTask_alreadyRegistered_loadChannelsFails_failsSilently() async {
        let store = TestStore(initialState: .init(profileId: testProfileId, isRegistered: true)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.loadChannels = { _ in
                struct LoadError: Error {}
                throw LoadError()
            }
        }

        // The error is swallowed: no response is emitted and no alert is presented.
        await store.send(.task)
    }

    // MARK: - Consent confirmed

    func testConfirmEnable_registered_setsIsRegistered() async {
        var initialState = NotificationChannelsDomain.State(profileId: testProfileId)
        initialState.alert = NotificationChannelsDomain.consentAlert
        let store = TestStore(initialState: initialState) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.register = { _ in .registered }
        }

        await store.send(.alert(.presented(.confirmEnable))) { state in
            state.isProcessing = true
            state.alert = nil // the alert is dismissed automatically after the button action
        }
        await store.receive(.response(.registered(.registered))) { state in
            state.isProcessing = false
            state.isRegistered = true
        }
    }

    func testConfirmEnable_permissionDenied_presentsSettingsAlert() async {
        var initialState = NotificationChannelsDomain.State(profileId: testProfileId)
        initialState.alert = NotificationChannelsDomain.consentAlert
        let store = TestStore(initialState: initialState) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.register = { _ in .permissionDenied }
        }

        await store.send(.alert(.presented(.confirmEnable))) { state in
            state.isProcessing = true
            state.alert = nil // the consent alert is dismissed automatically after the button action
        }
        await store.receive(.response(.registered(.permissionDenied))) { state in
            state.isProcessing = false
            state.alert = NotificationChannelsDomain.settingsAlert
        }
    }

    // MARK: - Open settings

    func testOpenSettings_opensSystemSettingsURL() async {
        let openedURL = LockIsolated<URL?>(nil)
        var initialState = NotificationChannelsDomain.State(profileId: testProfileId)
        initialState.alert = NotificationChannelsDomain.settingsAlert
        let store = TestStore(initialState: initialState) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.openURLHandler.open = { url in
                openedURL.setValue(url)
                return true
            }
        }

        await store.send(.alert(.presented(.openSettings))) { state in
            state.alert = nil // the settings alert is dismissed automatically after the button action
        }

        expect(openedURL.value?.absoluteString) == UIApplication.openSettingsURLString
    }

    // MARK: - Channel toggles

    func testChannelToggled_registered_success_keepsOptimisticValue() async {
        let channelId = NotificationChannelsDomain.ChannelID.newPrescription
        let store = TestStore(initialState: .init(profileId: testProfileId, isRegistered: true)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.configureChannel = { _, _, _ in }
        }

        await store.send(.channelToggled(id: channelId, enabled: true)) { state in
            state.channels[Self.index(of: channelId, in: state)].value = true
        }
        await store.receive(.response(.channelConfigured(id: channelId, enabled: true, success: true)))
    }

    func testChannelToggled_registered_failure_revertsValue() async {
        let channelId = NotificationChannelsDomain.ChannelID.newPrescription
        let store = TestStore(initialState: .init(profileId: testProfileId, isRegistered: true)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.pushNotificationRegistrationService.configureChannel = { _, _, _ in
                struct ConfigureError: Error {}
                throw ConfigureError()
            }
        }

        await store.send(.channelToggled(id: channelId, enabled: true)) { state in
            state.channels[Self.index(of: channelId, in: state)].value = true
        }
        await store.receive(.response(.channelConfigured(id: channelId, enabled: true, success: false))) { state in
            state.channels[Self.index(of: channelId, in: state)].value = false
        }
    }

    func testChannelToggled_notRegistered_reEvaluatesConsent() async {
        let channelId = NotificationChannelsDomain.ChannelID.newPrescription
        let store = TestStore(initialState: NotificationChannelsDomain.State(profileId: testProfileId)) {
            NotificationChannelsDomain()
        } withDependencies: { dependencies in
            dependencies.apnsRegistrationService.isAuthorizationDenied = { false }
        }

        await store.send(.channelToggled(id: channelId, enabled: true))
        await store.receive(.response(.presentConsent(authorizationDenied: false))) { state in
            state.alert = NotificationChannelsDomain.consentAlert
        }
    }
}
