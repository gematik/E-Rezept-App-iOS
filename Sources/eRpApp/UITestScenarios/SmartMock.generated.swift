// Generated using Sourcery 2.1.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
/// Use sourcery to update this file.

import Pharmacy
import eRpKit
import Combine
import OpenSSL
import Foundation

// MARK: - SmartMockPharmacyRemoteDataStore -

class SmartMockPharmacyRemoteDataStore: PharmacyRemoteDataStore, SmartMock {
    private var wrapped: PharmacyRemoteDataStore
    private var isRecording: Bool

    init(wrapped: PharmacyRemoteDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        searchPharmaciesByPositionFilterRecordings = mocks?.searchPharmaciesByPositionFilterRecordings ?? .delegate
        fetchPharmacyByRecordings = mocks?.fetchPharmacyByRecordings ?? .delegate
        loadAvsCertificatesForRecordings = mocks?.loadAvsCertificatesForRecordings ?? .delegate
    }

    var searchPharmaciesByPositionFilterRecordings: MockAnswer<[PharmacyLocation]>

    func searchPharmacies(by searchTerm: String, position: Position?, filter: [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.searchPharmacies(
                    by: searchTerm,
                    position: position,
                    filter: filter
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.searchPharmaciesByPositionFilterRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = searchPharmaciesByPositionFilterRecordings.next() {
            return Just(value)
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.searchPharmacies(
                    by: searchTerm,
                    position: position,
                    filter: filter
            )
        }
    }

    var fetchPharmacyByRecordings: MockAnswer<PharmacyLocation?>

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.fetchPharmacy(
                    by: telematikId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchPharmacyByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchPharmacyByRecordings.next() {
            return Just(value)
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchPharmacy(
                    by: telematikId
            )
        }
    }

    var loadAvsCertificatesForRecordings: MockAnswer<[SerializableX509]>

    func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.loadAvsCertificates(
                    for: locationId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.loadAvsCertificatesForRecordings.record(SerializableX509.from(value))
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = loadAvsCertificatesForRecordings.next() {
            return Just(value.unwrap)
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.loadAvsCertificates(
                    for: locationId
            )
        }
    }

    struct Mocks: Codable {
        var searchPharmaciesByPositionFilterRecordings: MockAnswer<[PharmacyLocation]>? = .delegate
        var fetchPharmacyByRecordings: MockAnswer<PharmacyLocation?>? = .delegate
        var loadAvsCertificatesForRecordings: MockAnswer<[SerializableX509]>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "PharmacyRemoteDataStore",
            Mocks(
                searchPharmaciesByPositionFilterRecordings: searchPharmaciesByPositionFilterRecordings,
                fetchPharmacyByRecordings: fetchPharmacyByRecordings,
                loadAvsCertificatesForRecordings: loadAvsCertificatesForRecordings
            )
        )
    }
}


// MARK: - SmartMockUserDataStore -

class SmartMockUserDataStore: UserDataStore, SmartMock {
    private var wrapped: UserDataStore
    private var isRecording: Bool

    init(wrapped: UserDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        hideOnboardingRecordings = mocks?.hideOnboardingRecordings ?? .delegate
        isOnboardingHiddenRecordings = mocks?.isOnboardingHiddenRecordings ?? .delegate
        onboardingVersionRecordings = mocks?.onboardingVersionRecordings ?? .delegate
        hideCardWallIntroRecordings = mocks?.hideCardWallIntroRecordings ?? .delegate
        serverEnvironmentConfigurationRecordings = mocks?.serverEnvironmentConfigurationRecordings ?? .delegate
        serverEnvironmentNameRecordings = mocks?.serverEnvironmentNameRecordings ?? .delegate
        appSecurityOptionRecordings = mocks?.appSecurityOptionRecordings ?? .delegate
        failedAppAuthenticationsRecordings = mocks?.failedAppAuthenticationsRecordings ?? .delegate
        ignoreDeviceNotSecuredWarningPermanentlyRecordings = mocks?.ignoreDeviceNotSecuredWarningPermanentlyRecordings ?? .delegate
        selectedProfileIdRecordings = mocks?.selectedProfileIdRecordings ?? .delegate
        latestCompatibleModelVersionRecordings = mocks?.latestCompatibleModelVersionRecordings ?? .delegate
        appStartCounterRecordings = mocks?.appStartCounterRecordings ?? .delegate
        hideWelcomeDrawerRecordings = mocks?.hideWelcomeDrawerRecordings ?? .delegate
    }

    var hideOnboardingRecordings: MockAnswer<Bool>

    var hideOnboarding: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideOnboarding
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideOnboardingRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideOnboardingRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideOnboarding
        }
    }
    var isOnboardingHiddenRecordings: MockAnswer<Bool>
    var isOnboardingHidden: Bool {
        guard !isRecording else {
            let result = wrapped.isOnboardingHidden
            isOnboardingHiddenRecordings.record(result)
            return result
        }
        if let first = isOnboardingHiddenRecordings.next() {
            return first
        }
        return wrapped.isOnboardingHidden
    }
    var onboardingVersionRecordings: MockAnswer<String?>

    var onboardingVersion: AnyPublisher<String?, Never> {
        guard !isRecording else {
            return wrapped.onboardingVersion
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.onboardingVersionRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = onboardingVersionRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.onboardingVersion
        }
    }
    var hideCardWallIntroRecordings: MockAnswer<Bool>

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideCardWallIntro
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideCardWallIntroRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideCardWallIntroRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideCardWallIntro
        }
    }
    var serverEnvironmentConfigurationRecordings: MockAnswer<String?>

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        guard !isRecording else {
            return wrapped.serverEnvironmentConfiguration
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.serverEnvironmentConfigurationRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = serverEnvironmentConfigurationRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.serverEnvironmentConfiguration
        }
    }
    var serverEnvironmentNameRecordings: MockAnswer<String?>
    var serverEnvironmentName: String? {
        guard !isRecording else {
            let result = wrapped.serverEnvironmentName
            serverEnvironmentNameRecordings.record(result)
            return result
        }
        if let first = serverEnvironmentNameRecordings.next() {
            return first
        }
        return wrapped.serverEnvironmentName
    }
    var appSecurityOptionRecordings: MockAnswer<AppSecurityOption>

    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        guard !isRecording else {
            return wrapped.appSecurityOption
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.appSecurityOptionRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = appSecurityOptionRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.appSecurityOption
        }
    }
    var failedAppAuthenticationsRecordings: MockAnswer<Int>

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        guard !isRecording else {
            return wrapped.failedAppAuthentications
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.failedAppAuthenticationsRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = failedAppAuthenticationsRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.failedAppAuthentications
        }
    }
    var ignoreDeviceNotSecuredWarningPermanentlyRecordings: MockAnswer<Bool>

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.ignoreDeviceNotSecuredWarningPermanently
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.ignoreDeviceNotSecuredWarningPermanentlyRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = ignoreDeviceNotSecuredWarningPermanentlyRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.ignoreDeviceNotSecuredWarningPermanently
        }
    }
    var selectedProfileIdRecordings: MockAnswer<UUID?>

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        guard !isRecording else {
            return wrapped.selectedProfileId
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.selectedProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = selectedProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.selectedProfileId
        }
    }
    var latestCompatibleModelVersionRecordings: MockAnswer<ModelVersion>
    var latestCompatibleModelVersion: ModelVersion {
        set {
            if isRecording {
                latestCompatibleModelVersionRecordings.record(newValue)
            }
            wrapped.latestCompatibleModelVersion = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.latestCompatibleModelVersion
                latestCompatibleModelVersionRecordings.record(result)
                return result
            }

            if let first = latestCompatibleModelVersionRecordings.next() {
                return first
            }
            return wrapped.latestCompatibleModelVersion
        }
    }
    var appStartCounterRecordings: MockAnswer<Int>
    var appStartCounter: Int {
        set {
            if isRecording {
                appStartCounterRecordings.record(newValue)
            }
            wrapped.appStartCounter = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.appStartCounter
                appStartCounterRecordings.record(result)
                return result
            }

            if let first = appStartCounterRecordings.next() {
                return first
            }
            return wrapped.appStartCounter
        }
    }
    var hideWelcomeDrawerRecordings: MockAnswer<Bool>
    var hideWelcomeDrawer: Bool {
        set {
            if isRecording {
                hideWelcomeDrawerRecordings.record(newValue)
            }
            wrapped.hideWelcomeDrawer = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.hideWelcomeDrawer
                hideWelcomeDrawerRecordings.record(result)
                return result
            }

            if let first = hideWelcomeDrawerRecordings.next() {
                return first
            }
            return wrapped.hideWelcomeDrawer
        }
    }
    func set(hideOnboarding: Bool) {
        wrapped.set(
                    hideOnboarding: hideOnboarding
            )
    }

    func set(onboardingVersion: String?) {
        wrapped.set(
                    onboardingVersion: onboardingVersion
            )
    }

    func set(hideCardWallIntro: Bool) {
        wrapped.set(
                    hideCardWallIntro: hideCardWallIntro
            )
    }

    func set(serverEnvironmentConfiguration: String?) {
        wrapped.set(
                    serverEnvironmentConfiguration: serverEnvironmentConfiguration
            )
    }

    func set(appSecurityOption: AppSecurityOption) {
        wrapped.set(
                    appSecurityOption: appSecurityOption
            )
    }

    func set(failedAppAuthentications: Int) {
        wrapped.set(
                    failedAppAuthentications: failedAppAuthentications
            )
    }

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        wrapped.set(
                    ignoreDeviceNotSecuredWarningPermanently: ignoreDeviceNotSecuredWarningPermanently
            )
    }

    func set(selectedProfileId: UUID) {
        wrapped.set(
                    selectedProfileId: selectedProfileId
            )
    }

    func wipeAll() {
        wrapped.wipeAll(
            )
    }

    /// AnyObject
    struct Mocks: Codable {
        var hideOnboardingRecordings: MockAnswer<Bool>? = .delegate
        var isOnboardingHiddenRecordings: MockAnswer<Bool>? = .delegate
        var onboardingVersionRecordings: MockAnswer<String?>? = .delegate
        var hideCardWallIntroRecordings: MockAnswer<Bool>? = .delegate
        var serverEnvironmentConfigurationRecordings: MockAnswer<String?>? = .delegate
        var serverEnvironmentNameRecordings: MockAnswer<String?>? = .delegate
        var appSecurityOptionRecordings: MockAnswer<AppSecurityOption>? = .delegate
        var failedAppAuthenticationsRecordings: MockAnswer<Int>? = .delegate
        var ignoreDeviceNotSecuredWarningPermanentlyRecordings: MockAnswer<Bool>? = .delegate
        var selectedProfileIdRecordings: MockAnswer<UUID?>? = .delegate
        var latestCompatibleModelVersionRecordings: MockAnswer<ModelVersion>? = .delegate
        var appStartCounterRecordings: MockAnswer<Int>? = .delegate
        var hideWelcomeDrawerRecordings: MockAnswer<Bool>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "UserDataStore",
            Mocks(
                hideOnboardingRecordings:hideOnboardingRecordings,
                isOnboardingHiddenRecordings: isOnboardingHiddenRecordings,
                onboardingVersionRecordings:onboardingVersionRecordings,
                hideCardWallIntroRecordings:hideCardWallIntroRecordings,
                serverEnvironmentConfigurationRecordings:serverEnvironmentConfigurationRecordings,
                serverEnvironmentNameRecordings: serverEnvironmentNameRecordings,
                appSecurityOptionRecordings:appSecurityOptionRecordings,
                failedAppAuthenticationsRecordings:failedAppAuthenticationsRecordings,
                ignoreDeviceNotSecuredWarningPermanentlyRecordings:ignoreDeviceNotSecuredWarningPermanentlyRecordings,
                selectedProfileIdRecordings:selectedProfileIdRecordings,
                latestCompatibleModelVersionRecordings: latestCompatibleModelVersionRecordings,
                appStartCounterRecordings: appStartCounterRecordings,
                hideWelcomeDrawerRecordings: hideWelcomeDrawerRecordings
            )
        )
    }
}


struct SerializableX509: Codable {
    let payload: X509
    init(with payload: X509) {
        self.payload = payload
    }
    static func from(_ list: Array<X509>) -> Array<SerializableX509> {
        list.map { SerializableX509(with: $0) }
    }

    static func from(_ value: X509) -> SerializableX509 {
        SerializableX509(with: value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(payload.derBytes ?? nil)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let x509Data = try container.decode(Data.self)
        payload = try X509(der: x509Data)
    }
    var unwrap: X509 {
        return payload
    }
}

extension Array where Element == SerializableX509 {
    var unwrap: [X509] {
        map(\.payload)
    }
}
