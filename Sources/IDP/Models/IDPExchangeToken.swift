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

/// IDP Exchange Token that will be received upon successful verification of a SignedChallenge
public struct IDPExchangeToken {
    /// Exchange code
    public let code: String
    /// SSO token
    public let sso: String?
    /// IDPChallengeSession state
    public let state: String

    /// Initialize
    ///
    /// - Parameters:
    ///   - code: Exchange code
    ///   - sso: SSO token
    ///   - state: IDPChallengeSession state
    public init(code: String, sso: String? = nil, state: String) {
        self.code = code
        self.sso = sso
        self.state = state
    }
}

extension IDPExchangeToken: Equatable {}
