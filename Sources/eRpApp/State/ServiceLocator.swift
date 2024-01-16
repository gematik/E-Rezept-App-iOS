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

import Dependencies
import SwiftUI

/// Provides access to services.
class ServiceLocator {
    // swiftlint:disable:next strict_fileprivate
    fileprivate(set) var deviceCapabilities: DeviceCapabilities = {
        #if targetEnvironment(simulator)
        return DebugDeviceCapabilities(isNFCReady: true, isMinimumOS14: true)
        #else
        return RealDeviceCapabilities()
        #endif
    }()
}

class ServiceLocatorDebugAccess {
    internal init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    var serviceLocator: ServiceLocator

    func setDeviceCapabilities(_ deviceCapabilities: DeviceCapabilities) {
        serviceLocator.deviceCapabilities = deviceCapabilities
    }
}

// MARK: TCA Dependency

extension ServiceLocator: DependencyKey {
    static let liveValue = ServiceLocator()

    static let previewValue = ServiceLocator()
    static let testValue: ServiceLocator = unimplemented("ServiceLocator")
}

extension DependencyValues {
    var serviceLocator: ServiceLocator {
        get { self[ServiceLocator.self] }
        set { self[ServiceLocator.self] = newValue }
    }
}

extension ServiceLocatorDebugAccess: DependencyKey {
    static let liveValue = ServiceLocatorDebugAccess(serviceLocator: .liveValue)

    static let previewValue = ServiceLocatorDebugAccess(serviceLocator: .previewValue)
}

extension DependencyValues {
    var serviceLocatorDebugAccess: ServiceLocatorDebugAccess {
        get { self[ServiceLocatorDebugAccess.self] }
        set { self[ServiceLocatorDebugAccess.self] = newValue }
    }
}
