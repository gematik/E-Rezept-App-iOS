//
//  Copyright (c) 2021 gematik GmbH
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
    private static let kShouldHideCardWallIntro = "kShouldHideCardWallIntro"
    private static let kAppSecurityOption = "kAppSecurityOption"
    /// Key for app tracking settings `UserDefaults`
    public static let kAppTrackingAllowed = "kAppTrackingAllowed"
    /// Key for storing if app-install event has been sent to tracking server in `UserDefaults`
    public static let kAppInstallSent = "kAppInstallSent"

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

    @objc var shouldHideCardWallIntro: Bool {
        get { bool(forKey: Self.kShouldHideCardWallIntro) }
        set { set(newValue, forKey: Self.kShouldHideCardWallIntro) }
    }

    @objc var appSecurityOption: Int {
        get { integer(forKey: Self.kAppSecurityOption) }
        set { set(newValue, forKey: Self.kAppSecurityOption) }
    }

    /// Store users setting for app tracking
    @objc public var kAppTrackingAllowed: Bool {
        get { bool(forKey: Self.kAppTrackingAllowed) }
        set { set(newValue, forKey: Self.kAppTrackingAllowed) }
    }

    /// Store if app-install event has been sent to tracking server
    @objc public var kAppInstallSent: Bool {
        get { bool(forKey: Self.kAppInstallSent) }
        set { set(newValue, forKey: Self.kAppInstallSent) }
    }

    // swiftlint:enable implicit_getter
}
