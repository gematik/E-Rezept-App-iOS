// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Combine
import eRpKit
import Foundation
import HealthCardAccess
import HealthCardControl
import IDP
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient

/// AUTO GENERATED – DO NOT EDIT
///
/// use sourcery to update this file.

/// # StreamWrapped
///
/// Creates a wrapper class for any Protocol that takes a stream of instances of the protocol. The implementation uses the stream for the actual implementation. The following cases for methods and properties may occur:
/// - function with a result of type `AnyPublisher`: The function will be called on the current stream element and on each new element as long as the subscription exists. Long running tasks may get canceled through `switchToLatest` functionality.
/// - function with any other or no result type: The function will be called once on the current element of the stream
/// - property with a type based on AnyPublisher: The property will be flat mapped on the stream to the actual implementation.
/// - property with any other type: The current element determines the value of the property.
///
/// # Usage
///
/// - Add `/// Sourcery: StreamWrapped` to any protocol that should be wrapped.
/// - Run `$ sourcery` to update or add protocols. 






class StreamWrappedErxTaskRepository: ErxTaskRepository {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<ErxTaskRepository, Never>

	init(stream: AnyPublisher<ErxTaskRepository, Never>) {
		self.stream = stream




	}


	func loadRemote(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        stream
        	.map { $0.loadRemote(
				by: id,
				accessCode: accessCode
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadLocal(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        stream
        	.map { $0.loadLocal(
				by: id,
				accessCode: accessCode
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadLocalAll() -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        stream
        	.map { $0.loadLocalAll(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadRemoteAll(for locale: String?) -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        stream
        	.map { $0.loadRemoteAll(
				for: locale
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        stream
        	.map { $0.save(
				erxTasks: erxTasks
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        stream
        	.map { $0.delete(
				erxTasks: erxTasks
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErxRepositoryError> {
        stream
        	.map { $0.redeem(
				orders: orders
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadLocalCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> {
        stream
        	.map { $0.loadLocalCommunications(
				for: profile
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError> {
        stream
        	.map { $0.saveLocal(
				communications: communications
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func countAllUnreadCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<Int, ErxRepositoryError> {
        stream
        	.map { $0.countAllUnreadCommunications(
				for: profile
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}


}

class StreamWrappedEventsStore: EventsStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<EventsStore, Never>
	private var current: EventsStore

	init(stream: AnyPublisher<EventsStore, Never>, current: EventsStore) {
		self.stream = stream
		self.current = current

		self.hintState = current.hintState

		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var hintStatePublisher: AnyPublisher<HintState, Never> {
		return stream
			.map { $0.hintStatePublisher }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var hintState: HintState {
		set { current.hintState = newValue }
		get { current.hintState }
	}


	/// AnyObject
}

class StreamWrappedIDPSession: IDPSession {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<IDPSession, Never>
	private var current: IDPSession

	init(stream: AnyPublisher<IDPSession, Never>, current: IDPSession) {
		self.stream = stream
		self.current = current


		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var isLoggedIn: AnyPublisher<Bool, IDPError> {
		return stream
			.map { $0.isLoggedIn }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
		return stream
			.map { $0.autoRefreshedToken }
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	func invalidateAccessToken() -> Void {
        current.invalidateAccessToken(
            )
	}

	func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        stream
        	.map { $0.requestChallenge(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        stream
        	.map { $0.verify(
				signedChallenge
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, redirectURI: String?, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.exchange(
				token: token,
				challengeSession: challengeSession,
				redirectURI: redirectURI,
				idTokenValidator: idTokenValidator
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.refresh(
				token: token
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        stream
        	.map { $0.pairDevice(
				with: registrationData,
				token: token
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func unregisterDevice(_ keyIdentifier: String) -> AnyPublisher<Bool, IDPError> {
        stream
        	.map { $0.unregisterDevice(
				keyIdentifier
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        stream
        	.map { $0.altVerify(
				signedChallenge
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        stream
        	.map { $0.loadDirectoryKKApps(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        stream
        	.map { $0.startExtAuth(
				entry: entry
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func extAuthVerifyAndExchange(_ url: URL, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.extAuthVerifyAndExchange(
				url,
				idTokenValidator: idTokenValidator
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func asVAUAccessTokenProvider() -> VAUAccessTokenProvider {
        current.asVAUAccessTokenProvider(
            )
	}

	func verifyAndExchange(signedChallenge: SignedChallenge, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.verifyAndExchange(
				signedChallenge: signedChallenge,
				idTokenValidator: idTokenValidator
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func httpInterceptor(delegate: IDPSessionDelegate?) -> IDPInterceptor {
        current.httpInterceptor(
				delegate: delegate
            )
	}

	func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, redirectURI: String?) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.exchange(
				token: token,
				challengeSession: challengeSession,
				redirectURI: redirectURI
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}


}

class StreamWrappedNFCSignatureProvider: NFCSignatureProvider {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<NFCSignatureProvider, Never>
	private var current: NFCSignatureProvider

	init(stream: AnyPublisher<NFCSignatureProvider, Never>, current: NFCSignatureProvider) {
		self.stream = stream
		self.current = current


		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func openSecureSession(can: CAN, pin: Format2Pin) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        stream
        	.map { $0.openSecureSession(
				can: can,
				pin: pin
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func sign(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        stream
        	.map { $0.sign(
				can: can,
				pin: pin,
				challenge: challenge
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}


}

class StreamWrappedProfileDataStore: ProfileDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<ProfileDataStore, Never>
	private var current: ProfileDataStore

	init(stream: AnyPublisher<ProfileDataStore, Never>, current: ProfileDataStore) {
		self.stream = stream
		self.current = current


		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        stream
        	.map { $0.fetchProfile(
				by: identifier
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        stream
        	.map { $0.listAllProfiles(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        current.save(
				profiles: profiles
            )
	}

	func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        current.delete(
				profiles: profiles
            )
	}

	func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        current.update(
				profileId: profileId,
				mutating: mutating
            )
	}


}

class StreamWrappedSecureUserDataStore: SecureUserDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<SecureUserDataStore, Never>
	private var current: SecureUserDataStore

	init(stream: AnyPublisher<SecureUserDataStore, Never>, current: SecureUserDataStore) {
		self.stream = stream
		self.current = current


		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var can: AnyPublisher<String?, Never> {
		return stream
			.map { $0.can }
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	func set(can: String?) -> Void {
        current.set(
				can: can
            )
	}

	func wipe() -> Void {
        current.wipe(
            )
	}


	/// IDPStorage
	var token: AnyPublisher<IDPToken?, Never> {
		return stream
			.map { $0.token }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
		return stream
			.map { $0.discoveryDocument }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	func set(token: IDPToken?) -> Void {
        current.set(
				token: token
            )
	}

	func set(discovery document: DiscoveryDocument?) -> Void {
        current.set(
				discovery: document
            )
	}

	/// SecureEGKCertificateStorage
	var certificate: AnyPublisher<X509?, Never> {
		return stream
			.map { $0.certificate }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var keyIdentifier: AnyPublisher<Data?, Never> {
		return stream
			.map { $0.keyIdentifier }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	func set(certificate: X509?) -> Void {
        current.set(
				certificate: certificate
            )
	}

	func set(keyIdentifier: Data?) -> Void {
        current.set(
				keyIdentifier: keyIdentifier
            )
	}

}

class StreamWrappedUserDataStore: UserDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<UserDataStore, Never>
	private var current: UserDataStore

	init(stream: AnyPublisher<UserDataStore, Never>, current: UserDataStore) {
		self.stream = stream
		self.current = current

		self.isOnboardingHidden = current.isOnboardingHidden
		self.latestCompatibleModelVersion = current.latestCompatibleModelVersion
		self.appStartCounter = current.appStartCounter

		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)

		stream
			.map(\.isOnboardingHidden)
			.assign(to: \.isOnboardingHidden, on: self)
			.store(in: &disposeBag)

	}

	var hideOnboarding: AnyPublisher<Bool, Never> {
		return stream
			.map { $0.hideOnboarding }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	private(set) var isOnboardingHidden: Bool
	var onboardingVersion: AnyPublisher<String?, Never> {
		return stream
			.map { $0.onboardingVersion }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var hideCardWallIntro: AnyPublisher<Bool, Never> {
		return stream
			.map { $0.hideCardWallIntro }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
		return stream
			.map { $0.serverEnvironmentConfiguration }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var appSecurityOption: AnyPublisher<Int, Never> {
		return stream
			.map { $0.appSecurityOption }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var failedAppAuthentications: AnyPublisher<Int, Never> {
		return stream
			.map { $0.failedAppAuthentications }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
		return stream
			.map { $0.ignoreDeviceNotSecuredWarningPermanently }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var selectedProfileId: AnyPublisher<UUID?, Never> {
		return stream
			.map { $0.selectedProfileId }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var latestCompatibleModelVersion: ModelVersion {
		set { current.latestCompatibleModelVersion = newValue }
		get { current.latestCompatibleModelVersion }
	}
	var appStartCounter: Int {
		set { current.appStartCounter = newValue }
		get { current.appStartCounter }
	}
	var configuration: AnyPublisher<AppConfiguration, Never> {
		return stream
			.map { $0.configuration }
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	func set(hideOnboarding: Bool) -> Void {
        current.set(
				hideOnboarding: hideOnboarding
            )
	}

	func set(onboardingVersion: String?) -> Void {
        current.set(
				onboardingVersion: onboardingVersion
            )
	}

	func set(hideCardWallIntro: Bool) -> Void {
        current.set(
				hideCardWallIntro: hideCardWallIntro
            )
	}

	func set(serverEnvironmentConfiguration: String?) -> Void {
        current.set(
				serverEnvironmentConfiguration: serverEnvironmentConfiguration
            )
	}

	func set(appSecurityOption: Int) -> Void {
        current.set(
				appSecurityOption: appSecurityOption
            )
	}

	func set(failedAppAuthentications: Int) -> Void {
        current.set(
				failedAppAuthentications: failedAppAuthentications
            )
	}

	func set(ignoreDeviceNotSecuredWarningPermanently: Bool) -> Void {
        current.set(
				ignoreDeviceNotSecuredWarningPermanently: ignoreDeviceNotSecuredWarningPermanently
            )
	}

	func set(selectedProfileId: UUID) -> Void {
        current.set(
				selectedProfileId: selectedProfileId
            )
	}


	/// AnyObject
}

class StreamWrappedUserSession: UserSession {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<UserSession, Never>
	private var current: UserSession

	init(stream: AnyPublisher<UserSession, Never>, current: UserSession) {
		self.stream = stream
		self.current = current

		self.pharmacyRepository = current.pharmacyRepository
		self.isDemoMode = current.isDemoMode
		self.extAuthRequestStorage = current.extAuthRequestStorage
		self.vauStorage = current.vauStorage
		self.trustStoreSession = current.trustStoreSession
		self.appSecurityManager = current.appSecurityManager
		self.deviceSecurityManager = current.deviceSecurityManager
		self.profileId = current.profileId
		self.profileSecureDataWiper = current.profileSecureDataWiper

		stream
			.assign(to: \.current, on: self)
			.store(in: &disposeBag)

		stream
			.map(\.pharmacyRepository)
			.assign(to: \.pharmacyRepository, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.isDemoMode)
			.assign(to: \.isDemoMode, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.extAuthRequestStorage)
			.assign(to: \.extAuthRequestStorage, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.vauStorage)
			.assign(to: \.vauStorage, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.trustStoreSession)
			.assign(to: \.trustStoreSession, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.appSecurityManager)
			.assign(to: \.appSecurityManager, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.deviceSecurityManager)
			.assign(to: \.deviceSecurityManager, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.profileId)
			.assign(to: \.profileId, on: self)
			.store(in: &disposeBag)
		stream
			.map(\.profileSecureDataWiper)
			.assign(to: \.profileSecureDataWiper, on: self)
			.store(in: &disposeBag)

	}

	var isAuthenticated: AnyPublisher<Bool, UserSessionError> {
		return stream
			.map { $0.isAuthenticated }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	lazy var erxTaskRepository: ErxTaskRepository = {
		StreamWrappedErxTaskRepository(stream: stream.map{ $0.erxTaskRepository }.eraseToAnyPublisher() )
	}()
	lazy var profileDataStore: ProfileDataStore = {
		StreamWrappedProfileDataStore(stream: stream.map{ $0.profileDataStore }.eraseToAnyPublisher(), current: current.profileDataStore )
	}()
	private(set) var pharmacyRepository: PharmacyRepository
	lazy var localUserStore: UserDataStore = {
		StreamWrappedUserDataStore(stream: stream.map{ $0.localUserStore }.eraseToAnyPublisher(), current: current.localUserStore )
	}()
	lazy var hintEventsStore: EventsStore = {
		StreamWrappedEventsStore(stream: stream.map{ $0.hintEventsStore }.eraseToAnyPublisher(), current: current.hintEventsStore )
	}()
	lazy var secureUserStore: SecureUserDataStore = {
		StreamWrappedSecureUserDataStore(stream: stream.map{ $0.secureUserStore }.eraseToAnyPublisher(), current: current.secureUserStore )
	}()
	private(set) var isDemoMode: Bool
	lazy var nfcSessionProvider: NFCSignatureProvider = {
		StreamWrappedNFCSignatureProvider(stream: stream.map{ $0.nfcSessionProvider }.eraseToAnyPublisher(), current: current.nfcSessionProvider )
	}()
	lazy var idpSession: IDPSession = {
		StreamWrappedIDPSession(stream: stream.map{ $0.idpSession }.eraseToAnyPublisher(), current: current.idpSession )
	}()
	private(set) var extAuthRequestStorage: ExtAuthRequestStorage
	lazy var biometrieIdpSession: IDPSession = {
		StreamWrappedIDPSession(stream: stream.map{ $0.biometrieIdpSession }.eraseToAnyPublisher(), current: current.biometrieIdpSession )
	}()
	private(set) var vauStorage: VAUStorage
	private(set) var trustStoreSession: TrustStoreSession
	private(set) var appSecurityManager: AppSecurityManager
	private(set) var deviceSecurityManager: DeviceSecurityManager
	private(set) var profileId: UUID
	private(set) var profileSecureDataWiper: ProfileSecureDataWiper

	func profile() -> AnyPublisher<Profile, LocalStoreError> {
        stream
        	.map { $0.profile(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func idTokenValidator() -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        stream
        	.map { $0.idTokenValidator(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}


}
