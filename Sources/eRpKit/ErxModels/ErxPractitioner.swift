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

public struct ErxPractitioner: Hashable, Codable {
    public init(title: String? = nil,
                lanr: String? = nil,
                zanr: String? = nil,
                name: String? = nil,
                qualification: String? = nil,
                email: String? = nil,
                address: String? = nil) {
        self.title = title
        self.lanr = lanr
        self.zanr = zanr
        self.name = name
        self.qualification = qualification
        self.email = email
        self.address = address
    }

    public let title: String?
    public let lanr: String?
    public let zanr: String?
    public let name: String?
    public let qualification: String?
    public let email: String?
    public let address: String?
}
