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

/// Interface to access user specific data
public class UserDefaultsStore: UserDataStore {
    private var userDefaults: UserDefaults

    public required init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public var hideOnboarding: AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \UserDefaults.shouldHideOnboarding)
            .eraseToAnyPublisher()
    }

    public func set(hideOnboarding: Bool) {
        userDefaults.shouldHideOnboarding = hideOnboarding
    }

    public var isOnboardingHidden: Bool {
        userDefaults.shouldHideOnboarding
    }

    public var onboardingVersion: AnyPublisher<String?, Never> {
        userDefaults.publisher(for: \UserDefaults.onboardingVersion)
            .eraseToAnyPublisher()
    }

    public func set(onboardingVersion: String?) {
        userDefaults.onboardingVersion = onboardingVersion
    }

    public var hideCardWallIntro: AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \UserDefaults.shouldHideCardWallIntro)
            .eraseToAnyPublisher()
    }

    public func set(hideCardWallIntro: Bool) {
        userDefaults.shouldHideCardWallIntro = hideCardWallIntro
    }

    public var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        userDefaults.publisher(for: \UserDefaults.serverEnvironmentConfiguration)
            .eraseToAnyPublisher()
    }

    public func set(serverEnvironmentConfiguration: String?) {
        userDefaults.serverEnvironmentConfiguration = serverEnvironmentConfiguration
    }

    public var appSecurityOption: AnyPublisher<Int, Never> {
        userDefaults.publisher(for: \UserDefaults.appSecurityOption)
            .eraseToAnyPublisher()
    }

    public func set(appSecurityOption: Int) {
        userDefaults.appSecurityOption = appSecurityOption
    }

    public var failedAppAuthentications: AnyPublisher<Int, Never> {
        userDefaults.publisher(for: \UserDefaults.failedAppAuthentications)
            .eraseToAnyPublisher()
    }

    public func set(failedAppAuthentications: Int) {
        userDefaults.failedAppAuthentications = failedAppAuthentications
    }

    public var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \UserDefaults.ignoreDeviceNotSecuredWarningForSession)
            .eraseToAnyPublisher()
    }

    public func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        userDefaults.ignoreDeviceNotSecuredWarningForSession = ignoreDeviceNotSecuredWarningPermanently
    }

    public var selectedProfileId: AnyPublisher<UUID?, Never> {
        userDefaults.publisher(for: \UserDefaults.selectedProfileId).eraseToAnyPublisher()
    }

    public func set(selectedProfileId: UUID) {
        userDefaults.selectedProfileId = selectedProfileId
    }

    public var latestCompatibleModelVersion: ModelVersion {
        get {
            guard let modelVersion = ModelVersion(rawValue: userDefaults.latestCompatibleCoreDataModelVersion) else {
                return ModelVersion.taskStatus
            }
            return modelVersion
        }
        set { userDefaults.latestCompatibleCoreDataModelVersion = newValue.rawValue }
    }

    public var appStartCounter: Int {
        get { userDefaults.appStartCounter }
        set { userDefaults.appStartCounter = newValue }
    }
}

extension UserDefaults {
    /// Name of the server environment to use. Only usable in non production builds
    public static let kServerEnvironmentConfiguration = "kEnvironmentConfiguration"

    /// Base URL Key (UserDefaults)
    public static let kBaseURL = "kBaseURL"
    /// VAU URL Key for `UserDefaults`
    public static let kVauURL = "kVauURL"
    /// DiscoveryDocument URL Key for `UserDefaults`
    public static let kDiscoveryURL = "kIDPDiscoveryURL"
    private static let kShouldHideOnboarding = "kShouldHideOnboarding"
    private static let kOnboardingVersion = "kOnboardingVersion"
    private static let kShouldHideCardWallIntro = "kShouldHideCardWallIntro"
    private static let kAppSecurityOption = "kAppSecurityOption"
    private static let kIgnoreDeviceNotSecuredWarningForSession = "kIgnoreDeviceNotSecuredWarningForSession"
    /// Key for app tracking settings `UserDefaults`
    public static let kAppTrackingAllowed = "kAppTrackingAllowed"
    /// Key for storing if app-install event has been sent to tracking server in `UserDefaults`
    public static let kAppInstallSent = "kAppInstallSent"
    /// Key for storing failedAppAuthentications
    public static let kFailedAppAuthentications = "kFailedAppAuthentications"
    /// Key for storing the selectedProfileId
    public static let kSelectedProfileId = "kSelectedProfileId"
    /// Key for latest compatible core data model version
    public static let kLatestCompatibleCoreDataModelVersion = "kLatestCompatibleCoreDataModelVersion"
    /// Kex for storing the app start count
    public static let kAppStartCounter = "kAppStartCounter"

    @objc var serverEnvironmentConfiguration: String? {
        get {
            string(forKey: Self.kServerEnvironmentConfiguration)
        }
        set {
            setValue(newValue, forKey: Self.kServerEnvironmentConfiguration)
        }
    }

    @objc var shouldHideOnboarding: Bool {
        get { bool(forKey: Self.kShouldHideOnboarding) }
        set { set(newValue, forKey: Self.kShouldHideOnboarding) }
    }

    @objc var onboardingVersion: String? {
        get { string(forKey: Self.kOnboardingVersion) }
        set { set(newValue, forKey: Self.kOnboardingVersion) }
    }

    @objc var shouldHideCardWallIntro: Bool {
        get { bool(forKey: Self.kShouldHideCardWallIntro) }
        set { set(newValue, forKey: Self.kShouldHideCardWallIntro) }
    }

    @objc var appSecurityOption: Int {
        get { integer(forKey: Self.kAppSecurityOption) }
        set { set(newValue, forKey: Self.kAppSecurityOption) }
    }

    @objc var ignoreDeviceNotSecuredWarningForSession: Bool {
        get { bool(forKey: Self.kIgnoreDeviceNotSecuredWarningForSession) }
        set { set(newValue, forKey: Self.kIgnoreDeviceNotSecuredWarningForSession) }
    }

    /// Store users setting for app tracking
    @objc public var kAppTrackingAllowed: Bool {
        get { bool(forKey: Self.kAppTrackingAllowed) }
        set { set(newValue, forKey: Self.kAppTrackingAllowed) }
    }

    /// Store if app-install event has been sent to tracking server
    @objc public var appInstallSent: Bool {
        get { bool(forKey: Self.kAppInstallSent) }
        set { set(newValue, forKey: Self.kAppInstallSent) }
    }

    /// Store number of failure app authentications
    @objc public var failedAppAuthentications: Int {
        get { integer(forKey: Self.kFailedAppAuthentications) }
        set { set(newValue, forKey: Self.kFailedAppAuthentications) }
    }

    /// Store for the selected profile identifier
    @objc public var selectedProfileId: UUID? {
        get {
            guard let uuidString = string(forKey: Self.kSelectedProfileId) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set { set(newValue?.uuidString, forKey: Self.kSelectedProfileId) }
    }

    /// Store number of failure app authentications
    @objc public var latestCompatibleCoreDataModelVersion: Int {
        get { integer(forKey: Self.kLatestCompatibleCoreDataModelVersion) }
        set { set(newValue, forKey: Self.kLatestCompatibleCoreDataModelVersion) }
    }

    /// Store every app start in this counter
    @objc public var appStartCounter: Int {
        get { integer(forKey: Self.kAppInstallSent) }
        set { set(newValue, forKey: Self.kAppInstallSent) }
    }

    // swiftlint:enable implicit_getter
}
