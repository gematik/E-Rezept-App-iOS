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
import eRpKit
import Foundation

class DemoUserDefaultsStore: UserDataStore {
    /// Indicates if the onboarding should be displayed
    var hideOnboarding: AnyPublisher<Bool, Never> {
        hideOnboardingCurrentValue.eraseToAnyPublisher()
    }

    var isOnboardingHidden = true

    private var hideOnboardingCurrentValue: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)

    func set(hideOnboarding: Bool) {
        isOnboardingHidden = hideOnboarding
        hideOnboardingCurrentValue.send(hideOnboarding)
    }

    private var onboardingDateCurrentValue: CurrentValueSubject<Date?, Never> = CurrentValueSubject(nil)

    var onboardingDate: AnyPublisher<Date?, Never> {
        onboardingDateCurrentValue.eraseToAnyPublisher()
    }

    func set(onboardingDate: Date?) {
        onboardingDateCurrentValue.send(onboardingDate)
    }

    /// Indicates if the card wall intro screen should be displayed
    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        hideCardWallIntroCurrentValue.eraseToAnyPublisher()
    }

    private var onboardingVersionCurrentValue: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)

    var onboardingVersion: AnyPublisher<String?, Never> {
        onboardingVersionCurrentValue
            .eraseToAnyPublisher()
    }

    func set(onboardingVersion: String?) {
        onboardingVersionCurrentValue.send(onboardingVersion)
    }

    private var hideCardWallIntroCurrentValue: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)

    func set(hideCardWallIntro: Bool) {
        hideCardWallIntroCurrentValue.send(hideCardWallIntro)
    }

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> = Just(nil).eraseToAnyPublisher()

    var serverEnvironmentName: String? {
        nil
    }

    func set(serverEnvironmentConfiguration _: String?) {}

    /// The app security option
    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        appSecurityOptionCurrentValue.eraseToAnyPublisher()
    }

    private var appSecurityOptionCurrentValue: CurrentValueSubject<AppSecurityOption, Never> =
        CurrentValueSubject(.unsecured)

    func set(appSecurityOption: AppSecurityOption) {
        appSecurityOptionCurrentValue.send(appSecurityOption)
    }

    private var failedAppAuthenticationsValue: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        failedAppAuthenticationsValue.eraseToAnyPublisher()
    }

    func set(failedAppAuthentications: Int) {
        failedAppAuthenticationsValue.send(failedAppAuthentications)
    }

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        ignoreDeviceNotSecuredWarningForSessionValue.eraseToAnyPublisher()
    }

    // swiftlint:disable:next identifier_name
    private var ignoreDeviceNotSecuredWarningForSessionValue: CurrentValueSubject<Bool, Never> =
        CurrentValueSubject(true)

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        ignoreDeviceNotSecuredWarningForSessionValue.send(ignoreDeviceNotSecuredWarningPermanently)
    }

    var selectedProfileIdSubject = CurrentValueSubject<UUID?, Never>(DemoProfileDataStore.anna.id)
    var selectedProfileId: AnyPublisher<UUID?, Never> {
        selectedProfileIdSubject.eraseToAnyPublisher()
    }

    func set(selectedProfileId: UUID) {
        selectedProfileIdSubject.send(selectedProfileId)
    }

    var latestCompatibleModelVersionValue = ModelVersion.taskStatus

    var latestCompatibleModelVersion: ModelVersion {
        get { latestCompatibleModelVersionValue }
        set { latestCompatibleModelVersionValue = newValue }
    }

    var appStartCounterValue: Int = 0

    var appStartCounter: Int {
        get { appStartCounterValue }
        set { appStartCounterValue = newValue }
    }

    var hideWelcomeDrawerValue = true

    var hideWelcomeDrawer: Bool {
        get { hideWelcomeDrawerValue }
        set { hideWelcomeDrawerValue = newValue }
    }

    var readInternalCommunications: AnyPublisher<[String], Never> {
        readInternalCommunicationsCurrentValue.eraseToAnyPublisher()
    }

    var allReadInternalCommunications: [String] = []

    private var readInternalCommunicationsCurrentValue: CurrentValueSubject<[String], Never> = CurrentValueSubject([])

    func markInternalCommunicationAsRead(messageId: String) {
        var newReadInternalCommunications = allReadInternalCommunications
        newReadInternalCommunications.append(messageId)
        readInternalCommunicationsCurrentValue.send(newReadInternalCommunications)
    }

    var hideWelcomeMessage: AnyPublisher<Bool, Never> {
        hideWelcomeMessageCurrentValue.eraseToAnyPublisher()
    }

    private var hideWelcomeMessageCurrentValue: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)

    func set(hideWelcomeMessage: Bool) {
        hideWelcomeMessageCurrentValue.send(hideWelcomeMessage)
    }

    func wipeAll() {}
}
