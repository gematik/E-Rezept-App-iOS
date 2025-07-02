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
import OpenSSL

/// TrustStoreSession acts as an interactor/mediator for the TrustStoreClient and TrustStoreStorage
///
/// [REQ:gemSpec_Krypt:A_21218,A_21222]
public protocol TrustStoreSession {
    /// Request and validate the VAU certificate
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19739]
    ///
    /// - Returns: A publisher that emits a validated VAU certificate or an error
    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError>

    /// Try to validate a given certificate against the underlying truststore.
    /// An OCSP response will also be requested and checked against
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19739]
    ///
    /// - Parameter certificate: the certificate to be validated
    /// - Returns: A publisher that emits a Boolean stating whether or not the certificate could be validated.
    func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError>

    /// Request and validate the VAU certificate
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19739]
    ///
    /// - Note: Thrown errors are of type `TrustStoreError`
    /// - Returns: A validated VAU certificate
    func vauCertificate() async throws -> X509

    /// Delete all stored data
    func reset()
}
