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

import eRpKit
import Foundation

struct InternalCommunication: Identifiable, Equatable {
    let id: String = "welcomeMessage"
    let sender: String = "E-Rezept App Team"
    var messages: [Message]

    var latestUpdate: Date? {
        messages.map(\.timestamp).max()
    }

    var hasUnreadMessages: Bool {
        messages.contains { !$0.isRead }
    }

    var latestMessage: String {
        messages.last?.text ?? ""
    }

    struct Message: Decodable, Identifiable, Equatable {
        let id: String
        let timestamp: Date
        let text: String
        let version: String
        var isRead = false

        enum CodingKeys: String, CodingKey {
            case id
            case timestamp
            case text
            case version
        }
    }
}
