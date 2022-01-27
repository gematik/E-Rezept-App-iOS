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

/// IDPToken
public struct IDPToken: Codable {
    /// Access token
    public let accessToken: String
    /// Expiry date
    public let expires: Date
    /// ID token
    public let idToken: String
    /// SSO token
    public let ssoToken: String?
    /// Token type
    public let tokenType: String

    /// Initialize an IDPToken
    /// - Parameters:
    ///   - accessToken: Access token
    ///   - expires: Expiration date
    ///   - idToken: ID token
    ///   - ssoToken: SSO token. Default: nil
    ///   - tokenType: Default: Bearer
    public init(
        accessToken: String,
        expires: Date,
        idToken: String,
        ssoToken: String? = nil,
        tokenType: String = "Bearer"
    ) {
        self.accessToken = accessToken
        self.expires = expires
        self.idToken = idToken
        self.ssoToken = ssoToken
        self.tokenType = tokenType
    }
}

extension IDPToken: Equatable {}
