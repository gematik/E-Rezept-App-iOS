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
import eRpKit
import Foundation
import IDP
import Pharmacy
import TrustStore
import VAUClient

extension UserMode: UserSession {
    private var sessionContainer: UserSession {
        switch self {
        case let .demo(container): return container
        case let .standard(container): return container
        }
    }

    var isAuthenticated: AnyPublisher<Bool, UserSessionError> {
        sessionContainer.isAuthenticated
    }

    var erxTaskRepository: ErxTaskRepository {
        sessionContainer.erxTaskRepository
    }

    var entireErxTaskRepository: eRpKit.ErxTaskRepository {
        sessionContainer.entireErxTaskRepository
    }

    var ordersRepository: OrdersRepository {
        sessionContainer.ordersRepository
    }

    var profileDataStore: ProfileDataStore {
        sessionContainer.profileDataStore
    }

    var pharmacyRepository: PharmacyRepository {
        sessionContainer.pharmacyRepository
    }

    var updateChecker: UpdateChecker {
        sessionContainer.updateChecker
    }

    var localUserStore: UserDataStore {
        sessionContainer.localUserStore
    }

    var shipmentInfoDataStore: ShipmentInfoDataStore {
        sessionContainer.shipmentInfoDataStore
    }

    var secureUserStore: SecureUserDataStore {
        sessionContainer.secureUserStore
    }

    var isDemoMode: Bool {
        if case .demo = self {
            return true
        }
        return false
    }

    var idpSession: IDPSession {
        sessionContainer.idpSession
    }

    var extAuthRequestStorage: ExtAuthRequestStorage {
        sessionContainer.extAuthRequestStorage
    }

    var pairingIdpSession: IDPSession {
        sessionContainer.pairingIdpSession
    }

    var nfcSessionProvider: NFCSignatureProvider {
        sessionContainer.nfcSessionProvider
    }

    var nfcHealthCardPasswordController: NFCHealthCardPasswordController {
        sessionContainer.nfcHealthCardPasswordController
    }

    var vauStorage: VAUStorage {
        sessionContainer.vauStorage
    }

    var trustStoreSession: TrustStoreSession {
        sessionContainer.trustStoreSession
    }

    var appSecurityManager: AppSecurityManager {
        sessionContainer.appSecurityManager
    }

    var deviceSecurityManager: DeviceSecurityManager {
        sessionContainer.deviceSecurityManager
    }

    var profileId: UUID {
        sessionContainer.profileId
    }

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        sessionContainer.profile()
    }

    var avsSession: AVSSession {
        sessionContainer.avsSession
    }

    var avsTransactionDataStore: AVSTransactionDataStore {
        sessionContainer.avsTransactionDataStore
    }

    var prescriptionRepository: PrescriptionRepository {
        sessionContainer.prescriptionRepository
    }

    var activityIndicating: ActivityIndicating {
        sessionContainer.activityIndicating
    }

    var idpSessionLoginHandler: LoginHandler {
        sessionContainer.idpSessionLoginHandler
    }

    var pairingIdpSessionLoginHandler: LoginHandler {
        sessionContainer.pairingIdpSessionLoginHandler
    }

    var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
        sessionContainer.secureEnclaveSignatureProvider
    }
}
