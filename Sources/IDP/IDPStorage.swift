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

import Combine
import Foundation
import OpenSSL

/// Interface to access an eGK Certificate that should be kept private
/// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Protocol
public protocol SecureEGKCertificateStorage {
    /// Retrieve the prior stored certificate
    var certificate: AnyPublisher<X509?, Never> { get }

    /// Set the stored certificate for this session or delete it, if `nil` is passed.
    ///
    /// - Parameter certificate: The certificate to store or `nil`if an existing certificate should be removed
    func set(certificate: X509?)

    /// Retrieve the prior stored key identifier for biometric pairing use case
    var keyIdentifier: AnyPublisher<Data?, Never> { get }

    /// Set the stored certificate for this session or delete it, if `nil` is passed.
    ///
    /// - Parameter certificate: The certificate to store or `nil`if an existing certificate should be removed
    func set(keyIdentifier: Data?)
}

/// IDP Storage protocol
public protocol IDPStorage {
    /// Retrieve and set an IDP Token
    /// [REQ:gemSpec_eRp_FdV:A_19480] usage of this token is limited to FD/IDP Access.
    var token: AnyPublisher<IDPToken?, Never> { get }
    /// Set and save the IDPToken
    func set(token: IDPToken?)

    /// Retrieve a previously saved DiscoveryDocument
    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> { get }

    /// Set and save the DiscoveryDocument
    ///
    /// - Parameter document: document to save. Pass in nil to unset
    func set(discovery document: DiscoveryDocument?)
}
