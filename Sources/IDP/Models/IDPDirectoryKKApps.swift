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

/// All relevant constraints needed for a successful challenge exchange
public struct IDPDirectoryKKApps {
    /// JWT containing the directory KK apps data
    public let jwt: JWT

    /// Initialize IDPDirectoryKKApps with a JWT string
    /// - Parameter jwt: JWT string to parse
    /// - Throws: If JWT parsing fails
    public init(jwt: String) throws {
        self.jwt = try JWT(from: jwt)
    }

    /// Initialize response from preformatted JWT
    ///
    /// - Parameter jwt: original challenge
    public init(jwt: JWT) {
        self.jwt = jwt
    }

    /// Verify the JWT signature with the provided certificate
    /// - Parameter certificate: X.509 certificate used for verification
    /// - Returns: Boolean indicating if verification was successful
    /// - Throws: If verification fails
    public func verify(with certificate: X509) throws -> Bool {
        try jwt.verify(with: certificate)
    }

    /// Extract claims from the JWT
    /// - Returns: KKAppDirectory claims from the JWT payload
    /// - Throws: If payload decoding fails
    public func claims() throws -> KKAppDirectory {
        try jwt.decodePayload(type: KKAppDirectory.self)
    }
}
