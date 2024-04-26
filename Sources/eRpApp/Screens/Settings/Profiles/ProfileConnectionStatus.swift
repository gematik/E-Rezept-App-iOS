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

import eRpStyleKit
import Foundation
import SwiftUI

enum ProfileConnectionStatus: Equatable {
    case never
    case connected
    case disconnected
}

extension ProfileConnectionStatus {
    var statusColor: Color? {
        switch self {
        case .connected:
            return Colors.secondary600
        case .disconnected:
            return Colors.red600
        case .never:
            return nil
        }
    }
}

extension ProfileConnectionStatus {
    var accessibilityValue: String {
        switch self {
        case .never:
            return "" // Has never been connected is not exposed to accessibility
        case .connected:
            return L10n.ctlTxtProfileConnectionStatusConnected.text
        case .disconnected:
            return L10n.ctlTxtProfileConnectionStatusDisconnected.text
        }
    }
}
