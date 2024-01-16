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
import OpenSSL

/// Represents stored data within the idp.
/// [REQ:gemF_Biometrie:A_21450:Pairing_Entry]
public struct PairingEntry: Equatable, Codable {
    public init(name: String, signedPairingData: String, creationTime: Date) {
        self.name = name
        self.signedPairingData = signedPairingData
        self.creationTime = creationTime
        pairingEntryVersion = "1.0"
    }

    public let name: String
    public let signedPairingData: String
    public let creationTime: Date
    public let pairingEntryVersion: String

    enum CodingKeys: String, CodingKey {
        case name
        case signedPairingData = "signed_pairing_data"
        case creationTime = "creation_time"
        case pairingEntryVersion = "pairing_entry_version"
    }
}

public struct PairingEntries: Equatable, Codable {
    public let pairingEntries: [PairingEntry]

    public init(pairingEntries: [PairingEntry]) {
        self.pairingEntries = pairingEntries
    }

    enum CodingKeys: String, CodingKey {
        case pairingEntries = "pairing_entries"
    }
}
