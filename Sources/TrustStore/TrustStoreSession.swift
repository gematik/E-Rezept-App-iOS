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

    /// Delete all stored data and reload all data from remote
    func reset()
}
