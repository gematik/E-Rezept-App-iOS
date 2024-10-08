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
import DataKit
import Foundation
import OpenSSL

/// All relevant constraints needed for a successful challenge exchange
public struct IDPDirectoryKKApps {
    let jwt: JWT

    /// - Parameter njwt: original challenge
    public init(jwt: String) throws {
        self.jwt = try JWT(from: jwt)
    }

    /// Initialize response from preformatted JWT
    ///
    /// - Parameter njwt: original challenge
    public init(jwt: JWT) {
        self.jwt = jwt
    }

    func verify(with certificate: X509) throws -> Bool {
        try jwt.verify(with: certificate)
    }

    func claims() throws -> KKAppDirectory {
        try jwt.decodePayload(type: KKAppDirectory.self)
    }
}
