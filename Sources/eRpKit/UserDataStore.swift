//
//  Copyright (c) 2024 gematik GmbH
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
import Foundation

/// Interface to access user specific data
/// sourcery: StreamWrapped
public protocol UserDataStore: AnyObject {
    // MARK: - Onboarding

    /// Publisher that returns if the onboarding screens should be displayed
    var hideOnboarding: AnyPublisher<Bool, Never> { get }

    /// Indicates if the onboarding screens should be displayed (alternative to publisher)
    var isOnboardingHidden: Bool { get }

    /// Publisher that returns the date when the onboarding was completed
    var onboardingDate: AnyPublisher<Date?, Never> { get }

    /// Set the onboardingDate
    /// The new value is published through `onboardingDate`
    /// - Parameter onboardingDate: the current date when the function is called
    func set(onboardingDate: Date?)

    /// Set the hideOnboarding
    /// The new value is published through `hideOnboarding`
    /// - Parameter hideOnboarding: `true`if it should be hidden, otherwise `false`
    func set(hideOnboarding: Bool)

    /// Indicates with which version the onboarding has been shown
    var onboardingVersion: AnyPublisher<String?, Never> { get }

    /// Set the app version in which onboarding has been presented
    /// The new value is published through `onboardingVersion`
    /// - Parameter onboardingVersion: app version that was installed when onboarding has finished
    func set(onboardingVersion: String?)

    // MARK: - CardWall

    /// Indicates if the card wall intro screen should be displayed
    var hideCardWallIntro: AnyPublisher<Bool, Never> { get }

    /// Set the hideCardWallIntro
    /// The new value is published through `hideCardWallIntro`
    /// - Parameter hideCardWallIntro: `true`if it should be hidden, otherwise `false`
    func set(hideCardWallIntro: Bool)

    // MARK: - Server configuration name

    /// Server environment name to use. Only available in non production builds.
    func set(serverEnvironmentConfiguration: String?)

    /// Server environment name to use. Only available in non production builds.
    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> { get }

    /// Get name for  server environment configuration without publisher
    var serverEnvironmentName: String? { get }

    // MARK: - App Security

    /// The app security option
    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> { get }

    /// Set the app security option
    /// The new value is published through `appSecurityOption`
    /// - Parameter appSecurityOption:The option selected to secure the app
    func set(appSecurityOption: AppSecurityOption)

    /// The current count of failed app authentications
    var failedAppAuthentications: AnyPublisher<Int, Never> { get }

    /// Set the count of failed app authentications during login
    /// - Parameter failedAppAuthentications: number of failures
    func set(failedAppAuthentications: Int)

    /// Whether the "your device is not secured" warning should be ignored permanently.
    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> { get }

    /// Set whether the "your device is not secured" warning should be ignored permanently.
    ///
    /// - Parameter ignoreDeviceNotSecuredWarningForSession: ignore the warning permanently
    func set(ignoreDeviceNotSecuredWarningPermanently: Bool)

    // MARK: - Profile Selection

    var selectedProfileId: AnyPublisher<UUID?, Never> { get }

    func set(selectedProfileId: UUID)

    // MARK: - General

    var latestCompatibleModelVersion: ModelVersion { get set }

    /// Counter that is increased every time the app has been opened
    var appStartCounter: Int { get set }

    /// Deletes all data stored in the `UserDataStore`
    func wipeAll()

    ///
    var hideWelcomeDrawer: Bool { get set }

    // MARK: - Messages

    /// Publisher that returns all the ids from internal messages that already got displayed
    var readInternalCommunications: AnyPublisher<[String], Never> { get }

    /// Set the readInternalCommunications
    /// The new value is published through `readInternalCommunications`
    /// - Parameter messageId: id of an internal message that got displayed
    func markInternalCommunicationAsRead(messageId: String)

    /// Indicates if the internal communication welcome message should be displayed
    var hideWelcomeMessage: AnyPublisher<Bool, Never> { get }

    /// Set the hideWelcomeMessage
    /// The new value is published through `hideWelcomeMessage`
    /// - Parameter hideWelcomeMessage: `true`if it should be hidden, otherwise `false`
    func set(hideWelcomeMessage: Bool)
}
