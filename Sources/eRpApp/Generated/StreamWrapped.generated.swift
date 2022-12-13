// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Combine
import eRpKit
import Foundation
import IDP
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient
import AVS

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






class StreamWrappedAVSTransactionDataStore: AVSTransactionDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<AVSTransactionDataStore, Never>
	private var current: AVSTransactionDataStore

	init(stream: AnyPublisher<AVSTransactionDataStore, Never>, current: AVSTransactionDataStore) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        stream
        	.map { $0.fetchAVSTransaction(
				by: identifier
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        stream
        	.map { $0.listAllAVSTransactions(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        current.save(
				avsTransactions: avsTransactions
            )
	}

	func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        current.delete(
				avsTransactions: avsTransactions
            )
	}

	func save(avsTransaction: AVSTransaction) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        current.save(
				avsTransaction: avsTransaction
            )
	}

	func delete(avsTransaction: AVSTransaction) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        current.delete(
				avsTransaction: avsTransaction
            )
	}


}

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

	func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> {
        stream
        	.map { $0.redeem(
				order: order
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

		stream
			.weakAssign(to: \.current, on: self)
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

class StreamWrappedExtAuthRequestStorage: ExtAuthRequestStorage {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<ExtAuthRequestStorage, Never>
	private var current: ExtAuthRequestStorage

	init(stream: AnyPublisher<ExtAuthRequestStorage, Never>, current: ExtAuthRequestStorage) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> {
		return stream
			.map { $0.pendingExtAuthRequests }
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String) -> Void {
        current.setExtAuthRequest(
				request,
				for: state
            )
	}

	func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession? {
        current.getExtAuthRequest(
				for: state
            )
	}

	func reset() -> Void {
        current.reset(
            )
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
			.weakAssign(to: \.current, on: self)
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

	func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.exchange(
				token: token,
				challengeSession: challengeSession,
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

	func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        stream
        	.map { $0.unregisterDevice(
				keyIdentifier,
				token: token
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        stream
        	.map { $0.listDevices(
				token: token
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

	func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession) -> AnyPublisher<IDPToken, IDPError> {
        stream
        	.map { $0.exchange(
				token: token,
				challengeSession: challengeSession
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func asVAUAccessTokenProvider() -> VAUAccessTokenProvider {
        current.asVAUAccessTokenProvider(
            )
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
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        stream
        	.map { $0.openSecureSession(
				can: can,
				pin: pin
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func sign(can: String, pin: String, challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
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

class StreamWrappedPagedAuditEventsController: PagedAuditEventsController {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<PagedAuditEventsController, Never>
	private var current: PagedAuditEventsController

	init(stream: AnyPublisher<PagedAuditEventsController, Never>, current: PagedAuditEventsController) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func getPageContainer() -> PageContainer? {
        current.getPageContainer(
            )
	}

	func getPage(_ page: Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        stream
        	.map { $0.getPage(
				page
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}


}

class StreamWrappedPharmacyLocalDataStore: PharmacyLocalDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<PharmacyLocalDataStore, Never>
	private var current: PharmacyLocalDataStore

	init(stream: AnyPublisher<PharmacyLocalDataStore, Never>, current: PharmacyLocalDataStore) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        stream
        	.map { $0.fetchPharmacy(
				by: telematikId
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        stream
        	.map { $0.listPharmacies(
				count: count
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        current.save(
				pharmacies: pharmacies
            )
	}

	func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        current.delete(
				pharmacies: pharmacies
            )
	}

	func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        current.update(
				telematikId: telematikId,
				mutating: mutating
            )
	}


}

class StreamWrappedPharmacyRepository: PharmacyRepository {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<PharmacyRepository, Never>
	private var current: PharmacyRepository

	init(stream: AnyPublisher<PharmacyRepository, Never>, current: PharmacyRepository) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}


	func updateFromRemote(by telematikId: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        stream
        	.map { $0.updateFromRemote(
				by: telematikId
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadCached(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        stream
        	.map { $0.loadCached(
				by: telematikId
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func searchRemote(searchTerm: String, position: Position?, filter: [PharmacyRepositoryFilter]) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        stream
        	.map { $0.searchRemote(
				searchTerm: searchTerm,
				position: position,
				filter: filter
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadLocal(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        stream
        	.map { $0.loadLocal(
				by: telematikId
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func loadLocal(count: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        stream
        	.map { $0.loadLocal(
				count: count
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        stream
        	.map { $0.save(
				pharmacies: pharmacies
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        stream
        	.map { $0.delete(
				pharmacies: pharmacies
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        current.save(
				pharmacy: pharmacy
            )
	}

	func delete(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        current.delete(
				pharmacy: pharmacy
            )
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
			.weakAssign(to: \.current, on: self)
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

	func pagedAuditEventsController(for profileId: UUID, with locale: String?) throws -> PagedAuditEventsController {
        try current.pagedAuditEventsController(
				for: profileId,
				with: locale
            )
	}

	func save(profile: Profile) -> AnyPublisher<Bool, LocalStoreError> {
        current.save(
				profile: profile
            )
	}

	func delete(profile: Profile) -> AnyPublisher<Bool, LocalStoreError> {
        current.delete(
				profile: profile
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
			.weakAssign(to: \.current, on: self)
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

class StreamWrappedShipmentInfoDataStore: ShipmentInfoDataStore {
    private var disposeBag: Set<AnyCancellable> = []
	private let stream: AnyPublisher<ShipmentInfoDataStore, Never>
	private var current: ShipmentInfoDataStore

	init(stream: AnyPublisher<ShipmentInfoDataStore, Never>, current: ShipmentInfoDataStore) {
		self.stream = stream
		self.current = current

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
		return stream
			.map { $0.selectedShipmentInfo }
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	func set(selectedShipmentInfoId: UUID) -> Void {
        current.set(
				selectedShipmentInfoId: selectedShipmentInfoId
            )
	}

	func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        stream
        	.map { $0.fetchShipmentInfo(
				by: identifier
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        stream
        	.map { $0.listAllShipmentInfos(
            ) }
            .switchToLatest()
            .eraseToAnyPublisher()
	}

	func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        current.save(
				shipmentInfos: shipmentInfos
            )
	}

	func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        current.delete(
				shipmentInfos: shipmentInfos
            )
	}

	func update(identifier: UUID, mutating: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        current.update(
				identifier: identifier,
				mutating: mutating
            )
	}

	func save(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        current.save(
				shipmentInfo: shipmentInfo
            )
	}

	func delete(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        current.delete(
				shipmentInfo: shipmentInfo
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

		stream
			.weakAssign(to: \.current, on: self)
			.store(in: &disposeBag)


	}

	var hideOnboarding: AnyPublisher<Bool, Never> {
		return stream
			.map { $0.hideOnboarding }
			.switchToLatest()
			.eraseToAnyPublisher()
	}
	var isOnboardingHidden: Bool { current.isOnboardingHidden }
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
	var serverEnvironmentName: String? { current.serverEnvironmentName }
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
	var appConfiguration: AppConfiguration { current.appConfiguration }

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

	func wipeAll() -> Void {
        current.wipeAll(
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

		stream
			.weakAssign(to: \.current, on: self)
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
	lazy var shipmentInfoDataStore: ShipmentInfoDataStore = {
		StreamWrappedShipmentInfoDataStore(stream: stream.map{ $0.shipmentInfoDataStore }.eraseToAnyPublisher(), current: current.shipmentInfoDataStore )
	}()
	lazy var pharmacyRepository: PharmacyRepository = {
		StreamWrappedPharmacyRepository(stream: stream.map{ $0.pharmacyRepository }.eraseToAnyPublisher(), current: current.pharmacyRepository )
	}()
	lazy var localUserStore: UserDataStore = {
		StreamWrappedUserDataStore(stream: stream.map{ $0.localUserStore }.eraseToAnyPublisher(), current: current.localUserStore )
	}()
	lazy var hintEventsStore: EventsStore = {
		StreamWrappedEventsStore(stream: stream.map{ $0.hintEventsStore }.eraseToAnyPublisher(), current: current.hintEventsStore )
	}()
	lazy var secureUserStore: SecureUserDataStore = {
		StreamWrappedSecureUserDataStore(stream: stream.map{ $0.secureUserStore }.eraseToAnyPublisher(), current: current.secureUserStore )
	}()
	var isDemoMode: Bool { current.isDemoMode }
	lazy var nfcSessionProvider: NFCSignatureProvider = {
		StreamWrappedNFCSignatureProvider(stream: stream.map{ $0.nfcSessionProvider }.eraseToAnyPublisher(), current: current.nfcSessionProvider )
	}()
	var nfcHealthCardPasswordController: NFCHealthCardPasswordController { current.nfcHealthCardPasswordController }
	lazy var idpSession: IDPSession = {
		StreamWrappedIDPSession(stream: stream.map{ $0.idpSession }.eraseToAnyPublisher(), current: current.idpSession )
	}()
	lazy var extAuthRequestStorage: ExtAuthRequestStorage = {
		StreamWrappedExtAuthRequestStorage(stream: stream.map{ $0.extAuthRequestStorage }.eraseToAnyPublisher(), current: current.extAuthRequestStorage )
	}()
	lazy var biometrieIdpSession: IDPSession = {
		StreamWrappedIDPSession(stream: stream.map{ $0.biometrieIdpSession }.eraseToAnyPublisher(), current: current.biometrieIdpSession )
	}()
	var vauStorage: VAUStorage { current.vauStorage }
	var trustStoreSession: TrustStoreSession { current.trustStoreSession }
	var appSecurityManager: AppSecurityManager { current.appSecurityManager }
	var deviceSecurityManager: DeviceSecurityManager { current.deviceSecurityManager }
	var profileId: UUID { current.profileId }
	var avsSession: AVSSession { current.avsSession }
	lazy var avsTransactionDataStore: AVSTransactionDataStore = {
		StreamWrappedAVSTransactionDataStore(stream: stream.map{ $0.avsTransactionDataStore }.eraseToAnyPublisher(), current: current.avsTransactionDataStore )
	}()

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
