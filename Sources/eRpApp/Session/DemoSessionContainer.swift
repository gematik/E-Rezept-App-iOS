//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import AVS
import BfArM
import Combine
import eRpKit
import eRpLocalStorage
import FHIRClient
import Foundation
import HTTPClient
import HTTPClientLive
import IDP
import Pharmacy
import TrustStore
import VAUClient

class DemoSessionContainer: UserSession {
    internal init(schedulers: Schedulers,
                  extAuthRequestStorage: ExtAuthRequestStorage = DummyExtAuthRequestStorage(),
                  profileDataStore: ProfileDataStore = DemoProfileDataStore()) {
        self.schedulers = schedulers
        self.extAuthRequestStorage = extAuthRequestStorage
        self.profileDataStore = profileDataStore
    }

    private lazy var memoryStorage = MemoryStorage()

    var isDemoMode: Bool {
        true
    }

    private let schedulers: Schedulers

    lazy var idpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    var extAuthRequestStorage: ExtAuthRequestStorage

    var profileDataStore: ProfileDataStore

    lazy var pairingIdpSession: IDPSession = {
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

    lazy var shipmentInfoDataStore: ShipmentInfoDataStore = {
        DemoShipmentInfoStore()
    }()

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = {
        idpSession.isLoggedIn
            .mapError { UserSessionError.idpError(error: $0) }
            .eraseToAnyPublisher()
    }()

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        DemoSignatureProvider()
    }()

    lazy var nfcHealthCardPasswordController: NFCHealthCardPasswordController = {
        DefaultNFCResetRetryCounterController()
    }()

    lazy var bfArMService: BfArMService = {
        let appConfiguration = UserDefaultsStore().appConfiguration

        return DemoBfArMService()
    }()

    lazy var pharmacyRepository: PharmacyRepository = {
        let appConfiguration = UserDefaultsStore().appConfiguration
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: appConfiguration.fhirVzdAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        let client = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
        return DemoPharmacyRepository(
            cloud: PharmacyFHIRDataSource(
                fhirClient: FHIRClient(
                    server: appConfiguration.fhirVzd,
                    httpClient: client
                )
            ),
            requestDelayInSeconds: 0.9,
            schedulers: Schedulers()
        )
    }()

    var updateChecker = UpdateChecker {
        false
    }

    private lazy var demoErxTaskRepository: ErxTaskRepository = {
        DemoErxTaskRepository(
            requestDelayInSeconds: 0.9,
            schedulers: schedulers,
            secureUserStore: secureUserStore
        )
    }()

    lazy var erxTaskRepository: ErxTaskRepository = {
        demoErxTaskRepository
    }()

    lazy var entireErxTaskRepository: eRpKit.ErxTaskRepository = {
        demoErxTaskRepository
    }()

    lazy var ordersRepository: OrdersRepository = {
        DemoOrdersRepository()
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

    lazy var avsSession: AVSSession = {
        DemoAVSSession()
    }()

    lazy var avsTransactionDataStore: AVSTransactionDataStore = {
        DemoAVSTransactionDataStore()
    }()

    private lazy var demoPrescriptionRepositoryWithActivity: DefaultPrescriptionRepository = {
        DefaultPrescriptionRepository(
            loginHandler: idpSessionLoginHandler,
            erxTaskRepository: self.erxTaskRepository
        )
    }()

    lazy var prescriptionRepository: PrescriptionRepository = {
        demoPrescriptionRepositoryWithActivity
    }()

    lazy var activityIndicating: ActivityIndicating = {
        demoPrescriptionRepositoryWithActivity
    }()

    lazy var idpSessionLoginHandler: LoginHandler = {
        DefaultLoginHandler(
            idpSession: idpSession,
            signatureProvider: secureEnclaveSignatureProvider
        )
    }()

    lazy var pairingIdpSessionLoginHandler: LoginHandler = {
        DefaultLoginHandler(
            idpSession: pairingIdpSession,
            signatureProvider: secureEnclaveSignatureProvider
        )
    }()

    lazy var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider = {
        DummySecureEnclaveSignatureProvider()
    }()
}

class DummySessionContainer: DemoSessionContainer {
    init() {
        super.init(schedulers: Schedulers())
    }
}

private struct DemoLoginHandler: LoginHandler {
    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        Just(LoginResult.success(true)).eraseToAnyPublisher()
    }

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        Just(LoginResult.success(true)).eraseToAnyPublisher()
    }
}
