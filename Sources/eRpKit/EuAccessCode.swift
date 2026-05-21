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

import CodedError
import Foundation

public struct EuAccessCode: Hashable, Codable, Sendable {
    public var identifier: UUID
    /// Accesscode for Eu prescription(s)
    public var accessCode: String?
    /// related country code
    public var countryCode: String?
    /// date until the accesscode is valid
    public var validUntil: Date?
    /// date when the accesscode was created
    public var createdAt: Date?
    /// ID from profile that created this access code
    public var profileId: UUID?

    public init(
        identifier: UUID = UUID(),
        accessCode: String? = nil,
        countryCode: String? = nil,
        validUntil: Date? = nil,
        createdAt: Date? = nil,
        profileId: UUID? = nil
    ) {
        self.identifier = identifier
        self.accessCode = accessCode
        self.countryCode = countryCode
        self.validUntil = validUntil
        self.createdAt = createdAt
        self.profileId = profileId
    }
}

extension EuAccessCode {
    @CodedError("209")
    public enum Error: Swift.Error {
        /// Unable to construct euAccessCode request
        @ErrorCode("01")
        case unableToConstructEuAccessCodeRequest
    }
}
