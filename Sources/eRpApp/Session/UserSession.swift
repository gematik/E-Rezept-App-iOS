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

import BfArM
import CodedError
import Combine
import Dependencies
import eRpKit
import eRpLocalStorage
import FeatureCardWall
import FeatureHelpers
import Foundation
import IDP
import Pharmacy
import TrustStore
import VAUClient

@CodedError("008")
enum UserSessionError: Error, Equatable {
    @ErrorCode("01")
    case idpError(error: IDPError)
}

/// An instance of `UserSession` holds all stores used by the app that need to be changeable per profile and demo user
/// sourcery: StreamWrapped
protocol UserSession {
    var ordersRepository: OrdersRepository { get }

    var profileDataStore: ProfileDataStore { get }

    /// Access to the store of `ShipmentInfo` objects
    var shipmentInfoDataStore: ShipmentInfoDataStore { get }

    /// The UserDefaults repository for this session
    var localUserStore: UserDataStore { get }

    /// The Secure (KeyChain) repository for this session
    var secureUserStore: SecureUserDataStore { get }

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

    var profileId: UUID { get }

    func profile() -> AnyPublisher<Profile, LocalStoreError>

    var avsTransactionDataStore: AVSTransactionDataStore { get }

    var prescriptionRepository: PrescriptionRepository { get }

    var activityIndicating: ActivityIndicating { get }

    var idpSessionLoginHandler: LoginHandler { get }

    var pairingIdpSessionLoginHandler: LoginHandler { get }
}

struct UserSessionDependency: DependencyKey {
    static var initialValue: UserSession = {
        let coreDataControllerFactory = CoreDataControllerFactory.liveValue
        // After sanitising the database there should be a profile available which is set as the selected profile
        let selectedProfileId = UserDefaults.standard.selectedProfileId ?? UUID()

        return StandardSessionContainer(
            for: selectedProfileId,
            schedulers: Schedulers(),
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
