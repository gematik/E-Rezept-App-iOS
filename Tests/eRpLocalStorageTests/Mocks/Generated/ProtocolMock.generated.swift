// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import Foundation

@testable import eRpLocalStorage

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.




















final class MockCoreDataControllerFactory: CoreDataControllerFactory {

    var databaseUrl: URL {
        get { return underlyingDatabaseUrl }
        set(value) { underlyingDatabaseUrl = value }
    }
    var underlyingDatabaseUrl: URL!

    //MARK: - loadCoreDataController

    var loadCoreDataControllerThrowableError: Error?
    var loadCoreDataControllerCallsCount = 0
    var loadCoreDataControllerCalled: Bool {
        return loadCoreDataControllerCallsCount > 0
    }
    var loadCoreDataControllerReturnValue: CoreDataController!
    var loadCoreDataControllerClosure: (() throws -> CoreDataController)?

    func loadCoreDataController() throws -> CoreDataController {
        if let error = loadCoreDataControllerThrowableError {
            throw error
        }
        loadCoreDataControllerCallsCount += 1
        if let loadCoreDataControllerClosure = loadCoreDataControllerClosure {
            return try loadCoreDataControllerClosure()
        } else {
            return loadCoreDataControllerReturnValue
        }
    }

}
final class MockUserDataStore: UserDataStore {

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { return underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    var underlyingHideOnboarding: AnyPublisher<Bool, Never>!
    var isOnboardingHidden: Bool {
        get { return underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    var underlyingIsOnboardingHidden: Bool!
    var onboardingVersion: AnyPublisher<String?, Never> {
        get { return underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    var underlyingOnboardingVersion: AnyPublisher<String?, Never>!
    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { return underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    var underlyingHideCardWallIntro: AnyPublisher<Bool, Never>!
    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { return underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    var underlyingServerEnvironmentConfiguration: AnyPublisher<String?, Never>!
    var serverEnvironmentName: String?
    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { return underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    var underlyingAppSecurityOption: AnyPublisher<AppSecurityOption, Never>!
    var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { return underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    var underlyingFailedAppAuthentications: AnyPublisher<Int, Never>!
    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never>!
    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!
    var latestCompatibleModelVersion: ModelVersion {
        get { return underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    var underlyingLatestCompatibleModelVersion: ModelVersion!
    var appStartCounter: Int {
        get { return underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    var underlyingAppStartCounter: Int!
    var hideWelcomeDrawer: Bool {
        get { return underlyingHideWelcomeDrawer }
        set(value) { underlyingHideWelcomeDrawer = value }
    }
    var underlyingHideWelcomeDrawer: Bool!

    //MARK: - set

    var setHideOnboardingCallsCount = 0
    var setHideOnboardingCalled: Bool {
        return setHideOnboardingCallsCount > 0
    }
    var setHideOnboardingReceivedHideOnboarding: Bool?
    var setHideOnboardingReceivedInvocations: [Bool] = []
    var setHideOnboardingClosure: ((Bool) -> Void)?

    func set(hideOnboarding: Bool) {
        setHideOnboardingCallsCount += 1
        setHideOnboardingReceivedHideOnboarding = hideOnboarding
        setHideOnboardingReceivedInvocations.append(hideOnboarding)
        setHideOnboardingClosure?(hideOnboarding)
    }

    //MARK: - set

    var setOnboardingVersionCallsCount = 0
    var setOnboardingVersionCalled: Bool {
        return setOnboardingVersionCallsCount > 0
    }
    var setOnboardingVersionReceivedOnboardingVersion: String?
    var setOnboardingVersionReceivedInvocations: [String?] = []
    var setOnboardingVersionClosure: ((String?) -> Void)?

    func set(onboardingVersion: String?) {
        setOnboardingVersionCallsCount += 1
        setOnboardingVersionReceivedOnboardingVersion = onboardingVersion
        setOnboardingVersionReceivedInvocations.append(onboardingVersion)
        setOnboardingVersionClosure?(onboardingVersion)
    }

    //MARK: - set

    var setHideCardWallIntroCallsCount = 0
    var setHideCardWallIntroCalled: Bool {
        return setHideCardWallIntroCallsCount > 0
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

    //MARK: - set

    var setServerEnvironmentConfigurationCallsCount = 0
    var setServerEnvironmentConfigurationCalled: Bool {
        return setServerEnvironmentConfigurationCallsCount > 0
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

    //MARK: - set

    var setAppSecurityOptionCallsCount = 0
    var setAppSecurityOptionCalled: Bool {
        return setAppSecurityOptionCallsCount > 0
    }
    var setAppSecurityOptionReceivedAppSecurityOption: AppSecurityOption?
    var setAppSecurityOptionReceivedInvocations: [AppSecurityOption] = []
    var setAppSecurityOptionClosure: ((AppSecurityOption) -> Void)?

    func set(appSecurityOption: AppSecurityOption) {
        setAppSecurityOptionCallsCount += 1
        setAppSecurityOptionReceivedAppSecurityOption = appSecurityOption
        setAppSecurityOptionReceivedInvocations.append(appSecurityOption)
        setAppSecurityOptionClosure?(appSecurityOption)
    }

    //MARK: - set

    var setFailedAppAuthenticationsCallsCount = 0
    var setFailedAppAuthenticationsCalled: Bool {
        return setFailedAppAuthenticationsCallsCount > 0
    }
    var setFailedAppAuthenticationsReceivedFailedAppAuthentications: Int?
    var setFailedAppAuthenticationsReceivedInvocations: [Int] = []
    var setFailedAppAuthenticationsClosure: ((Int) -> Void)?

    func set(failedAppAuthentications: Int) {
        setFailedAppAuthenticationsCallsCount += 1
        setFailedAppAuthenticationsReceivedFailedAppAuthentications = failedAppAuthentications
        setFailedAppAuthenticationsReceivedInvocations.append(failedAppAuthentications)
        setFailedAppAuthenticationsClosure?(failedAppAuthentications)
    }

    //MARK: - set

    var setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningPermanentlyCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount > 0
    }
    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently: Bool?
    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations: [Bool] = []
    var setIgnoreDeviceNotSecuredWarningPermanentlyClosure: ((Bool) -> Void)?

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount += 1
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently = ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }

    //MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        return setSelectedProfileIdCallsCount > 0
    }
    var setSelectedProfileIdReceivedSelectedProfileId: UUID?
    var setSelectedProfileIdReceivedInvocations: [UUID] = []
    var setSelectedProfileIdClosure: ((UUID) -> Void)?

    func set(selectedProfileId: UUID) {
        setSelectedProfileIdCallsCount += 1
        setSelectedProfileIdReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdClosure?(selectedProfileId)
    }

    //MARK: - wipeAll

    var wipeAllCallsCount = 0
    var wipeAllCalled: Bool {
        return wipeAllCallsCount > 0
    }
    var wipeAllClosure: (() -> Void)?

    func wipeAll() {
        wipeAllCallsCount += 1
        wipeAllClosure?()
    }

}
