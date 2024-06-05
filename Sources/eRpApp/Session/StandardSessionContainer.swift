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

import AVS
import Combine
import Dependencies
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import IDP
import Pharmacy
import TrustStore
import VAUClient

// swiftlint:disable:next type_body_length
class StandardSessionContainer: UserSession {
    private var keychainStorage: KeychainStorage
    private let schedulers: Schedulers
    private var erxTaskCoreDataStore: ErxTaskCoreDataStore
    private var entireCoreDataStore: ErxTaskCoreDataStore
    private var pharmacyCoreDataStore: PharmacyCoreDataStore
    let appConfiguration: AppConfiguration
    var profileDataStore: ProfileDataStore
    let shipmentInfoDataStore: ShipmentInfoDataStore
    let avsTransactionDataStore: AVSTransactionDataStore

    let profileId: UUID

    init(
        for profileId: UUID,
        schedulers: Schedulers,
        erxTaskCoreDataStore: ErxTaskCoreDataStore,
        entireCoreDataStore: ErxTaskCoreDataStore,
        pharmacyCoreDataStore: PharmacyCoreDataStore,
        profileDataStore: ProfileDataStore,
        shipmentInfoDataStore: ShipmentInfoDataStore,
        avsTransactionDataStore: AVSTransactionDataStore,
        appConfiguration: AppConfiguration
    ) {
        self.profileId = profileId
        self.schedulers = schedulers
        self.erxTaskCoreDataStore = erxTaskCoreDataStore
        self.entireCoreDataStore = entireCoreDataStore
        self.pharmacyCoreDataStore = pharmacyCoreDataStore
        self.profileDataStore = profileDataStore
        self.shipmentInfoDataStore = shipmentInfoDataStore
        self.avsTransactionDataStore = avsTransactionDataStore
        self.appConfiguration = appConfiguration
        keychainStorage = KeychainStorage(profileId: profileId, schedulers: schedulers)
    }

    var isDemoMode: Bool { false }

    lazy var trustStoreSession: TrustStoreSession = {
        guard let trustStoreStorageFilePath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("TrustStoreStorage") else {
            preconditionFailure("Could not create a filePath for the truststore storage.")
        }
        let trustStoreStorage = TrustStoreFileStorage(trustStoreStorageBaseFilePath: trustStoreStorageFilePath)
        return DefaultTrustStoreSession(
            serverURL: appConfiguration.erp,
            trustAnchor: appConfiguration.trustAnchor,
            trustStoreStorage: trustStoreStorage,
            httpClient: trustStoreHttpClient
        )
    }()

    lazy var idpSession: IDPSession = {
        let idpSessionConfig = DefaultIDPSession.Configuration(
            clientId: appConfiguration.clientId,
            redirectURI: appConfiguration.redirectUri,
            extAuthRedirectURI: appConfiguration.extAuthRedirectUri,
            discoveryURL: appConfiguration.idp,
            scopes: appConfiguration.idpDefaultScopes
        )

        return DefaultIDPSession(
            config: idpSessionConfig,
            // [REQ:gemSpec_eRp_FdV:A_21328#2] Keychain storage encrypts session tokens
            // [REQ:gemSpec_eRp_FdV:A_20184] Keychain storage encrypts session/ssl tokens
            storage: secureUserStore,
            schedulers: schedulers,
            httpClient: idpHttpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: extAuthRequestStorage
        )
    }()

    lazy var pairingIdpSession: IDPSession = {
        let idpConfig = DefaultIDPSession.Configuration(
            clientId: appConfiguration.clientId,
            redirectURI: appConfiguration.redirectUri,
            extAuthRedirectURI: appConfiguration.extAuthRedirectUri,
            discoveryURL: appConfiguration.idp,
            scopes: ["pairing", "openid"]
        )
        return DefaultIDPSession(
            config: idpConfig,
            storage: MemoryStorage(), // [REQ:gemSpec_eRp_FdV:A_20184] No persistent storage for idp pairing session
            schedulers: schedulers,
            httpClient: idpHttpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: DummyExtAuthRequestStorage()
        )
    }()

    lazy var extAuthRequestStorage: ExtAuthRequestStorage = { PersistentExtAuthRequestStorage() }()
    lazy var secureUserStore: SecureUserDataStore = { keychainStorage }()
    lazy var localUserStore: UserDataStore = { UserDefaultsStore() }()

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = {
        idpSession.isLoggedIn
            .mapError { UserSessionError.idpError(error: $0) }
            .eraseToAnyPublisher()
    }()

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        #if ENABLE_DEBUG_VIEW
        #if targetEnvironment(simulator)
        return VirtualEGKSignatureProvider()
        #else
        return switchedSignatureProvider
        #endif
        #else
        return EGKSignatureProvider(storage: secureUserStore)
        #endif
    }()

    lazy var nfcHealthCardPasswordController: NFCHealthCardPasswordController = {
        DefaultNFCResetRetryCounterController()
    }()

    #if ENABLE_DEBUG_VIEW
    lazy var switchedSignatureProvider: NFCSignatureProvider = {
        SwitchSignatureProvider(
            defaultSignatureProvider: EGKSignatureProvider(storage: secureUserStore),
            alternativeSignatureProvider: VirtualEGKSignatureProvider()
        )
    }()
    #endif

    // Local VAU storage configuration
    lazy var vauStorage: VAUStorage = {
        guard let vauStorageFilePath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("VauStorage") else {
            preconditionFailure("Could not create a filePath for the vau storage.")
        }
        return FileVAUStorage(vauStorageBaseFilePath: vauStorageFilePath)
    }()

    @Dependency(\.pharmacyServiceFactory) var pharmacyServiceFactory: PharmacyServiceFactory

    lazy var pharmacyRepository: PharmacyRepository = {
        DefaultPharmacyRepository(
            disk: pharmacyCoreDataStore,
            cloud: pharmacyServiceFactory.construct(
                FHIRClient(
                    server: appConfiguration.apoVzd,
                    httpClient: pharmacyHttpClient
                )
            )
        )
    }()

    lazy var updateChecker: UpdateChecker = {
        @Dependency(\.updateCheckerFactory) var factory

        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
            LoggingInterceptor(log: .body),
            DebugLiveLogger.LogInterceptor(),
        ]
        let client = DefaultHTTPClient(urlSessionConfiguration: .ephemeral, interceptors: interceptors)

        return factory.updateChecker(client, appConfiguration)
    }()

    @Dependency(\.erxRemoteDataStoreFactory) var erxRemoteDataStoreFactory: ErxRemoteDataStoreFactory
    @Dependency(\.medicationScheduleRepository) var medicationScheduleRepository

    private lazy var erxRemoteDataStore: ErxRemoteDataStore = {
        let vauSession = VAUSession(
            vauServer: appConfiguration.erp,
            vauAccessTokenProvider: self.idpSession.asVAUAccessTokenProvider(),
            vauStorage: self.vauStorage,
            trustStoreSession: self.trustStoreSession
        )

        let fhirClient = FHIRClient(
            server: appConfiguration.base,
            httpClient: self.erpHttpClient(vau: vauSession)
        )
        return erxRemoteDataStoreFactory.construct(fhirClient)
    }()

    // The local store only returns stored objects for the related profileId
    lazy var erxTaskRepository: ErxTaskRepository = {
        DefaultErxTaskRepository(
            disk: erxTaskCoreDataStore,
            cloud: erxRemoteDataStore,
            medicationScheduleRepository: medicationScheduleRepository,
            profile: profile()
        )
    }()

    // the locale store returns all stored objects regardless from which profile they are
    lazy var entireErxTaskRepository: ErxTaskRepository = {
        DefaultErxTaskRepository(
            disk: entireCoreDataStore,
            cloud: erxRemoteDataStore,
            medicationScheduleRepository: medicationScheduleRepository,
            profile: profile()
        )
    }()

    // Orders are displayed for all profiles, so the local store is returning objects from all profiles
    lazy var ordersRepository: OrdersRepository = {
        DefaultOrdersRepository(
            erxTaskRepository: entireErxTaskRepository,
            pharmacyRepository: pharmacyRepository
        )
    }()

    lazy var appSecurityManager: AppSecurityManager = {
        DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper())
    }()

    lazy var deviceSecurityManager: DeviceSecurityManager = {
        DefaultDeviceSecurityManager(
            userDataStore: localUserStore
        )
    }()

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        profileDataStore.fetchProfile(by: profileId)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    lazy var avsSession: AVSSession = {
        #if ENABLE_DEBUG_VIEW
        DefaultAVSSession(httpClient: avsHttpClient) { message, endpoint, httpResponse in
            var urlRequest = URLRequest(url: endpoint.url)
            endpoint.additionalHeaders.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            urlRequest.httpBody = try? JSONEncoder().encode(message)
            var response = httpResponse
            response.status = HTTPStatusCode.debug
            DebugLiveLogger.shared.log(request: urlRequest, sentAt: Date(), response: response, receivedAt: Date())
        }
        #else
        DefaultAVSSession(httpClient: avsHttpClient)
        #endif
    }()

    private lazy var prescriptionRepositoryWithActivity: DefaultPrescriptionRepository = {
        DefaultPrescriptionRepository(
            loginHandler: idpSessionLoginHandler,
            erxTaskRepository: self.erxTaskRepository
        )
    }()

    var prescriptionRepository: PrescriptionRepository {
        prescriptionRepositoryWithActivity
    }

    var activityIndicating: ActivityIndicating {
        prescriptionRepositoryWithActivity
    }

    @Dependency(\.loginHandlerServiceFactory) var loginHandlerServiceFactory: LoginHandlerServiceFactory

    lazy var idpSessionLoginHandler: LoginHandler = {
        loginHandlerServiceFactory.construct(
            idpSession,
            secureEnclaveSignatureProvider
        )
    }()

    lazy var pairingIdpSessionLoginHandler: LoginHandler = {
        loginHandlerServiceFactory.construct(
            pairingIdpSession,
            secureEnclaveSignatureProvider
        )
    }()

    lazy var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider = {
        #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
        // swiftlint:disable:next trailing_closure
        DefaultSecureEnclaveSignatureProvider(
            storage: secureUserStore,
            privateKeyContainerProvider: { try PrivateKeyContainer.createFromKeyChain(with: $0) }
        )
        #else
        DefaultSecureEnclaveSignatureProvider(
            storage: secureUserStore
        )
        #endif
    }()
}

extension IDPSession {
    func asVAUAccessTokenProvider() -> VAUAccessTokenProvider {
        IDPSessionTokenProvider(idpSession: self)
    }
}

class IDPSessionTokenProvider: VAUAccessTokenProvider {
    let idpSession: IDPSession

    init(idpSession: IDPSession) {
        self.idpSession = idpSession
    }

    var vauBearerToken: AnyPublisher<BearerToken, VAUError> {
        idpSession.autoRefreshedToken
            .compactMap { $0?.accessToken }
            .mapError { error in
                VAUError.unspecified(error: error)
            }
            .eraseToAnyPublisher()
    }
}

extension StandardSessionContainer {
    var trustStoreHttpClient: HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    func erpHttpClient(vau session: VAUSession) -> HTTPClient {
        // [REQ:gemSpec_IDP_Frontend:A_21325#2] Interceptor order defines what is encrypted via VAU
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
            idpSession.httpInterceptor(delegate: nil),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
            session.provideInterceptor(),
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    var idpHttpClient: HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.idpAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    var pharmacyHttpClient: HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.apoVzdAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    var avsHttpClient: HTTPClient {
        let interceptors: [Interceptor] = [
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }
}
