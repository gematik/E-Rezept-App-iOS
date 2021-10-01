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

    var erxTaskRepository: ErxTaskRepositoryAccess {
        sessionContainer.erxTaskRepository
    }

    var pharmacyRepository: PharmacyRepository {
        sessionContainer.pharmacyRepository
    }

    var localUserStore: UserDataStore {
        sessionContainer.localUserStore
    }

    var secureUserStore: SecureUserDataStore {
        sessionContainer.secureUserStore
    }

    var hintEventsStore: EventsStore {
        sessionContainer.hintEventsStore
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

    var biometrieIdpSession: IDPSession {
        sessionContainer.biometrieIdpSession
    }

    var nfcSessionProvider: NFCSignatureProvider {
        sessionContainer.nfcSessionProvider
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
}
