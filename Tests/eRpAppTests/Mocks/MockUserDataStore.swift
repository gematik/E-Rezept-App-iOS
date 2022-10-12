//
//  Copyright (c) 2022 gematik GmbH
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

// swiftlint:disable identifier_name

// MARK: - MockUserDataStore -

final class MockUserDataStore: UserDataStore {
    // MARK: - hideOnboarding

    var isOnboardingHidden = false

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }

    private var underlyingHideOnboarding: AnyPublisher<Bool, Never>!

    // MARK: - hideCardWallIntro

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }

    private var underlyingHideCardWallIntro: AnyPublisher<Bool, Never>!

    // MARK: - serverEnvironmentConfiguration

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }

    private var underlyingServerEnvironmentConfiguration: AnyPublisher<String?, Never>!

    // MARK: - appSecurityOption

    var appSecurityOption: AnyPublisher<Int, Never> {
        get { underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }

    private var underlyingAppSecurityOption: AnyPublisher<Int, Never>!

    // MARK: - ignoreDeviceNotSecuredWarningPermanently

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }

    private var underlyingIgnoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never>!

    // MARK: - set

    var setHideOnboardingCallsCount = 0
    var setHideOnboardingCalled: Bool {
        setHideOnboardingCallsCount > 0
    }

    var setHideOnboardingReceivedHideOnboarding: Bool?
    var setHideOnboardingReceivedInvocations: [Bool] = []
    var setHideOnboardingClosure: ((Bool) -> Void)?

    func set(hideOnboarding: Bool) {
        isOnboardingHidden = hideOnboarding
        setHideOnboardingCallsCount += 1
        setHideOnboardingReceivedHideOnboarding = hideOnboarding
        setHideOnboardingReceivedInvocations.append(hideOnboarding)
        setHideOnboardingClosure?(hideOnboarding)
    }

    // MARK: - set

    var setOnboardingVersionCallsCount = 0
    var setOnboardingVersionCalled: Bool {
        setOnboardingVersionCallsCount > 0
    }

    var setOnboardingVersionReceivedOnboardingVersion: String?
    var setOnboardingVersionReceivedInvocations: [String?] = []
    var setOnboardingVersionClosure: ((String?) -> Void)?

    private var underlyingOnboardingVersion: AnyPublisher<String?, Never>!

    var onboardingVersion: AnyPublisher<String?, Never> {
        get { underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }

    func set(onboardingVersion version: String?) {
        setOnboardingVersionCallsCount += 1
        setOnboardingVersionReceivedOnboardingVersion = version
        setOnboardingVersionReceivedInvocations.append(version)
        setOnboardingVersionClosure?(version)
    }

    // MARK: - set

    var setHideCardWallIntroCallsCount = 0
    var setHideCardWallIntroCalled: Bool {
        setHideCardWallIntroCallsCount > 0
    }

    var setHideCardWallIntroReceivedHideCardWallIntro: Bool?
    var setHideCardWallIntroReceivedInvocations: [Bool] = []
    var setHideCardWallIntroClosure: ((Bool) -> Void)?

    func set(hideCardWallIntro: Bool) {
        setHideCardWallIntroCallsCount += 1
        setHideCardWallIntroReceivedHideCardWallIntro = hideCardWallIntro
        setHideCardWallIntroReceivedInvocations.append(hideCardWallIntro)
        setHideCardWallIntroClosure?(hideCardWallIntro)
    }

    // MARK: - set

    var setServerEnvironmentConfigurationCallsCount = 0
    var setServerEnvironmentConfigurationCalled: Bool {
        setServerEnvironmentConfigurationCallsCount > 0
    }

    var setServerEnvironmentConfigurationReceivedServerEnvironmentConfiguration: String?
    var setServerEnvironmentConfigurationReceivedInvocations: [String?] = []
    var setServerEnvironmentConfigurationClosure: ((String?) -> Void)?

    func set(serverEnvironmentConfiguration: String?) {
        setServerEnvironmentConfigurationCallsCount += 1
        setServerEnvironmentConfigurationReceivedServerEnvironmentConfiguration = serverEnvironmentConfiguration
        setServerEnvironmentConfigurationReceivedInvocations.append(serverEnvironmentConfiguration)
        setServerEnvironmentConfigurationClosure?(serverEnvironmentConfiguration)
    }

    var setServerEnvironmentNameCallsCount = 0
    var setServerEnvironmentNameCalled: Bool {
        setServerEnvironmentNameCallsCount > 0
    }

    var underlyingServerEnvironmentName: String?
    var setServerEnvironmentNameReceivedInvocations: [String?] = []
    var serverEnvironmentName: String? {
        get {
            setServerEnvironmentNameCallsCount += 1
            return underlyingServerEnvironmentName
        }
        set {
            underlyingServerEnvironmentName = newValue
            setServerEnvironmentNameReceivedInvocations.append(newValue)
        }
    }

    // MARK: - set

    var setAppSecurityOptionCallsCount = 0
    var setAppSecurityOptionCalled: Bool {
        setAppSecurityOptionCallsCount > 0
    }

    var setAppSecurityOptionReceivedAppSecurityOption: Int?
    var setAppSecurityOptionReceivedInvocations: [Int] = []
    var setAppSecurityOptionClosure: ((Int) -> Void)?

    func set(appSecurityOption: Int) {
        setAppSecurityOptionCallsCount += 1
        setAppSecurityOptionReceivedAppSecurityOption = appSecurityOption
        setAppSecurityOptionReceivedInvocations.append(appSecurityOption)
        setAppSecurityOptionClosure?(appSecurityOption)
    }

    // MARK: - failedAppAuthentications

    var underlyingFailedAppAuthentications: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        underlyingFailedAppAuthentications.eraseToAnyPublisher()
    }

    // MARK: - set

    var setFailedAppAuthenticationsCallsCount = 0
    var setFailedAppAuthenticationsCalled: Bool {
        setFailedAppAuthenticationsCallsCount > 0
    }

    var setFailedAppAuthenticationsReceived: Int?
    var setFailedAppAuthenticationsReceivedInvocations: [Int] = []
    var setFailedAppAuthenticationsClosure: ((Int) -> Void)?

    func set(failedAppAuthentications: Int) {
        setFailedAppAuthenticationsCallsCount += 1
        setFailedAppAuthenticationsReceived = failedAppAuthentications
        setFailedAppAuthenticationsReceivedInvocations.append(failedAppAuthentications)
        setFailedAppAuthenticationsClosure?(failedAppAuthentications)
    }

    // MARK: - set

    var setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningPermanentlyCalled: Bool {
        setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount > 0
    }

    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently: Bool?
    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations: [Bool] = []
    var setIgnoreDeviceNotSecuredWarningPermanentlyClosure: ((Bool) -> Void)?

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount += 1
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently =
            ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }

    // MARK: - selectedProfileId

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        setSelectedProfileIdCallsCount > 0
    }

    var setSelectedProfileIdReceived: UUID?
    var setSelectedProfileIdReceivedInvocations: [UUID] = []
    var setSelectedProfileIdClosure: ((UUID) -> Void)?

    func set(selectedProfileId: UUID) {
        setSelectedProfileIdCallsCount += 1
        setSelectedProfileIdReceived = selectedProfileId
        setSelectedProfileIdReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdClosure?(selectedProfileId)
    }

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }

    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!

    // MARK: - LatestCompatibleCoreDataModelVersion

    var latestCompatibleCoreDataModelVersionCallsCount = 0
    var latestCompatibleCoreDataModelVersionCalled: Bool {
        latestCompatibleCoreDataModelVersionCallsCount > 0
    }

    var latestCompatibleModelVersion: ModelVersion {
        get {
            latestCompatibleCoreDataModelVersionCallsCount += 1
            return underlyingLastCompatibleCoreDataModelVersion
        }
        set {
            underlyingLastCompatibleCoreDataModelVersion = newValue
        }
    }

    var underlyingLastCompatibleCoreDataModelVersion: ModelVersion = .taskStatus

    var underlyingAppStartCounter: Int = 0
    var appStartCounterCallsCount = 0
    var appStartCounterCalled: Bool {
        appStartCounterCallsCount > 0
    }

    var appStartCounter: Int {
        get {
            appStartCounterCallsCount += 1
            return underlyingAppStartCounter
        }
        set {
            underlyingAppStartCounter = newValue
        }
    }

    var wipeAllCallsCount = 0
    var wipeAllCalled: Bool {
        wipeAllCallsCount > 0
    }

    func wipeAll() {
        wipeAllCallsCount += 1
    }
}
