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

import Combine
import Foundation
import IDP
import OpenSSL

/// Interface to access user specific data that should be kept private
/// sourcery: StreamWrapped
/// [REQ:BSI-eRp-ePA:O.Auth_13#2|11] The protocol for storing secured data
public protocol SecureUserDataStore: IDPStorage, SecureEGKCertificateStorage {
    /// Keep track of the latest CAN kept by the DataStore
    var can: AnyPublisher<String?, Never> { get }
    /// Set the CAN
    ///
    /// - Parameter can: the CAN to set and save
    func set(can: String?)

    /// Wipe the whole storage and delete all user information
    func wipe()
}
