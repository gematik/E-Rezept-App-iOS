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
import SwiftUI

@frozen
public enum AppSecurityOption: Codable, Identifiable, Equatable, Hashable {
    case unsecured
    case biometry(BiometryType)
    case password
    case biometryAndPassword(BiometryType)

    public var id: Int {
        switch self {
        case .unsecured:
            return -1
        case let .biometry(biometryType):
            switch biometryType {
            case .faceID:
                return 1
            case .touchID:
                return 2
            }
        case .password:
            return 3
        case let .biometryAndPassword(biometryType):
            switch biometryType {
            case .faceID:
                return 4
            case .touchID:
                return 5
            }
        }
    }

    public init(fromId id: Int) {
        switch id {
        case -1:
            self = .unsecured
        case 1:
            self = .biometry(.faceID)
        case 2:
            self = .biometry(.touchID)
        case 3:
            self = .password
        case 4:
            self = .biometryAndPassword(.faceID)
        case 5:
            self = .biometryAndPassword(.touchID)
        default:
            self = .unsecured
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let id = try container.decode(Int.self)
        self.init(fromId: id)
    }

    public var intValue: Int {
        get { id }
        set { self = AppSecurityOption(fromId: newValue) }
    }
}

/// Possible types of biometric sensors
@frozen
public enum BiometryType {
    /// Face ID
    case faceID
    /// Touch ID
    case touchID
}
