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

import Combine
import eRpKit
import LocalAuthentication

protocol DeviceSecurityManager {
    /// If true, a dialog should be presented with a system warning
    var showSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never> { get }

    /// If true, a dialog should be presented with a system warning concerning no device passcode
    var informMissingSystemPin: AnyPublisher<Bool, Never> { get }

    func set(ignoreDeviceSystemPinWarningForSession: Bool)

    func set(ignoreDeviceSystemPinWarningPermanently: Bool)

    func informJailbreakDetected() -> Bool

    func set(ignoreRootedDeviceWarningForSession: Bool)
}

enum DeviceSecurityWarningType {
    case jailbreakDetected
    case devicePinMissing
    case none
}

@objc
protocol SecurityPolicyEvaluator: NSObjectProtocol {
    @objc
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
}

extension LAContext: SecurityPolicyEvaluator {}

struct DefaultDeviceSecurityManager: DeviceSecurityManager {
    let passwordIdentifier = "de.gematik.DefaultDeviceSecurityManager"

    private let laContext: SecurityPolicyEvaluator
    private let deviceSecurityManagerSessionStorage: DeviceSecurityManagerSessionStorage
    private var userDataStore: UserDataStore

    init(
        userDataStore: UserDataStore,
        sessionStorage: DeviceSecurityManagerSessionStorage = DefaultDeviceSecurityManagerSessionStorage(),
        laContext: SecurityPolicyEvaluator = LAContext()
    ) {
        deviceSecurityManagerSessionStorage = sessionStorage
        self.userDataStore = userDataStore
        self.laContext = laContext
    }

    var showSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never> {
        if informJailbreakDetected() {
            return Just(DeviceSecurityWarningType.jailbreakDetected).eraseToAnyPublisher()
        }
        return informMissingSystemPin
            .map { $0 ? .devicePinMissing : .none }
            .eraseToAnyPublisher()
    }

    var informMissingSystemPin: AnyPublisher<Bool, Never> {
        var error: NSError?
        let localAuthenticationEvaluationSuccess = laContext.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
        return Just(localAuthenticationEvaluationSuccess)
            .zip(
                ignoreDeviceNotSecuredWarningForSession,
                ignoreDeviceNotSecuredWarningPermanently
            ) {
                !($0 || $1 || $2)
            }
            .first()
            .eraseToAnyPublisher()
    }

    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool, Never> {
        deviceSecurityManagerSessionStorage
            .ignoreDeviceNotSecuredWarningForSession
            .map { (ignore: Bool?) -> Bool in
                if let ignore = ignore {
                    return ignore
                } else {
                    return false
                }
            }
            .eraseToAnyPublisher()
    }

    func set(ignoreDeviceSystemPinWarningForSession: Bool) {
        deviceSecurityManagerSessionStorage
            .set(ignoreDeviceNotSecuredWarningForSession: ignoreDeviceSystemPinWarningForSession)
    }

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        userDataStore.ignoreDeviceNotSecuredWarningPermanently
    }

    func set(ignoreDeviceSystemPinWarningPermanently: Bool) {
        userDataStore.set(ignoreDeviceNotSecuredWarningPermanently: ignoreDeviceSystemPinWarningPermanently)
    }

    // [REQ:gemSpec_BSI_FdV:A_20937] Jailbreak detection
    func informJailbreakDetected() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else

        guard deviceSecurityManagerSessionStorage.ignoreDeviceRootedWarningForSession == false else {
            return false
        }

        let fileManager = FileManager.default

        // swiftlint:disable:next line_length
        // Source: https://github.com/OWASP/owasp-mstg/blob/10f1f8a639dd29cbe4db166881244f3e4ea52797/Document/0x06j-Testing-Resiliency-Against-Reverse-Engineering.md#checking-file-permissions

        for file in filesToCheck {
            if fileManager.fileExists(atPath: file) {
                return true
            }
        }

        do {
            let pathToFileInRestrictedDirectory = "/private/jailbreak.txt"
            try "This is a test.".write(toFile: pathToFileInRestrictedDirectory,
                                        atomically: true,
                                        encoding: String.Encoding.utf8)
            try FileManager.default.removeItem(atPath: pathToFileInRestrictedDirectory)

            return true
        } catch {
            return false
        }
        #endif
    }

    func set(ignoreRootedDeviceWarningForSession: Bool) {
        deviceSecurityManagerSessionStorage.ignoreDeviceRootedWarningForSession = ignoreRootedDeviceWarningForSession
    }
}

struct DummyDeviceSecurityManager: DeviceSecurityManager {
    var showSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never> {
        Just(.none).eraseToAnyPublisher()
    }

    var informMissingSystemPin: AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    func set(ignoreDeviceSystemPinWarningForSession _: Bool) {
        // do nothing
    }

    func set(ignoreDeviceSystemPinWarningPermanently _: Bool) {
        // do nothing
    }

    func informJailbreakDetected() -> Bool {
        false
    }

    func set(ignoreRootedDeviceWarningForSession _: Bool) {
        // do nothing
    }
}

private let filesToCheck = [
    "/Applications/Cydia.app",
    "/Applications/FakeCarrier.app",
    "/Applications/Icy.app",
    "/Applications/IntelliScreen.app",
    "/Applications/MxTube.app",
    "/Applications/RockApp.app",
    "/Applications/SBSettings.app",
    "/Applications/WinterBoard.app",
    "/Applications/blackra1n.app",
    "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
    "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
    "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
    "/bin/bash",
    "/bin/sh",
    "/etc/apt",
    "/etc/ssh/sshd_config",
    "/private/var/lib/apt",
    "/private/var/lib/cydia",
    "/private/var/mobile/Library/SBSettings/Themes",
    "/private/var/stash",
    "/private/var/tmp/cydia.log",
    "/var/tmp/cydia.log",
    "/usr/bin/sshd",
    "/usr/libexec/sftp-server",
    "/usr/libexec/ssh-keysign",
    "/usr/sbin/sshd",
    "/var/cache/apt",
    "/var/lib/apt",
    "/var/lib/cydia",
    "/usr/sbin/frida-server",
    "/usr/bin/cycript",
    "/usr/local/bin/cycript",
    "/usr/lib/libcycript.dylib",
    "/var/log/syslog",
]
