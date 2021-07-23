//
//  Copyright (c) 2021 gematik GmbH
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

import CoreNFC
import Foundation
import SwiftUI

/// Provides access to device capabilities.
///
/// Use via `ServiceLocator` to enable proper testing via DebugView screen.
protocol DeviceCapabilities {
    var isNFCReady: Bool { get }
    var isMinimumOS14: Bool { get }
}

class RealDeviceCapabilities: DeviceCapabilities {
    lazy var isNFCReady: Bool = {
        NFCNDEFReaderSession.readingAvailable
    }()

    lazy var isMinimumOS14: Bool = {
        ProcessInfo().operatingSystemVersion.majorVersion >= 14
    }()
}

struct DebugDeviceCapabilities: DeviceCapabilities {
    var isNFCReady: Bool
    var isMinimumOS14: Bool
}

extension DebugDeviceCapabilities: Equatable {
    static func ==(lhs: DebugDeviceCapabilities, rhs: DebugDeviceCapabilities) -> Bool {
        lhs.isMinimumOS14 == rhs.isMinimumOS14 && lhs.isNFCReady == rhs.isNFCReady
    }
}
