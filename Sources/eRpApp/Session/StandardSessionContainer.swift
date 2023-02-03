//
//  Copyright (c) 2023 gematik GmbH
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

class StandardSessionContainer: UserSession {
    private var keychainStorage: KeychainStorage
    private let schedulers: Schedulers
    private var erxTaskCoreDataStore: ErxTaskCoreDataStore
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
        pharmacyCoreDataStore: PharmacyCoreDataStore,
        profileDataStore: ProfileDataStore,
        shipmentInfoDataStore: ShipmentInfoDataStore,
        avsTransactionDataStore: AVSTransactionDataStore,
        appConfiguration: AppConfiguration
    ) {
        self.profileId = profileId
        self.schedulers = schedulers
        self.erxTaskCoreDataStore = erxTaskCoreDataStore
        self.pharmacyCoreDataStore = pharmacyCoreDataStore
        self.profileDataStore = profileDataStore
        self.shipmentInfoDataStore = shipmentInfoDataStore
        self.avsTransactionDataStore = avsTransactionDataStore
        self.appConfiguration = appConfiguration
        keychainStorage = KeychainStorage(profileId: profileId, schedulers: schedulers)
    }

    var isDemoMode: Bool {
        false
    }

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
            storage: secureUserStore, // [REQ:gemSpec_eRp_FdV:A_20184] Keychain storage encrypts session/ssl tokens
            schedulers: schedulers,
            httpClient: idpHttpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: extAuthRequestStorage
        )
    }()

    lazy var biometrieIdpSession: IDPSession = {
        let idpConfig = DefaultIDPSession.Configuration(
            clientId: appConfiguration.clientId,
            redirectURI: appConfiguration.redirectUri,
            extAuthRedirectURI: appConfiguration.extAuthRedirectUri,
            discoveryURL: appConfiguration.idp,
            scopes: ["pairing", "openid"]
        )
        return DefaultIDPSession(
            config: idpConfig,
            storage: MemoryStorage(), // [REQ:gemSpec_eRp_FdV:A_20184] No persistent storage for idp biometrics session
            schedulers: schedulers,
            httpClient: idpHttpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: DummyExtAuthRequestStorage()
        )
    }()

    lazy var extAuthRequestStorage: ExtAuthRequestStorage = {
        PersistentExtAuthRequestStorage()
    }()

    lazy var secureUserStore: SecureUserDataStore = {
        keychainStorage
    }()

    lazy var localUserStore: UserDataStore = {
        UserDefaultsStore()
    }()

    lazy var hintEventsStore: EventsStore = {
        HintEventsStore()
    }()

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
        return EGKSignatureProvider(schedulers: schedulers)
        #endif
    }()

    lazy var nfcHealthCardPasswordController: NFCHealthCardPasswordController = {
        DefaultNFCResetRetryCounterController(schedulers: schedulers)
    }()

    #if ENABLE_DEBUG_VIEW
    lazy var switchedSignatureProvider: NFCSignatureProvider = {
        SwitchSignatureProvider(defaultSignatureProvider: EGKSignatureProvider(schedulers: self.schedulers),
                                alternativeSignatureProvider: VirtualEGKSignatureProvider())
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

    lazy var pharmacyRepository: PharmacyRepository = {
        DefaultPharmacyRepository(
            disk: pharmacyCoreDataStore,
            cloud: PharmacyFHIRDataSource(
                fhirClient: FHIRClient(
                    server: appConfiguration.apoVzd,
                    httpClient: pharmacyHttpClient
                )
            )
        )
    }()

    lazy var erxTaskRepository: ErxTaskRepository = {
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
        let cloud = ErxTaskFHIRDataStore(fhirClient: fhirClient)
        return DefaultErxTaskRepository(disk: erxTaskCoreDataStore, cloud: cloud)
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
        DefaultAVSSession(httpClient: avsHttpClient)
    }()

    private lazy var defaultLoginHandler: DefaultLoginHandler = {
        DefaultLoginHandler(
            idpSession: idpSession,
            signatureProvider: DefaultSecureEnclaveSignatureProvider(storage: secureUserStore)
        )
    }()

    private lazy var prescriptionRepositoryWithActivity: DefaultPrescriptionRepository = {
        DefaultPrescriptionRepository(
            loginHandler: defaultLoginHandler,
            erxTaskRepository: self.erxTaskRepository
        )
    }()

    var prescriptionRepository: PrescriptionRepository {
        prescriptionRepositoryWithActivity
    }

    var activityIndicating: ActivityIndicating {
        prescriptionRepositoryWithActivity
    }
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
