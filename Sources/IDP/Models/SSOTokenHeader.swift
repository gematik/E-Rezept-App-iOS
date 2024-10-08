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

/// Header of a SSOToken
public struct SSOTokenHeader: Claims, Decodable {
    public init(
        exp: Date? = nil,
        enc: String? = nil,
        alg: String? = nil,
        cty: String? = nil,
        kid: String? = nil
    ) {
        self.exp = exp
        self.enc = enc
        self.alg = alg
        self.cty = cty
        self.kid = kid
    }

    public let exp: Date?
    public let enc: String?
    public let alg: String?
    public let cty: String?
    public let kid: String?
}
