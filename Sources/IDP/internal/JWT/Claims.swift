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

public protocol Claims: Codable {
    /// Expires
    var exp: Date? { get }
    /// Issued at
    var iat: Date? { get }
    /// not before
    var nbf: Date? { get }
}

extension Claims {
    /// Expires
    public var exp: Date? { nil }
    /// Issued at
    public var iat: Date? { nil }
    /// not before
    public var nbf: Date? { nil }
}
