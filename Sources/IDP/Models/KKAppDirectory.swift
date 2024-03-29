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

import Foundation

public struct KKAppDirectory: Codable, Equatable, Claims {
    public init(apps: [KKAppDirectory.Entry]) {
        self.apps = apps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysV2.self)
        if let apps = try? container.decode([KKAppDirectory.Entry].self, forKey: CodingKeysV2.apps) {
            self.apps = apps
        } else {
            let container = try decoder.container(keyedBy: CodingKeysV1.self)
            apps = try container.decode([KKAppDirectory.Entry].self, forKey: CodingKeysV1.apps)
        }
    }

    public let apps: [Entry]

    enum CodingKeysV1: String, CodingKey {
        case apps = "kk_app_list"
    }

    enum CodingKeysV2: String, CodingKey {
        case apps = "fed_idp_list"
    }

    public struct Entry: Codable, Equatable {
        public init(name: String, identifier: String, gId: Bool = false, logo: String? = nil) {
            self.name = name
            self.identifier = identifier
            self.gId = gId
            self.logo = logo
        }

        public let name: String
        public let identifier: String
        /// is GID flow?
        public let gId: Bool
        public let logo: String?

        enum CodingKeysV1: String, CodingKey {
            case name = "kk_app_name"
            case identifier = "kk_app_id"
        }

        enum CodingKeysV2: String, CodingKey {
            case name = "idp_name"
            case identifier = "idp_iss"
            case gId = "idp_sek_2"
            case logo = "idp_logo"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: KKAppDirectory.Entry.CodingKeysV1.self)
            if let name = try? container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV1.name) {
                self.name = name
                identifier = try container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV1.identifier)
                gId = false
                logo = nil
            } else {
                let container = try decoder.container(keyedBy: KKAppDirectory.Entry.CodingKeysV2.self)
                name = try container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.name)
                identifier = try container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.identifier)
                gId = (try? container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.identifier)) != nil
                logo = try? container.decode(String.self, forKey: KKAppDirectory.Entry.CodingKeysV2.logo)
            }
        }
    }

    public func sorted() -> Self {
        KKAppDirectory(apps: apps.sorted { $0.name.lowercased() < $1.name.lowercased() })
    }
}
