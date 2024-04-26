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

extension Result: Codable where Success: Codable, Failure: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let success = try? container.decode(Success.self) {
            self = .success(success)
        } else if let failure = try? container.decode(Failure.self) {
            self = .failure(failure)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "The container contains neither a success nor a failure"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .success(success):
            try container.encode(success)
        case let .failure(failure):
            try container.encode(failure)
        }
    }
}
