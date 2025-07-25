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
import Combine
import Dependencies
import eRpKit
import eRpLocalStorage
import Foundation
import IDP
import Pharmacy
import TrustStore
import VAUClient

// sourcery: CodedError = "008"
enum UserSessionError: Error, Equatable {
    // sourcery: errorCode = "01"
    case idpError(error: IDPError)
}

/// An instance of `UserSession` holds all stores used by the app that need to be changeable per profile and demo user
/// sourcery: StreamWrapped
protocol UserSession {
    /// Last authentication state of the app. This value should not get stale as it should inform on the latest state.
    var isAuthenticated: AnyPublisher<Bool, UserSessionError> { get }

    var erxTaskRepository: ErxTaskRepository { get }

    var entireErxTaskRepository: ErxTaskRepository { get }

    var ordersRepository: OrdersRepository { get }

    var profileDataStore: ProfileDataStore { get }

    /// Access to the store of `ShipmentInfo` objects
    var shipmentInfoDataStore: ShipmentInfoDataStore { get }

    /// Access to the `PharmacyRepository`
    var pharmacyRepository: PharmacyRepository { get }

    /// Check for forced app updates
    var updateChecker: UpdateChecker { get }

    /// The UserDefaults repository for this session
    var localUserStore: UserDataStore { get }

    /// The Secure (KeyChain) repository for this session
    var secureUserStore: SecureUserDataStore { get }

    /// Indicates if the user session is a demo session
    var isDemoMode: Bool { get }

    /// The NFC Session provider
    var nfcSessionProvider: NFCSignatureProvider { get }

    /// The controller for resetting the reset counter of the password MR.PIN home on eGKs
    var nfcHealthCardPasswordController: NFCHealthCardPasswordController { get }

    /// IDP Authentication session
    var idpSession: IDPSession { get }

    var extAuthRequestStorage: ExtAuthRequestStorage { get }

    /// IDP session for pairing additional devices/keys
    var pairingIdpSession: IDPSession { get }

    /// VAU storage holding the user pseudonym information
    var vauStorage: VAUStorage { get }

    var trustStoreSession: TrustStoreSession { get }

    /// Affected manager when app (start) is secured by password usage
    var appSecurityManager: AppSecurityManager { get }

    // Manager that gathering information about device security and the user's acknowledgement thereof
    var deviceSecurityManager: DeviceSecurityManager { get }

    var profileId: UUID { get }

    func profile() -> AnyPublisher<Profile, LocalStoreError>

    var avsSession: AVSSession { get }

    var avsTransactionDataStore: AVSTransactionDataStore { get }

    var prescriptionRepository: PrescriptionRepository { get }

    var activityIndicating: ActivityIndicating { get }

    var idpSessionLoginHandler: LoginHandler { get }

    var pairingIdpSessionLoginHandler: LoginHandler { get }

    var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider { get }
}

struct UserSessionDependency: DependencyKey {
    static var initialValue: UserSession = {
        let coreDataControllerFactory = CoreDataControllerFactoryDependency.liveValue
        // After sanitising the database there should be a profile available which is set as the selected profile
        let selectedProfileId = UserDefaults.standard.selectedProfileId ?? UUID()

        @Dependency(\.erxTaskCoreDataStoreFactory) var erxTaskCoreDataStoreFactory: ErxTaskCoreDataStoreFactory
        let erxTaskCoreDataStore = erxTaskCoreDataStoreFactory.construct(selectedProfileId, coreDataControllerFactory)
        let entireCoreDataStore = erxTaskCoreDataStoreFactory.construct(nil, coreDataControllerFactory)

        return StandardSessionContainer(
            for: selectedProfileId,
            schedulers: Schedulers(),
            erxTaskCoreDataStore: erxTaskCoreDataStore,
            entireCoreDataStore: entireCoreDataStore,
            pharmacyCoreDataStore: PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            profileDataStore: ProfileDataStoreDependency.initialValue,
            shipmentInfoDataStore: ShipmentInfoCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            avsTransactionDataStore: AVSTransactionCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            appConfiguration: UserDataStoreDependency.liveValue.appConfiguration
        )
    }()

    static let liveValue: UserSession? = nil

    static var previewValue: UserSession? = DemoSessionContainer(schedulers: Schedulers())

    static let testValue: UserSession? = UnimplementedUserSession()
}

extension DependencyValues {
    var userSession: UserSession {
        get { self[UserSessionDependency.self] ?? changeableUserSessionContainer.userSession }
        set { self[UserSessionDependency.self] = newValue }
    }
}
