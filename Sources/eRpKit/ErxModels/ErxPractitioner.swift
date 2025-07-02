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

public struct ErxPractitioner: Hashable, Codable, Sendable {
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
