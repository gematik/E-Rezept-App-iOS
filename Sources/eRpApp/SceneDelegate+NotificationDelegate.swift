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

import Dependencies
import Foundation
import UserNotifications

extension SceneDelegate {
    class LocalNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        init(router: Routing) {
            self.router = router
        }

        // Dependencies framework is not setup for routing here!
        var router: Routing

        @MainActor
        func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            // swiftlint:disable force_cast force_unwrapping
            await router.routeTo(.mainScreen(.medicationReminder(
                (response.notification.request.content.userInfo["entries"] as! [String])
                    .map { UUID(uuidString: $0)! }
            )))
            // swiftlint:enable force_cast force_unwrapping
        }

        func userNotificationCenter(
            _: UNUserNotificationCenter,
            openSettingsFor _: UNNotification?
        ) {
            print("OPEN SETTINGS")
        }

        func userNotificationCenter(
            _: UNUserNotificationCenter,
            willPresent _: UNNotification,
            withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler(.banner)
        }
    }
}
