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

/// Data Model that holds all relevant informations from a `ModelsR4.Bundle` signature
///
/// A Signature holds an electronic representation of a signature and its supporting context in a FHIR accessible form.
/// The signature may either be a cryptographic type (XML DigSig or a JWS),
/// which is able to provide non-repudiation proof,
/// or it may be a graphical image that represents a signature or a signature process.
public struct ErxSignature: Hashable, Codable {
    /// When the signature was created
    public let when: String
    /// The technical format of the signature (for example: application/pkcs7-mime)
    public let sigFormat: String?
    /// The actual signature content (XML DigSig. JWS, picture, etc.)
    public let data: String?

    /// Default initializer to instantiate an ErxSignature.
    public init(
        when: String,
        sigFormat: String? = nil,
        data: String? = nil
    ) {
        self.when = when
        self.sigFormat = sigFormat
        self.data = data
    }
}
