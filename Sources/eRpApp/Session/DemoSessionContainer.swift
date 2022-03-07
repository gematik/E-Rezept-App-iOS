//
//  Copyright (c) 2022 gematik GmbH
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
import FHIRClient
import Foundation
import HTTPClient
import IDP
import Pharmacy
import TrustStore
import VAUClient

class DemoSessionContainer: UserSession {
    private lazy var memoryStorage = MemoryStorage()

    var isDemoMode: Bool {
        true
    }

    lazy var idpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    var extAuthRequestStorage: ExtAuthRequestStorage = DummyExtAuthRequestStorage()

    var profileDataStore: ProfileDataStore = DemoProfileDataStore()

    lazy var biometrieIdpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    lazy var secureUserStore: SecureUserDataStore = {
        memoryStorage
    }()

    lazy var vauStorage: VAUStorage = {
        DemoVAUStorage()
    }()

    lazy var localUserStore: UserDataStore = {
        DemoUserDefaultsStore()
    }()

    lazy var hintEventsStore: EventsStore = {
        // In demo mode we need the same store as in the default session
        HintEventsStore()
    }()

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = {
        idpSession.isLoggedIn
            .mapError { UserSessionError.networkError(error: $0) }
            .eraseToAnyPublisher()
    }()

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        DemoSignatureProvider()
    }()

    lazy var pharmacyRepository: PharmacyRepository = {
        let appConfiguration = UserDefaultsStore().appConfiguration
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.apoVzdAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        let client = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
        return DefaultPharmacyRepository(
            cloud: PharmacyFHIRDataSource(
                fhirClient: FHIRClient(
                    server: appConfiguration.apoVzd,
                    httpClient: client
                )
            )
        )
    }()

    lazy var erxTaskRepository: ErxTaskRepository = {
        DemoErxTaskRepository(
            requestDelayInSeconds: 0.9,
            schedulers: Schedulers()
        )
    }()

    lazy var trustStoreSession: TrustStoreSession = {
        DemoTrustStoreSession()
    }()

    lazy var appSecurityManager: AppSecurityManager = {
        DemoAppSecurityPasswordManager()
    }()

    private(set) lazy var deviceSecurityManager: DeviceSecurityManager = {
        DemoDeviceSecurityManager()
    }()

    let profileId = DemoProfileDataStore.anna.id

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        localUserStore.selectedProfileId
            .compactMap { $0 }
            .flatMap { userId in
                self.profileDataStore.fetchProfile(by: userId)
                    .compactMap { $0 }
            }
            .eraseToAnyPublisher()
    }

    lazy var profileSecureDataWiper: ProfileSecureDataWiper = DemoProfileSecureDataWiper()
}