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

/// Represents stored data within the idp.
/// [REQ:gemSpec_IDP_Dienst:A_21450:Pairing_Entry]
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
