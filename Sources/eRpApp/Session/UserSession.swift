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
import Foundation
import IDP
import Pharmacy
import TrustStore
import VAUClient

enum UserSessionError: Error {
    case networkError(error: Error)
}

/// `UserSession` defines a SceneDelegate environment variable that a \.userSession should conform to.
/// sourcery: StreamWrapped
protocol UserSession {
    /// Last authentication state of the app. This value should not get stale as it should inform on the latest state.
    var isAuthenticated: AnyPublisher<Bool, UserSessionError> { get }

    /// Interface to access the `AnyErxTaskRepository`
    var erxTaskRepository: ErxTaskRepositoryAccess { get }

    /// Access to the `PharmacyRepository`
    var pharmacyRepository: PharmacyRepository { get }

    /// The UserDefaults repository for this session
    var localUserStore: UserDataStore { get }

    /// Provides the state of events are relevant for hints
    var hintEventsStore: EventsStore { get }

    /// The Secure (KeyChain) repository for this session
    var secureUserStore: SecureUserDataStore { get }

    /// Indicates if the user session is a demo session
    var isDemoMode: Bool { get }

    /// The NFC Session provider
    var nfcSessionProvider: NFCSignatureProvider { get }

    /// IDP Authentication session
    var idpSession: IDPSession { get }

    /// IDP session for pairing additional devices/keys
    var biometrieIdpSession: IDPSession { get }

    /// VAU storage holding the user pseudonym information
    var vauStorage: VAUStorage { get }

    var trustStoreSession: TrustStoreSession { get }

    /// Affected manager when app (start) ist secured by password usage
    var appSecurityManager: AppSecurityManager { get }

    // Manager that gathering information about device security and the user's acknowledgement thereof
    var deviceSecurityManager: DeviceSecurityManager { get }
}
