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

import Foundation

public struct KKAppDirectory: Codable, Equatable, Claims {
    public init(apps: [KKAppDirectory.Entry]) {
        self.apps = apps
    }

    public let apps: [Entry]

    enum CodingKeys: String, CodingKey {
        case apps = "kk_app_list"
    }

    public struct Entry: Codable, Equatable {
        public init(name: String, identifier: String) {
            self.name = name
            self.identifier = identifier
        }

        public let name: String
        public let identifier: String

        enum CodingKeys: String, CodingKey {
            case name = "kk_app_name"
            case identifier = "kk_app_id"
        }
    }
}
