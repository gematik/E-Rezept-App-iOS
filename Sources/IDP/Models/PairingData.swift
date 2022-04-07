//
//  Copyright (c) 2022 gematik GmbH
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
import OpenSSL

/// Structure for registering a biometric key. See `SignedPairingData` for sigend representation.
/// [REQ:gemF_Biometrie:A_21415:Pairing_Data]
public struct PairingData: Claims, Codable {
    public init(
        authCertSubjectPublicKeyInfo: String,
        notAfter: Int,
        product: String,
        serialnumber: String,
        keyIdentifier: String,
        seSubjectPublicKeyInfo: String,
        issuer: String
    ) {
        self.authCertSubjectPublicKeyInfo = authCertSubjectPublicKeyInfo
        self.notAfter = notAfter
        self.product = product
        self.serialnumber = serialnumber
        self.keyIdentifier = keyIdentifier
        self.seSubjectPublicKeyInfo = seSubjectPublicKeyInfo
        self.issuer = issuer
        pairingDataVersion = "1.0"
    }

    let authCertSubjectPublicKeyInfo: String
    let notAfter: Int
    let product: String
    let serialnumber: String
    public let keyIdentifier: String
    let seSubjectPublicKeyInfo: String
    let issuer: String
    let pairingDataVersion: String

    enum CodingKeys: String, CodingKey {
        case authCertSubjectPublicKeyInfo = "auth_cert_subject_public_key_info"
        case notAfter = "not_after"
        case product
        case serialnumber
        case keyIdentifier = "key_identifier"
        case seSubjectPublicKeyInfo = "se_subject_public_key_info"
        case issuer
        case pairingDataVersion = "pairing_data_version"
    }
}
