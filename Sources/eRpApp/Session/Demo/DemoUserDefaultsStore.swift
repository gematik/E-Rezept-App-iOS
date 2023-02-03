//
//  Copyright (c) 2023 gematik GmbH
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

    func wipeAll() {}
}
