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

/// Trusted execution environment protocol that must be implemented according to 'gemSpec_Krypt'.
public protocol TrustStoreClient {
    /// Load the CertList for creating a trust store
    ///
    /// - Returns: A stream that emits either a CertList or a TrustStoreError.
    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError>

    /// Load the OCSP Response from remote
    ///
    /// - Returns: A stream that emits either a OCSPList or a TrustStoreError.
    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError>

    /// Load the PKI certificates from remote
    /// https://github.com/gematik/api-erp/blob/master/docs/certificate_check.adoc
    ///
    /// - Parameter rootSubjectCn: Common name (CN) of the currently installed root certificate
    /// - Note: Thrown errors are of type `TrustStoreError`
    /// - Returns: PKI certificates in form of `PKICertificates`
    func loadPKICertificatesFromServer(rootSubjectCn: String) async throws -> PKICertificates

    /// Load the VAU encryption certificate from remote
    /// https://github.com/gematik/api-erp/blob/master/docs/authentisieren.adoc
    ///
    /// - Note: Thrown errors are of type `TrustStoreError`
    /// - Returns: Data of the VAU certificate
    func loadVauCertificateFromServer() async throws -> Data

    /// Load a OCSP Response from remote
    ///  https://github.com/gematik/api-erp/blob/master/docs/certificate_check.adoc
    ///
    /// - Parameter issuerCn: Common name (CN) of the issuer of the certificate the OCSP response is requested for
    /// - Parameter serialNr: Serial number of the certificate the OCSP response is requested for in hexadecimal format
    /// - Note: Thrown errors are of type `TrustStoreError`
    /// - Returns: Data of the OCSP Response
    func loadOcspResponseFromServer(issuerCn: String, serialNr: String) async throws -> Data
}
