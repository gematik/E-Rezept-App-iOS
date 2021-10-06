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

import Combine
@testable import eRpApp

// MARK: - MockDeviceSecurityManagerSessionStorage -

final class MockDeviceSecurityManagerSessionStorage: DeviceSecurityManagerSessionStorage {
    // MARK: - ignoreDeviceNotSecuredWarningForSession

    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> {
        get { underlyingIgnoreDeviceNotSecuredWarningForSession }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningForSession = value }
    }

    private var underlyingIgnoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never>!

    // MARK: - ignoreDeviceRootedWarningForSession

    var ignoreDeviceRootedWarningForSession: Bool {
        get { underlyingIgnoreDeviceRootedWarningForSession }
        set(value) { underlyingIgnoreDeviceRootedWarningForSession = value }
    }

    private var underlyingIgnoreDeviceRootedWarningForSession: Bool!

    // MARK: - set

    var setIgnoreDeviceNotSecuredWarningForSessionCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningForSessionCalled: Bool {
        setIgnoreDeviceNotSecuredWarningForSessionCallsCount > 0
    }

    var setIgnoreDeviceNotSecuredWarningForSessionReceivedIgnoreDeviceNotSecuredWarningForSession: Bool?
    var setIgnoreDeviceNotSecuredWarningForSessionReceivedInvocations: [Bool?] = []
    var setIgnoreDeviceNotSecuredWarningForSessionClosure: ((Bool?) -> Void)?

    func set(ignoreDeviceNotSecuredWarningForSession: Bool?) {
        setIgnoreDeviceNotSecuredWarningForSessionCallsCount += 1
        setIgnoreDeviceNotSecuredWarningForSessionReceivedIgnoreDeviceNotSecuredWarningForSession =
            ignoreDeviceNotSecuredWarningForSession
        setIgnoreDeviceNotSecuredWarningForSessionReceivedInvocations.append(ignoreDeviceNotSecuredWarningForSession)
        setIgnoreDeviceNotSecuredWarningForSessionClosure?(ignoreDeviceNotSecuredWarningForSession)
    }
}
