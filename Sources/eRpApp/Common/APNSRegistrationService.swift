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

import CodedError
import Dependencies
import DependenciesMacros
import Foundation
import UIKit
import UserNotifications

extension Notification.Name {
    /// Posted by the `AppDelegate` once an APNs device token was received.
    /// `userInfo["deviceToken"]` carries the token `Data`.
    static let didReceiveAPNSToken = Notification.Name("didReceiveAPNSToken")
    /// Posted by the `AppDelegate` when registering for remote notifications failed.
    /// `userInfo["error"]` carries the `Error`.
    static let didFailToRegisterForAPNS = Notification.Name("didFailToRegisterForAPNS")
}

/// Requests push-notification authorization and registers the device with APNs.
///
/// The device token is delivered asynchronously by the `AppDelegate`
/// (`didRegisterForRemoteNotificationsWithDeviceToken`), which broadcasts it via `NotificationCenter`.
/// This client bridges that callback back into structured concurrency so callers can simply `await`
/// the token. Used by both the production push-registration flow and the debug push view.
@DependencyClient
struct APNSRegistrationService {
    /// Requests notification authorization and, if granted, registers for remote notifications and
    /// resolves with the APNs device token. Throws `APNSRegistrationError` on denial or failure.
    /// [REQ:gemF_PushNotification:A_27183] Asks the user to consent to receiving push notifications
    /// [REQ:gemF_PushNotification:A_27173] Obtains the pushkey (APNs device token) from the push provider
    var requestAuthorizationAndRegister: @Sendable () async throws -> Data
    /// `true` if the user previously denied notification authorization at the OS level (the app can no
    /// longer re-prompt and must direct the user to the system settings instead).
    var isAuthorizationDenied: @Sendable () async -> Bool = { false }
}

@CodedError("701")
enum APNSRegistrationError: Error, Equatable {
    @ErrorCode("01")
    case permissionDenied
    @ErrorCode("02")
    case registrationFailed
    @ErrorCode("03")
    case missingToken
}

extension APNSRegistrationService: DependencyKey {
    static let liveValue = Self(
        requestAuthorizationAndRegister: {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else { throw APNSRegistrationError.permissionDenied }
            return try await registerAndAwaitToken()
        },
        isAuthorizationDenied: {
            await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .denied
        }
    )

    /// Registers for remote notifications and waits for the `AppDelegate` to report the resulting
    /// device token (or a registration failure) via `NotificationCenter`.
    private static func registerAndAwaitToken() async throws -> Data {
        let box = ResumeOnce()

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            let center = NotificationCenter.default
            let tokenObserver = center.addObserver(forName: .didReceiveAPNSToken, object: nil, queue: nil) { note in
                box.finish {
                    if let token = note.userInfo?["deviceToken"] as? Data {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: APNSRegistrationError.missingToken)
                    }
                }
            }
            let failObserver = center.addObserver(forName: .didFailToRegisterForAPNS, object: nil, queue: nil) { note in
                box.finish {
                    let error = (note.userInfo?["error"] as? Error) ?? APNSRegistrationError.registrationFailed
                    continuation.resume(throwing: error)
                }
            }
            box.setObservers([tokenObserver, failObserver])

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// Guards that the continuation is resumed exactly once and tears down its observers.
    private final class ResumeOnce: @unchecked Sendable {
        private let lock = NSLock()
        private var finished = false
        private var observers: [NSObjectProtocol] = []

        func setObservers(_ observers: [NSObjectProtocol]) {
            lock.lock()
            defer { lock.unlock() }
            // If the token already arrived before observers were registered, remove them right away.
            if finished {
                observers.forEach(NotificationCenter.default.removeObserver)
                return
            }
            self.observers = observers
        }

        func finish(_ resume: () -> Void) {
            lock.lock()
            defer { lock.unlock() }
            if finished {
                return
            }
            finished = true
            observers.forEach(NotificationCenter.default.removeObserver)
            resume()
        }
    }
}

extension DependencyValues {
    /// Requests push-notification authorization and registers the device with APNs.
    var apnsRegistrationService: APNSRegistrationService {
        get { self[APNSRegistrationService.self] }
        set { self[APNSRegistrationService.self] = newValue }
    }
}
