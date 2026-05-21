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

import ASN1Kit
import Foundation
import IDP
import OpenSSL

extension X509: IDPX509 {
    public func idpBrainpoolP256r1VerifyPublicKey() -> (any IDP.IDPBrainpoolP256r1VerifyPublicKey)? {
        brainpoolP256r1VerifyPublicKey()
    }
}

extension BrainpoolP256r1.Verify.PublicKey: IDPBrainpoolP256r1VerifyPublicKey {
    public func asn1Encoded() throws -> Data {
        let asn1 = try ASN1Data.constructed(
            [
                create(tag: .universal(.sequence), data: ASN1Data.constructed(
                    [
                        ObjectIdentifier.from(string: "1.2.840.10045.2.1").asn1encode(),
                        ObjectIdentifier.from(string: "1.3.36.3.3.2.8.1.1.7").asn1encode(),
                    ]
                )),

                x962Value().asn1bitStringEncode(),
            ]
        )
        return try create(tag: .universal(.sequence), data: asn1).serialize()
    }
}
