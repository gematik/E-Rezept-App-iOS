// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Combine
import eRpKit
import Foundation

@testable import eRpLocalStorage
























public class UserDataStoreMock: UserDataStore {

    public init() {}

    public var hideOnboarding: AnyPublisher<Bool, Never> {
        get { return underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    public var underlyingHideOnboarding: (AnyPublisher<Bool, Never>)!
    public var isOnboardingHidden: Bool {
        get { return underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    public var underlyingIsOnboardingHidden: (Bool)!
    public var onboardingDate: AnyPublisher<Date?, Never> {
        get { return underlyingOnboardingDate }
        set(value) { underlyingOnboardingDate = value }
    }
    public var underlyingOnboardingDate: (AnyPublisher<Date?, Never>)!
    public var onboardingVersion: AnyPublisher<String?, Never> {
        get { return underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    public var underlyingOnboardingVersion: (AnyPublisher<String?, Never>)!
    public var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { return underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    public var underlyingHideCardWallIntro: (AnyPublisher<Bool, Never>)!
    public var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { return underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    public var underlyingServerEnvironmentConfiguration: (AnyPublisher<String?, Never>)!
    public var serverEnvironmentName: String?
    public var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { return underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    public var underlyingAppSecurityOption: (AnyPublisher<AppSecurityOption, Never>)!
    public var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { return underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    public var underlyingFailedAppAuthentications: (AnyPublisher<Int, Never>)!
    public var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    public var underlyingIgnoreDeviceNotSecuredWarningPermanently: (AnyPublisher<Bool, Never>)!
    public var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    public var underlyingSelectedProfileId: (AnyPublisher<UUID?, Never>)!
    public var latestCompatibleModelVersion: ModelVersion {
        get { return underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    public var underlyingLatestCompatibleModelVersion: (ModelVersion)!
    public var appStartCounter: Int {
        get { return underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    public var underlyingAppStartCounter: (Int)!
    public var readInternalCommunications: AnyPublisher<[String], Never> {
        get { return underlyingReadInternalCommunications }
        set(value) { underlyingReadInternalCommunications = value }
    }
    public var underlyingReadInternalCommunications: (AnyPublisher<[String], Never>)!
    public var hideWelcomeMessage: AnyPublisher<Bool, Never> {
        get { return underlyingHideWelcomeMessage }
        set(value) { underlyingHideWelcomeMessage = value }
    }
    public var underlyingHideWelcomeMessage: (AnyPublisher<Bool, Never>)!
    public var hideEURedeemInstructions: AnyPublisher<Bool, Never> {
        get { return underlyingHideEURedeemInstructions }
        set(value) { underlyingHideEURedeemInstructions = value }
    }
    public var underlyingHideEURedeemInstructions: (AnyPublisher<Bool, Never>)!


    //MARK: - set

    public var setOnboardingDateDateVoidCallsCount = 0
    public var setOnboardingDateDateVoidCalled: Bool {
        return setOnboardingDateDateVoidCallsCount > 0
    }
    public var setOnboardingDateDateVoidReceivedOnboardingDate: (Date)?
    public var setOnboardingDateDateVoidReceivedInvocations: [(Date)?] = []
    public var setOnboardingDateDateVoidClosure: ((Date?) -> Void)?

    public func set(onboardingDate: Date?) {
        setOnboardingDateDateVoidCallsCount += 1
        setOnboardingDateDateVoidReceivedOnboardingDate = onboardingDate
        setOnboardingDateDateVoidReceivedInvocations.append(onboardingDate)
        setOnboardingDateDateVoidClosure?(onboardingDate)
    }

    //MARK: - set

    public var setHideOnboardingBoolVoidCallsCount = 0
    public var setHideOnboardingBoolVoidCalled: Bool {
        return setHideOnboardingBoolVoidCallsCount > 0
    }
    public var setHideOnboardingBoolVoidReceivedHideOnboarding: (Bool)?
    public var setHideOnboardingBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideOnboardingBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideOnboarding: Bool) {
        setHideOnboardingBoolVoidCallsCount += 1
        setHideOnboardingBoolVoidReceivedHideOnboarding = hideOnboarding
        setHideOnboardingBoolVoidReceivedInvocations.append(hideOnboarding)
        setHideOnboardingBoolVoidClosure?(hideOnboarding)
    }

    //MARK: - set

    public var setOnboardingVersionStringVoidCallsCount = 0
    public var setOnboardingVersionStringVoidCalled: Bool {
        return setOnboardingVersionStringVoidCallsCount > 0
    }
    public var setOnboardingVersionStringVoidReceivedOnboardingVersion: (String)?
    public var setOnboardingVersionStringVoidReceivedInvocations: [(String)?] = []
    public var setOnboardingVersionStringVoidClosure: ((String?) -> Void)?

    public func set(onboardingVersion: String?) {
        setOnboardingVersionStringVoidCallsCount += 1
        setOnboardingVersionStringVoidReceivedOnboardingVersion = onboardingVersion
        setOnboardingVersionStringVoidReceivedInvocations.append(onboardingVersion)
        setOnboardingVersionStringVoidClosure?(onboardingVersion)
    }

    //MARK: - set

    public var setHideCardWallIntroBoolVoidCallsCount = 0
    public var setHideCardWallIntroBoolVoidCalled: Bool {
        return setHideCardWallIntroBoolVoidCallsCount > 0
    }
    public var setHideCardWallIntroBoolVoidReceivedHideCardWallIntro: (Bool)?
    public var setHideCardWallIntroBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideCardWallIntroBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideCardWallIntro: Bool) {
        setHideCardWallIntroBoolVoidCallsCount += 1
        setHideCardWallIntroBoolVoidReceivedHideCardWallIntro = hideCardWallIntro
        setHideCardWallIntroBoolVoidReceivedInvocations.append(hideCardWallIntro)
        setHideCardWallIntroBoolVoidClosure?(hideCardWallIntro)
    }

    //MARK: - set

    public var setServerEnvironmentConfigurationStringVoidCallsCount = 0
    public var setServerEnvironmentConfigurationStringVoidCalled: Bool {
        return setServerEnvironmentConfigurationStringVoidCallsCount > 0
    }
    public var setServerEnvironmentConfigurationStringVoidReceivedServerEnvironmentConfiguration: (String)?
    public var setServerEnvironmentConfigurationStringVoidReceivedInvocations: [(String)?] = []
    public var setServerEnvironmentConfigurationStringVoidClosure: ((String?) -> Void)?

    public func set(serverEnvironmentConfiguration: String?) {
        setServerEnvironmentConfigurationStringVoidCallsCount += 1
        setServerEnvironmentConfigurationStringVoidReceivedServerEnvironmentConfiguration = serverEnvironmentConfiguration
        setServerEnvironmentConfigurationStringVoidReceivedInvocations.append(serverEnvironmentConfiguration)
        setServerEnvironmentConfigurationStringVoidClosure?(serverEnvironmentConfiguration)
    }

    //MARK: - set

    public var setAppSecurityOptionAppSecurityOptionVoidCallsCount = 0
    public var setAppSecurityOptionAppSecurityOptionVoidCalled: Bool {
        return setAppSecurityOptionAppSecurityOptionVoidCallsCount > 0
    }
    public var setAppSecurityOptionAppSecurityOptionVoidReceivedAppSecurityOption: (AppSecurityOption)?
    public var setAppSecurityOptionAppSecurityOptionVoidReceivedInvocations: [(AppSecurityOption)] = []
    public var setAppSecurityOptionAppSecurityOptionVoidClosure: ((AppSecurityOption) -> Void)?

    public func set(appSecurityOption: AppSecurityOption) {
        setAppSecurityOptionAppSecurityOptionVoidCallsCount += 1
        setAppSecurityOptionAppSecurityOptionVoidReceivedAppSecurityOption = appSecurityOption
        setAppSecurityOptionAppSecurityOptionVoidReceivedInvocations.append(appSecurityOption)
        setAppSecurityOptionAppSecurityOptionVoidClosure?(appSecurityOption)
    }

    //MARK: - set

    public var setFailedAppAuthenticationsIntVoidCallsCount = 0
    public var setFailedAppAuthenticationsIntVoidCalled: Bool {
        return setFailedAppAuthenticationsIntVoidCallsCount > 0
    }
    public var setFailedAppAuthenticationsIntVoidReceivedFailedAppAuthentications: (Int)?
    public var setFailedAppAuthenticationsIntVoidReceivedInvocations: [(Int)] = []
    public var setFailedAppAuthenticationsIntVoidClosure: ((Int) -> Void)?

    public func set(failedAppAuthentications: Int) {
        setFailedAppAuthenticationsIntVoidCallsCount += 1
        setFailedAppAuthenticationsIntVoidReceivedFailedAppAuthentications = failedAppAuthentications
        setFailedAppAuthenticationsIntVoidReceivedInvocations.append(failedAppAuthentications)
        setFailedAppAuthenticationsIntVoidClosure?(failedAppAuthentications)
    }

    //MARK: - set

    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount = 0
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount > 0
    }
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedIgnoreDeviceNotSecuredWarningPermanently: (Bool)?
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedInvocations: [(Bool)] = []
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidClosure: ((Bool) -> Void)?

    public func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount += 1
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedIgnoreDeviceNotSecuredWarningPermanently = ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }

    //MARK: - set

    public var setSelectedProfileIdUUIDVoidCallsCount = 0
    public var setSelectedProfileIdUUIDVoidCalled: Bool {
        return setSelectedProfileIdUUIDVoidCallsCount > 0
    }
    public var setSelectedProfileIdUUIDVoidReceivedSelectedProfileId: (UUID)?
    public var setSelectedProfileIdUUIDVoidReceivedInvocations: [(UUID)] = []
    public var setSelectedProfileIdUUIDVoidClosure: ((UUID) -> Void)?

    public func set(selectedProfileId: UUID) {
        setSelectedProfileIdUUIDVoidCallsCount += 1
        setSelectedProfileIdUUIDVoidReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdUUIDVoidReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdUUIDVoidClosure?(selectedProfileId)
    }

    //MARK: - wipeAll

    public var wipeAllVoidCallsCount = 0
    public var wipeAllVoidCalled: Bool {
        return wipeAllVoidCallsCount > 0
    }
    public var wipeAllVoidClosure: (() -> Void)?

    public func wipeAll() {
        wipeAllVoidCallsCount += 1
        wipeAllVoidClosure?()
    }

    //MARK: - markInternalCommunicationAsRead

    public var markInternalCommunicationAsReadMessageIdStringVoidCallsCount = 0
    public var markInternalCommunicationAsReadMessageIdStringVoidCalled: Bool {
        return markInternalCommunicationAsReadMessageIdStringVoidCallsCount > 0
    }
    public var markInternalCommunicationAsReadMessageIdStringVoidReceivedMessageId: (String)?
    public var markInternalCommunicationAsReadMessageIdStringVoidReceivedInvocations: [(String)] = []
    public var markInternalCommunicationAsReadMessageIdStringVoidClosure: ((String) -> Void)?

    public func markInternalCommunicationAsRead(messageId: String) {
        markInternalCommunicationAsReadMessageIdStringVoidCallsCount += 1
        markInternalCommunicationAsReadMessageIdStringVoidReceivedMessageId = messageId
        markInternalCommunicationAsReadMessageIdStringVoidReceivedInvocations.append(messageId)
        markInternalCommunicationAsReadMessageIdStringVoidClosure?(messageId)
    }

    //MARK: - set

    public var setHideWelcomeMessageBoolVoidCallsCount = 0
    public var setHideWelcomeMessageBoolVoidCalled: Bool {
        return setHideWelcomeMessageBoolVoidCallsCount > 0
    }
    public var setHideWelcomeMessageBoolVoidReceivedHideWelcomeMessage: (Bool)?
    public var setHideWelcomeMessageBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideWelcomeMessageBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideWelcomeMessage: Bool) {
        setHideWelcomeMessageBoolVoidCallsCount += 1
        setHideWelcomeMessageBoolVoidReceivedHideWelcomeMessage = hideWelcomeMessage
        setHideWelcomeMessageBoolVoidReceivedInvocations.append(hideWelcomeMessage)
        setHideWelcomeMessageBoolVoidClosure?(hideWelcomeMessage)
    }

    //MARK: - set

    public var setHideEURedeemInstructionsBoolVoidCallsCount = 0
    public var setHideEURedeemInstructionsBoolVoidCalled: Bool {
        return setHideEURedeemInstructionsBoolVoidCallsCount > 0
    }
    public var setHideEURedeemInstructionsBoolVoidReceivedHideEURedeemInstructions: (Bool)?
    public var setHideEURedeemInstructionsBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideEURedeemInstructionsBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideEURedeemInstructions: Bool) {
        setHideEURedeemInstructionsBoolVoidCallsCount += 1
        setHideEURedeemInstructionsBoolVoidReceivedHideEURedeemInstructions = hideEURedeemInstructions
        setHideEURedeemInstructionsBoolVoidReceivedInvocations.append(hideEURedeemInstructions)
        setHideEURedeemInstructionsBoolVoidClosure?(hideEURedeemInstructions)
    }


}
