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

import Foundation

/// X509 certificate representation used in IDP, should be able to provide the DER byte representation
///  of the certificate as well as some convenience functions for parsing relevant fields for IDP
public protocol IDPX509 {
    /// Get the DER byte representation as `Data`
    var derBytes: Data? { get }

    /// Return the certificate's issuer X500 Principal representation as DER encoded `Data`
    /// (ex: "CN=GEM.KOMP-CA10 TEST-ONLY, OU=Komponenten-CA der Telematikinfrastruktur, O=gematik GmbH NOT-VALID, C=DE")
    ///
    /// - Returns: issuer DER encoded data if successful, else nil
    func issuerX500PrincipalDEREncoded() -> Data?

    /// Return the certificates serial number as decimal `String`
    ///
    /// - Returns: serial number as decimal `String`
    func serialNumber() throws -> String

    /// Return the certificate's `notAfter` field.
    ///
    /// - Returns: the certificate's `notAfter` field as `Date`
    func notAfter() throws -> Date

    /// Convenience function for parsing the certificate's BrainpoolP256r1 PublicKey for verification, if it exists
    func idpBrainpoolP256r1VerifyPublicKey() -> IDPBrainpoolP256r1VerifyPublicKey?
}

/// Representation of a BrainpoolP256r1 public key used for signature verification in IDP
public protocol IDPBrainpoolP256r1VerifyPublicKey {
    /// ASN.1 DER encoded representation of the public key
    func asn1Encoded() throws -> Data
}
