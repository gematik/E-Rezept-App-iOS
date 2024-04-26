// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import Foundation

@testable import eRpLocalStorage

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockCoreDataControllerFactory -

final class MockCoreDataControllerFactory: CoreDataControllerFactory {
    
   // MARK: - databaseUrl

    var databaseUrl: URL {
        get { underlyingDatabaseUrl }
        set(value) { underlyingDatabaseUrl = value }
    }
    var underlyingDatabaseUrl: URL!
    
   // MARK: - loadCoreDataController

    var loadCoreDataControllerThrowableError: Error?
    var loadCoreDataControllerCallsCount = 0
    var loadCoreDataControllerCalled: Bool {
        loadCoreDataControllerCallsCount > 0
    }
    var loadCoreDataControllerReturnValue: CoreDataController!
    var loadCoreDataControllerClosure: (() throws -> CoreDataController)?

    func loadCoreDataController() throws -> CoreDataController {
        if let error = loadCoreDataControllerThrowableError {
            throw error
        }
        loadCoreDataControllerCallsCount += 1
        return try loadCoreDataControllerClosure.map({ try $0() }) ?? loadCoreDataControllerReturnValue
    }
}


// MARK: - MockUserDataStore -

final class MockUserDataStore: UserDataStore {
    
   // MARK: - hideOnboarding

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    var underlyingHideOnboarding: AnyPublisher<Bool, Never>!
    
   // MARK: - isOnboardingHidden

    var isOnboardingHidden: Bool {
        get { underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    var underlyingIsOnboardingHidden: Bool!
    
   // MARK: - onboardingVersion

    var onboardingVersion: AnyPublisher<String?, Never> {
        get { underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    var underlyingOnboardingVersion: AnyPublisher<String?, Never>!
    
   // MARK: - hideCardWallIntro

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    var underlyingHideCardWallIntro: AnyPublisher<Bool, Never>!
    
   // MARK: - serverEnvironmentConfiguration

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    var underlyingServerEnvironmentConfiguration: AnyPublisher<String?, Never>!
    var serverEnvironmentName: String?
    
   // MARK: - appSecurityOption

    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    var underlyingAppSecurityOption: AnyPublisher<AppSecurityOption, Never>!
    
   // MARK: - failedAppAuthentications

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    var underlyingFailedAppAuthentications: AnyPublisher<Int, Never>!
    
   // MARK: - ignoreDeviceNotSecuredWarningPermanently

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never>!
    
   // MARK: - selectedProfileId

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!
    
   // MARK: - latestCompatibleModelVersion

    var latestCompatibleModelVersion: ModelVersion {
        get { underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    var underlyingLatestCompatibleModelVersion: ModelVersion!
    
   // MARK: - appStartCounter

    var appStartCounter: Int {
        get { underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    var underlyingAppStartCounter: Int!
    
   // MARK: - hideWelcomeDrawer

    var hideWelcomeDrawer: Bool {
        get { underlyingHideWelcomeDrawer }
        set(value) { underlyingHideWelcomeDrawer = value }
    }
    var underlyingHideWelcomeDrawer: Bool!
    
   // MARK: - set

    var setHideOnboardingCallsCount = 0
    var setHideOnboardingCalled: Bool {
        setHideOnboardingCallsCount > 0
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
    
   // MARK: - set

    var setOnboardingVersionCallsCount = 0
    var setOnboardingVersionCalled: Bool {
        setOnboardingVersionCallsCount > 0
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
    
   // MARK: - set

    var setAppSecurityOptionCallsCount = 0
    var setAppSecurityOptionCalled: Bool {
        setAppSecurityOptionCallsCount > 0
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
    
   // MARK: - set

    var setFailedAppAuthenticationsCallsCount = 0
    var setFailedAppAuthenticationsCalled: Bool {
        setFailedAppAuthenticationsCallsCount > 0
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
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently = ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }
    
   // MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        setSelectedProfileIdCallsCount > 0
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
    
   // MARK: - wipeAll

    var wipeAllCallsCount = 0
    var wipeAllCalled: Bool {
        wipeAllCallsCount > 0
    }
    var wipeAllClosure: (() -> Void)?

    func wipeAll() {
        wipeAllCallsCount += 1
        wipeAllClosure?()
    }
}
