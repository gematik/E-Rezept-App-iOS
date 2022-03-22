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

import eRpKit
import Foundation
import SwiftUI

enum ProfileColor: Int, Equatable, CaseIterable {
    case grey
    case yellow
    case red
    case green
    case blue

    var background: SwiftUI.Color {
        switch self {
        case .grey:
            return SwiftUI.Color(.systemGray4)
        case .yellow:
            return Colors.yellow200
        case .red:
            return Colors.red200
        case .green:
            return Colors.secondary200
        case .blue:
            return Colors.primary200
        }
    }

    var border: SwiftUI.Color {
        switch self {
        case .grey:
            return SwiftUI.Color(.systemGray6)
        case .yellow:
            return Colors.yellow400
        case .red:
            return Colors.red400
        case .green:
            return Colors.secondary400
        case .blue:
            return Colors.primary400
        }
    }
}

extension ProfileColor {
    var erxColor: Profile.Color {
        switch self {
        case .grey:
            return .grey
        case .yellow:
            return .yellow
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}
