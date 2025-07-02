//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import CoreNFC
import Foundation
import SwiftUI

/// Provides access to device capabilities.
///
/// Use via `ServiceLocator` to enable proper testing via DebugView screen.
protocol DeviceCapabilities: AnyObject {
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

class DebugDeviceCapabilities: DeviceCapabilities {
    var isNFCReady: Bool
    var isMinimumOS14: Bool

    internal init(isNFCReady: Bool, isMinimumOS14: Bool) {
        self.isNFCReady = isNFCReady
        self.isMinimumOS14 = isMinimumOS14
    }
}

extension DebugDeviceCapabilities: Equatable {
    static func ==(lhs: DebugDeviceCapabilities, rhs: DebugDeviceCapabilities) -> Bool {
        lhs.isMinimumOS14 == rhs.isMinimumOS14 && lhs.isNFCReady == rhs.isNFCReady
    }
}
