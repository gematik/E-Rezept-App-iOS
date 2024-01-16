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

#if canImport(UIKit)
import UIKit

extension DefaultSecureEnclaveSignatureProvider {
    /// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
    func deviceInformation() -> RegistrationData.DeviceInformation {
        let deviceType = RegistrationData.DeviceInformation.DeviceType(
            product: UIDevice.current.machineName(),
            model: UIDevice.current.model,
            os: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion,
            manufacturer: "Apple"
        )

        return RegistrationData.DeviceInformation(
            name: UIDevice.current.name,
            deviceType: deviceType
        )
    }
}

extension UIDevice {
    func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}

#elseif canImport(AppKit)
import AppKit

extension DefaultSecureEnclaveSignatureProvider {
    /// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
    func deviceInformation() -> RegistrationData.DeviceInformation {
        let deviceType = RegistrationData.DeviceInformation.DeviceType(
            product: ProcessInfo.processInfo.hostName,
            model: "generic mac",
            os: "macOS",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            manufacturer: "Apple"
        )

        return RegistrationData.DeviceInformation(
            name: ProcessInfo.processInfo.hostName,
            deviceType: deviceType
        )
    }
}

#endif
