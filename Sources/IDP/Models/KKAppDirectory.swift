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
import SwiftUI

public struct KKAppDirectory: Codable, Equatable, Claims {
    public init(apps: [KKAppDirectory.Entry]) {
        self.apps = apps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysV2.self)
        apps = try container.decode([KKAppDirectory.Entry].self, forKey: CodingKeysV2.apps)
    }

    public let apps: [Entry]

    enum CodingKeysV2: String, CodingKey {
        case apps = "fed_idp_list"
    }

    public struct Entry: Hashable, Codable, Equatable, Identifiable {
        public init(name: String, identifier: String, pkv: Bool = false, logo: String? = nil) {
            self.name = name
            self.identifier = identifier
            self.pkv = pkv
            self.logo = logo
        }

        public var id: String {
            identifier
        }

        public let name: String
        public let identifier: String
        /// is GID flow?
        public let pkv: Bool
        public let logo: String?

        enum CodingKeysV2: String, CodingKey {
            case name = "idp_name"
            case identifier = "idp_iss"
            case pkv = "idp_pkv"
            case logo = "idp_logo"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: KKAppDirectory.Entry.CodingKeysV2.self)
            name = try container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.name)
            identifier = try container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.identifier)
            pkv = (try? container.decode(Bool.self, forKey: KKAppDirectory.Entry.CodingKeysV2.pkv)) ?? false
            logo = try? container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.logo)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: KKAppDirectory.Entry.CodingKeysV2.self)
            try container.encode(name, forKey: .name)
            try container.encode(identifier, forKey: .identifier)
            try container.encode(pkv, forKey: .pkv)
            try container.encode(logo, forKey: .logo)
        }
    }

    public func sorted() -> Self {
        KKAppDirectory(apps: apps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
}
