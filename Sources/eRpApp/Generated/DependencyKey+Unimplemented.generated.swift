// Generated using Sourcery 2.1.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import AVS
import Combine
import CombineSchedulers
import CoreData
import LocalAuthentication
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import HTTPClient
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient
import UIKit
import XCTestDynamicOverlay







struct UnimplementedAppAuthenticationProvider: AppAuthenticationProvider {
    init() {}

    func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityOption, Never> {
        fatalError("loadAppAuthenticationOption has not been implemented")
    }
}
struct UnimplementedAppSecurityManager: AppSecurityManager {
    init() {}

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func save(password: String) throws -> Bool {
        fatalError("save(password:) has not been implemented")
    }
    func matches(password: String) throws -> Bool {
        fatalError("matches(password:) has not been implemented")
    }
}
struct UnimplementedAuthenticationChallengeProvider: AuthenticationChallengeProvider {
    init() {}

    func startAuthenticationChallenge() -> AnyPublisher<Result<Bool, AuthenticationChallengeProviderError>, Never> {
        fatalError("startAuthenticationChallenge has not been implemented")
    }
}
struct UnimplementedChargeItemListDomainService: ChargeItemListDomainService {
    init() {}

    func fetchLocalChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fatalError("fetchLocalChargeItems(for:) has not been implemented")
    }
    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fatalError("fetchRemoteChargeItemsAndSave(for:) has not been implemented")
    }
    func delete(chargeItem: ErxChargeItem, for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        fatalError("delete(chargeItem:for:) has not been implemented")
    }
    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never> {
        fatalError("authenticate(for:) has not been implemented")
    }
    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> {
        fatalError("grantChargeItemsConsent(for:) has not been implemented")
    }
    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fatalError("fetchChargeItemsAssumingConsentGranted(for:) has not been implemented")
    }
    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> {
        fatalError("revokeChargeItemsConsent(for:) has not been implemented")
    }
}
struct UnimplementedChargeItemPDFService: ChargeItemPDFService {
    init() {}

    func generatePDF(for chargeItem: ErxChargeItem) throws -> Data {
        fatalError("generatePDF(for:) has not been implemented")
    }
    func loadPDFOrGenerate(for chargeItem: ErxChargeItem) throws -> URL {
        fatalError("loadPDFOrGenerate(for:) has not been implemented")
    }
}
struct UnimplementedCoreDataControllerFactory: CoreDataControllerFactory {
    init() {}

    var databaseUrl: URL {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func loadCoreDataController() throws -> CoreDataController {
        fatalError("loadCoreDataController has not been implemented")
    }
}
struct UnimplementedAuditEventsService: AuditEventsService {
    init() {}

    func loadAuditEvents(for profileId: UUID, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        fatalError("loadAuditEvents(for:locale:) has not been implemented")
    }
    func loadNextAuditEvents(for profileId: UUID, url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        fatalError("loadNextAuditEvents(for:url:locale:) has not been implemented")
    }
}
struct UnimplementedDeviceSecurityManager: DeviceSecurityManager {
    init() {}

    var showSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var informMissingSystemPin: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func set(ignoreDeviceSystemPinWarningForSession: Bool) -> Void {
        fatalError("set(ignoreDeviceSystemPinWarningForSession:) has not been implemented")
    }
    func set(ignoreDeviceSystemPinWarningPermanently: Bool) -> Void {
        fatalError("set(ignoreDeviceSystemPinWarningPermanently:) has not been implemented")
    }
    func informJailbreakDetected() -> Bool {
        fatalError("informJailbreakDetected has not been implemented")
    }
    func set(ignoreRootedDeviceWarningForSession: Bool) -> Void {
        fatalError("set(ignoreRootedDeviceWarningForSession:) has not been implemented")
    }
}
struct UnimplementedErxMatrixCodeGenerator: ErxMatrixCodeGenerator {
    init() {}

    func matrixCode(for tasks: [ErxTask], with size: CGSize) throws -> CGImage {
        fatalError("matrixCode(for:with:) has not been implemented")
    }
    func matrixCodePublisher(for tasks: [ErxTask], with size: CGSize, scale: CGFloat, orientation: UIImage.Orientation) -> AnyPublisher<UIImage, Error> {
        fatalError("matrixCodePublisher(for:with:scale:orientation:) has not been implemented")
    }
    func matrixCode(for chargeItem: ErxChargeItem, with size: CGSize) throws -> CGImage {
        fatalError("matrixCode(for:with:) has not been implemented")
    }
    func matrixCodePublisher(for chargeItem: ErxChargeItem, with size: CGSize, scale: CGFloat, orientation: UIImage.Orientation) -> AnyPublisher<UIImage, Error> {
        fatalError("matrixCodePublisher(for:with:scale:orientation:) has not been implemented")
    }
    func publishedMatrixCode(for tasks: [ErxTask], with size: CGSize) -> AnyPublisher<UIImage, Error> {
        fatalError("publishedMatrixCode(for:with:) has not been implemented")
    }
    func publishedMatrixCode(for chargeItem: ErxChargeItem, with size: CGSize) -> AnyPublisher<UIImage, Error> {
        fatalError("publishedMatrixCode(for:with:) has not been implemented")
    }
}
struct UnimplementedErxTaskRepository: ErxTaskRepository {
    init() {}

    func loadRemote(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        fatalError("loadRemote(by:accessCode:) has not been implemented")
    }
    func loadLocal(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        fatalError("loadLocal(by:accessCode:) has not been implemented")
    }
    func loadLocalAll() -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        fatalError("loadLocalAll has not been implemented")
    }
    func loadRemoteAll(for locale: String?) -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        fatalError("loadRemoteAll(for:) has not been implemented")
    }
    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("save(erxTasks:) has not been implemented")
    }
    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("delete(erxTasks:) has not been implemented")
    }
    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> {
        fatalError("redeem(order:) has not been implemented")
    }
    func loadLocalCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> {
        fatalError("loadLocalCommunications(for:) has not been implemented")
    }
    func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("saveLocal(communications:) has not been implemented")
    }
    func countAllUnreadCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<Int, ErxRepositoryError> {
        fatalError("countAllUnreadCommunications(for:) has not been implemented")
    }
    func loadRemoteLatestAuditEvents(for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> {
        fatalError("loadRemoteLatestAuditEvents(for:) has not been implemented")
    }
    func loadRemoteAuditEventsPage(from url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> {
        fatalError("loadRemoteAuditEventsPage(from:locale:) has not been implemented")
    }
    func loadRemoteChargeItems() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        fatalError("loadRemoteChargeItems has not been implemented")
    }
    func fetchConsents() -> AnyPublisher<[ErxConsent], ErxRepositoryError> {
        fatalError("fetchConsents has not been implemented")
    }
    func loadLocal(by id: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> {
        fatalError("loadLocal(by:) has not been implemented")
    }
    func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        fatalError("loadLocalAll has not been implemented")
    }
    func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("save(chargeItems:) has not been implemented")
    }
    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("delete(chargeItems:) has not been implemented")
    }
    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError> {
        fatalError("grantConsent(_:) has not been implemented")
    }
    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError> {
        fatalError("revokeConsent(_:) has not been implemented")
    }
}
class UnimplementedExtAuthRequestStorage: ExtAuthRequestStorage {
    init() {}

    var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String) -> Void {
        fatalError("setExtAuthRequest(_:for:) has not been implemented")
    }
    func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession? {
        fatalError("getExtAuthRequest(for:) has not been implemented")
    }
    func reset() -> Void {
        fatalError("reset has not been implemented")
    }
}
struct UnimplementedFeedbackReceiver: FeedbackReceiver {
    init() {}

    func hapticFeedbackSuccess() -> Void {
        fatalError("hapticFeedbackSuccess has not been implemented")
    }
}
struct UnimplementedIDPSession: IDPSession {
    init() {}

    var isLoggedIn: AnyPublisher<Bool, IDPError> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func invalidateAccessToken() -> Void {
        fatalError("invalidateAccessToken has not been implemented")
    }
    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        fatalError("requestChallenge has not been implemented")
    }
    func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        fatalError("verify(_:) has not been implemented")
    }
    func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        fatalError("exchange(token:challengeSession:idTokenValidator:) has not been implemented")
    }
    func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        fatalError("refresh(token:) has not been implemented")
    }
    func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        fatalError("pairDevice(with:token:) has not been implemented")
    }
    func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        fatalError("unregisterDevice(_:token:) has not been implemented")
    }
    func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        fatalError("listDevices(token:) has not been implemented")
    }
    func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        fatalError("altVerify(_:) has not been implemented")
    }
    func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        fatalError("loadDirectoryKKApps has not been implemented")
    }
    func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        fatalError("startExtAuth(entry:) has not been implemented")
    }
    func extAuthVerifyAndExchange(_ url: URL, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        fatalError("extAuthVerifyAndExchange(_:idTokenValidator:) has not been implemented")
    }
    func verifyAndExchange(signedChallenge: SignedChallenge, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        fatalError("verifyAndExchange(signedChallenge:idTokenValidator:) has not been implemented")
    }
    func httpInterceptor(delegate: IDPSessionDelegate?) -> IDPInterceptor {
        fatalError("httpInterceptor(delegate:) has not been implemented")
    }
    func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession) -> AnyPublisher<IDPToken, IDPError> {
        fatalError("exchange(token:challengeSession:) has not been implemented")
    }
    func asVAUAccessTokenProvider() -> VAUAccessTokenProvider {
        fatalError("asVAUAccessTokenProvider has not been implemented")
    }
}
struct UnimplementedMatrixCodeGenerator: MatrixCodeGenerator {
    init() {}

    func generateImage(for contents: String, width: Int, height: Int) throws -> CGImage {
        fatalError("generateImage(for:width:height:) has not been implemented")
    }
    func matrixCodePublisher(for string: String, with size: CGSize, scale: CGFloat = UIScreen.main.scale, orientation: UIImage.Orientation = .up) -> AnyPublisher<UIImage, Swift.Error> {
        fatalError("matrixCodePublisher(for:with:scale:orientation:) has not been implemented")
    }
}
struct UnimplementedModelMigrating: ModelMigrating {
    init() {}

    func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError> {
        fatalError("startModelMigration(from:) has not been implemented")
    }
}
struct UnimplementedNFCHealthCardPasswordController: NFCHealthCardPasswordController {
    init() {}

    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        fatalError("resetEgkMrPinRetryCounter(can:puk:mode:) has not been implemented")
    }
    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        fatalError("changeReferenceData(can:old:new:mode:) has not been implemented")
    }
}
struct UnimplementedNFCSignatureProvider: NFCSignatureProvider {
    init() {}

    func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        fatalError("openSecureSession(can:pin:) has not been implemented")
    }
    func sign(can: String, pin: String, challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        fatalError("sign(can:pin:challenge:) has not been implemented")
    }
}
struct UnimplementedPasswordStrengthTester: PasswordStrengthTester {
    init() {}

    func passwordStrength(for password: String) -> PasswordStrength {
        fatalError("passwordStrength(for:) has not been implemented")
    }
}
struct UnimplementedPharmacyRepository: PharmacyRepository {
    init() {}

    func updateFromRemote(by telematikId: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        fatalError("updateFromRemote(by:) has not been implemented")
    }
    func loadCached(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        fatalError("loadCached(by:) has not been implemented")
    }
    func searchRemote(searchTerm: String, position: Position?, filter: [PharmacyRepositoryFilter]) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        fatalError("searchRemote(searchTerm:position:filter:) has not been implemented")
    }
    func loadLocal(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        fatalError("loadLocal(by:) has not been implemented")
    }
    func loadLocal(count: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        fatalError("loadLocal(count:) has not been implemented")
    }
    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        fatalError("save(pharmacies:) has not been implemented")
    }
    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        fatalError("delete(pharmacies:) has not been implemented")
    }
    func loadAvsCertificates(for id: String) -> AnyPublisher<[X509], PharmacyRepositoryError> {
        fatalError("loadAvsCertificates(for:) has not been implemented")
    }
    func save(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        fatalError("save(pharmacy:) has not been implemented")
    }
    func delete(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        fatalError("delete(pharmacy:) has not been implemented")
    }
}
struct UnimplementedPrescriptionRepository: PrescriptionRepository {
    init() {}

    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        fatalError("loadLocal has not been implemented")
    }
    func forcedLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        fatalError("forcedLoadRemote(for:) has not been implemented")
    }
    func silentLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        fatalError("silentLoadRemote(for:) has not been implemented")
    }
}
struct UnimplementedProfileBasedSessionProvider: ProfileBasedSessionProvider {
    init() {}

    func idpSession(for profileId: UUID) -> IDPSession {
        fatalError("idpSession(for:) has not been implemented")
    }
    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        fatalError("biometrieIdpSession(for:) has not been implemented")
    }
    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        fatalError("userDataStore(for:) has not been implemented")
    }
    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        fatalError("idTokenValidator(for:) has not been implemented")
    }
}
struct UnimplementedProfileDataStore: ProfileDataStore {
    init() {}

    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fatalError("fetchProfile(by:) has not been implemented")
    }
    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        fatalError("listAllProfiles has not been implemented")
    }
    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        fatalError("save(profiles:) has not been implemented")
    }
    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        fatalError("delete(profiles:) has not been implemented")
    }
    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        fatalError("update(profileId:mutating:) has not been implemented")
    }
    func save(profile: Profile) -> AnyPublisher<Bool, LocalStoreError> {
        fatalError("save(profile:) has not been implemented")
    }
    func delete(profile: Profile) -> AnyPublisher<Bool, LocalStoreError> {
        fatalError("delete(profile:) has not been implemented")
    }
}
struct UnimplementedProfileOnlineChecker: ProfileOnlineChecker {
    init() {}

    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        fatalError("token(for:) has not been implemented")
    }
}
struct UnimplementedProfileSecureDataWiper: ProfileSecureDataWiper {
    init() {}

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        fatalError("wipeSecureData(of:) has not been implemented")
    }
    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        fatalError("logout(profile:) has not been implemented")
    }
    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        fatalError("secureStorage(of:) has not been implemented")
    }
    func wipeSecureData(of profile: Profile) -> AnyPublisher<Void, Never> {
        fatalError("wipeSecureData(of:) has not been implemented")
    }
}
struct UnimplementedRedeemInputValidator: RedeemInputValidator {
    init() {}

    var service: RedeemServiceOption {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func isValid(version: Int) -> Validity {
        fatalError("isValid(version:) has not been implemented")
    }
    func isValid(name: String?) -> Validity {
        fatalError("isValid(name:) has not been implemented")
    }
    func isValid(street: String?) -> Validity {
        fatalError("isValid(street:) has not been implemented")
    }
    func isValid(zip: String?) -> Validity {
        fatalError("isValid(zip:) has not been implemented")
    }
    func isValid(city: String?) -> Validity {
        fatalError("isValid(city:) has not been implemented")
    }
    func isValid(hint: String?) -> Validity {
        fatalError("isValid(hint:) has not been implemented")
    }
    func isValid(text: String?) -> Validity {
        fatalError("isValid(text:) has not been implemented")
    }
    func isValid(phone: String?) -> Validity {
        fatalError("isValid(phone:) has not been implemented")
    }
    func isValid(mail: String?) -> Validity {
        fatalError("isValid(mail:) has not been implemented")
    }
    func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(optionType: RedeemOption, phone: String?, mail: String?) -> Validity {
        fatalError("ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(optionType:phone:mail:) has not been implemented")
    }
    func validate(_ shipmentInfo: ShipmentInfo?, for redeemOption: RedeemOption) -> Validity {
        fatalError("validate(_:for:) has not been implemented")
    }
    func validate(_ contactInfo: PharmacyContactDomain.State.ContactInfo) -> Validity {
        fatalError("validate(_:) has not been implemented")
    }
    func isValid(address: Address?) -> Validity {
        fatalError("isValid(address:) has not been implemented")
    }
}
struct UnimplementedRedeemService: RedeemService {
    init() {}

    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        fatalError("redeem(_:) has not been implemented")
    }
}
struct UnimplementedRegisteredDevicesService: RegisteredDevicesService {
    init() {}

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        fatalError("registeredDevices(for:) has not been implemented")
    }
    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        fatalError("deviceId(for:) has not been implemented")
    }
    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        fatalError("deleteDevice(_:of:) has not been implemented")
    }
    func cardWall(for profileId: UUID) -> AnyPublisher<CardWallCANDomain.State, Never> {
        fatalError("cardWall(for:) has not been implemented")
    }
}
struct UnimplementedResourceHandler: ResourceHandler {
    init() {}

    func canOpenURL(_ url: URL) -> Bool {
        fatalError("canOpenURL(_:) has not been implemented")
    }
    func open(_ url: URL) -> Void {
        fatalError("open(_:) has not been implemented")
    }
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) -> Void {
        fatalError("open(_:options:completionHandler:) has not been implemented")
    }
}
class UnimplementedRouting: Routing {
    init() {}

    func routeTo(_ endpoint: Endpoint) -> Void {
        fatalError("routeTo(_:) has not been implemented")
    }
}
struct UnimplementedSearchHistory: SearchHistory {
    init() {}

    func addHistoryItem(_ item: String) -> Void {
        fatalError("addHistoryItem(_:) has not been implemented")
    }
    func historyItems() -> [String] {
        fatalError("historyItems has not been implemented")
    }
}
struct UnimplementedSecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
    init() {}

    var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func createPairingSession() throws -> PairingSession {
        fatalError("createPairingSession has not been implemented")
    }
    func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: X509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        fatalError("signPairingSession(_:with:certificate:) has not been implemented")
    }
    func abort(pairingSession: PairingSession) throws -> Void {
        fatalError("abort(pairingSession:) has not been implemented")
    }
    func authenticationData(for challenge: IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        fatalError("authenticationData(for:) has not been implemented")
    }
}
struct UnimplementedShipmentInfoDataStore: ShipmentInfoDataStore {
    init() {}

    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func set(selectedShipmentInfoId: UUID) -> Void {
        fatalError("set(selectedShipmentInfoId:) has not been implemented")
    }
    func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fatalError("fetchShipmentInfo(by:) has not been implemented")
    }
    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        fatalError("listAllShipmentInfos has not been implemented")
    }
    func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        fatalError("save(shipmentInfos:) has not been implemented")
    }
    func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        fatalError("delete(shipmentInfos:) has not been implemented")
    }
    func update(identifier: UUID, mutating: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        fatalError("update(identifier:mutating:) has not been implemented")
    }
    func save(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fatalError("save(shipmentInfo:) has not been implemented")
    }
    func delete(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fatalError("delete(shipmentInfo:) has not been implemented")
    }
}
class UnimplementedTracker: Tracker {
    init() {}

    var optIn: Bool {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var optInPublisher: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func track(events: [AnalyticsEvent]) -> Void {
        fatalError("track(events:) has not been implemented")
    }
    func track(screens: [AnalyticsScreen]) -> Void {
        fatalError("track(screens:) has not been implemented")
    }
    func track(event: String) -> Void {
        fatalError("track(event:) has not been implemented")
    }
    func track(screen: String) -> Void {
        fatalError("track(screen:) has not been implemented")
    }
    func stopTracking() -> Void {
        fatalError("stopTracking has not been implemented")
    }
}
class UnimplementedUserDataStore: UserDataStore {
    init() {}

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var isOnboardingHidden: Bool {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var onboardingVersion: AnyPublisher<String?, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }
    var serverEnvironmentName: String?

    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var latestCompatibleModelVersion: ModelVersion {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var appStartCounter: Int {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var hideWelcomeDrawer: Bool {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var configuration: AnyPublisher<AppConfiguration, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var appConfiguration: AppConfiguration {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func set(hideOnboarding: Bool) -> Void {
        fatalError("set(hideOnboarding:) has not been implemented")
    }
    func set(onboardingVersion: String?) -> Void {
        fatalError("set(onboardingVersion:) has not been implemented")
    }
    func set(hideCardWallIntro: Bool) -> Void {
        fatalError("set(hideCardWallIntro:) has not been implemented")
    }
    func set(serverEnvironmentConfiguration: String?) -> Void {
        fatalError("set(serverEnvironmentConfiguration:) has not been implemented")
    }
    func set(appSecurityOption: AppSecurityOption) -> Void {
        fatalError("set(appSecurityOption:) has not been implemented")
    }
    func set(failedAppAuthentications: Int) -> Void {
        fatalError("set(failedAppAuthentications:) has not been implemented")
    }
    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) -> Void {
        fatalError("set(ignoreDeviceNotSecuredWarningPermanently:) has not been implemented")
    }
    func set(selectedProfileId: UUID) -> Void {
        fatalError("set(selectedProfileId:) has not been implemented")
    }
    func wipeAll() -> Void {
        fatalError("wipeAll has not been implemented")
    }
}
struct UnimplementedUserProfileService: UserProfileService {
    init() {}

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func set(selectedProfileId: UUID) -> Void {
        fatalError("set(selectedProfileId:) has not been implemented")
    }
    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        fatalError("userProfilesPublisher has not been implemented")
    }
    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        fatalError("activeUserProfilePublisher has not been implemented")
    }
    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        fatalError("save(profiles:) has not been implemented")
    }
    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError> {
        fatalError("update(profileId:mutating:) has not been implemented")
    }
}
struct UnimplementedUserSession: UserSession {
    init() {}

    var isAuthenticated: AnyPublisher<Bool, UserSessionError> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var erxTaskRepository: ErxTaskRepository {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var ordersRepository: ErxTaskRepository {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var profileDataStore: ProfileDataStore {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var shipmentInfoDataStore: ShipmentInfoDataStore {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var pharmacyRepository: PharmacyRepository {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var localUserStore: UserDataStore {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var secureUserStore: SecureUserDataStore {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var isDemoMode: Bool {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var nfcSessionProvider: NFCSignatureProvider {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var nfcHealthCardPasswordController: NFCHealthCardPasswordController {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var idpSession: IDPSession {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var extAuthRequestStorage: ExtAuthRequestStorage {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var pairingIdpSession: IDPSession {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var vauStorage: VAUStorage {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var trustStoreSession: TrustStoreSession {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var appSecurityManager: AppSecurityManager {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var deviceSecurityManager: DeviceSecurityManager {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var profileId: UUID {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var avsSession: AVSSession {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var avsTransactionDataStore: AVSTransactionDataStore {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var prescriptionRepository: PrescriptionRepository {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var activityIndicating: ActivityIndicating {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var idpSessionLoginHandler: LoginHandler {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var pairingIdpSessionLoginHandler: LoginHandler {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        fatalError("profile has not been implemented")
    }
    func idTokenValidator() -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        fatalError("idTokenValidator has not been implemented")
    }
}
struct UnimplementedUserSessionProviderControl: UserSessionProviderControl {
    init() {}

    func resetSession(with config: AppConfiguration) -> Void {
        fatalError("resetSession(with:) has not been implemented")
    }
    func userSession(for uuid: UUID) -> UserSession {
        fatalError("userSession(for:) has not been implemented")
    }
}
struct UnimplementedUserSessionProvider: UserSessionProvider {
    init() {}

    func userSession(for uuid: UUID) -> UserSession {
        fatalError("userSession(for:) has not been implemented")
    }
}
struct UnimplementedUsersSessionContainer: UsersSessionContainer {
    init() {}

    var userSession: UserSession {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    var isDemoMode: AnyPublisher<Bool, Never> {
        get { fatalError("") }
        set(value) { fatalError("") }
    }

    func switchToDemoMode() -> Void {
        fatalError("switchToDemoMode has not been implemented")
    }
    func switchToStandardMode() -> Void {
        fatalError("switchToStandardMode has not been implemented")
    }
}
