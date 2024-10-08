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

import Combine

protocol DeviceSecurityManagerSessionStorage: AnyObject {
    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> { get }

    func set(ignoreDeviceNotSecuredWarningForSession: Bool?)

    var ignoreDeviceRootedWarningForSession: Bool { get set }
}

// swiftlint:disable:next type_name
class DefaultDeviceSecurityManagerSessionStorage: DeviceSecurityManagerSessionStorage {
    // swiftlint:disable:next identifier_name
    @Published private var ignoreDeviceNotSecuredWarningForSessionState: Bool?
    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> {
        $ignoreDeviceNotSecuredWarningForSessionState.eraseToAnyPublisher()
    }

    func set(ignoreDeviceNotSecuredWarningForSession: Bool?) {
        ignoreDeviceNotSecuredWarningForSessionState = ignoreDeviceNotSecuredWarningForSession
    }

    var ignoreDeviceRootedWarningForSession = false
}
