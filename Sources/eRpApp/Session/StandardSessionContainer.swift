//
//  Copyright (c) 2021 gematik GmbH
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
    private lazy var keychainStorage = KeychainStorage()

    private let schedulers: Schedulers

    init(schedulers: Schedulers) {
        self.schedulers = schedulers
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
        let configurationProvider = localUserStore.configuration.map { configuration in
            ConfiguredTrustStoreSession.Configuration(
                httpClient: self.trustStoreHttpClient(configuration: configuration),
                serverURL: configuration.erp,
                trustAnchor: configuration.trustAnchor
            )
        }
        return ConfiguredTrustStoreSession(
            configurationProvider.eraseToAnyPublisher(),
            trustStoreStorage: trustStoreStorage
        )
    }()

    lazy var idpSession: IDPSession = {
        let publishedConfig = localUserStore.configuration
            .map { configuration -> ConfiguredIDPSession.Configuration in
                ConfiguredIDPSession.Configuration(
                    httpClient: self.idpHttpClient(configuration: configuration),
                    idpSessionConfiguration:
                    DefaultIDPSession.Configuration(
                        clientId: configuration.clientId,
                        redirectURL: configuration.redirectUri,
                        discoveryURL: configuration.idp,
                        scopes: ["e-rezept", "openid"]
                    )
                )
            }
        return ConfiguredIDPSession(
            publishedConfig.eraseToAnyPublisher(),
            storage: secureUserStore, // [REQ:gemSpec_eRp_FdV:A_20184] Keychain storage encrypts session/ssl tokens
            schedulers: schedulers,
            trustStoreSession: trustStoreSession
        )
    }()

    lazy var biometrieIdpSession: IDPSession = {
        let publishedConfig = localUserStore.configuration
            .map { configuration -> ConfiguredIDPSession.Configuration in
                ConfiguredIDPSession.Configuration(
                    httpClient: self.idpHttpClient(configuration: configuration),
                    idpSessionConfiguration:
                    DefaultIDPSession.Configuration(
                        clientId: configuration.clientId,
                        redirectURL: configuration.redirectUri,
                        discoveryURL: configuration.idp,
                        scopes: ["pairing", "openid"]
                    )
                )
            }
        return ConfiguredIDPSession(
            publishedConfig.eraseToAnyPublisher(),
            storage: MemoryStorage(), // [REQ:gemSpec_eRp_FdV:A_20184] No persistent storage for idp biometrics session
            schedulers: schedulers,
            trustStoreSession: trustStoreSession
        )
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
            .mapError { UserSessionError.networkError(error: $0) }
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
        ConfiguredPharmacyRepository(localUserStore.configuration)
    }()

    lazy var erxTaskRepository: ErxTaskRepositoryAccess = {
        // Local FHIR data store configuration
        guard let filePath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("ErxTask.db") else {
            preconditionFailure("Could not create a filePath for the local storage data store.")
        }

        let disk: ErxTaskCoreDataStore
        do {
            disk = try ErxTaskCoreDataStore(url: filePath, fileProtection: .completeUnlessOpen)
        } catch {
            preconditionFailure("Failed to initialize ErxTaskCoreDataStore: \(error)")
        }
        let repositoryPublisher = localUserStore.configuration
            .map { configuration -> DefaultErxTaskRepository<ErxTaskCoreDataStore, ErxTaskFHIRDataStore> in
                let vauUrl = configuration.erp
                let serverUrl = configuration.base

                let vauSession = VAUSession(
                    vauServer: vauUrl,
                    vauAccessTokenProvider: self.idpSession.asVAUAccessTokenProvider(),
                    vauStorage: self.vauStorage,
                    trustStoreSession: self.trustStoreSession
                )

                let fhirClient = FHIRClient(
                    server: serverUrl,
                    httpClient: self.erpHttpClient(configuration: configuration, vau: vauSession)
                )
                let cloud = ErxTaskFHIRDataStore(fhirClient: fhirClient)

                return DefaultErxTaskRepository(disk: disk, cloud: cloud)
            }
            .eraseToAnyPublisher()
        return AnyErxTaskRepository(repositoryPublisher)
    }()

    lazy var appSecurityManager: AppSecurityManager = {
        DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper())
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
    func trustStoreHttpClient(configuration: AppConfiguration) -> HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: configuration.erpAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    func erpHttpClient(configuration: AppConfiguration, vau session: VAUSession) -> HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: configuration.erpAdditionalHeader),
            idpSession.httpInterceptor(delegate: nil),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
            session.provideInterceptor(),
            AdditionalHeaderInterceptor(additionalHeader: configuration.erpAdditionalHeader),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    func idpHttpClient(configuration: AppConfiguration) -> HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: configuration.idpAdditionalHeader),
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
