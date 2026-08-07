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

import Foundation
import PushNotificationCrypto
import UserNotifications

/// [REQ:gemF_PushNotification:A_27178] Implements "Push Notifications empfangen": derive key, decrypt, display
class PushNotificationServiceExtension: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        let payload = request.content.userInfo
        guard let timeMessageEncrypted = payload["time_message_encrypted"] as? String,
              let keyIdentifier = payload["key_identifier"] as? String,
              let ciphertextBase64 = payload["ciphertext"] as? String,
              let ciphertext = Data(base64Encoded: ciphertextBase64) else {
            let content = UNMutableNotificationContent()
            content.title = "Neue Nachricht"
            content.body = "Beim Laden der Nachricht ist ein Fehler aufgetreten, bitte öffnen Sie die App."
            contentHandler(content)
            return
        }

        // [REQ:gemF_PushNotification:A_27179,A_27181] Derive missing key material and decrypt the notification
        let decryptedMessageSerialized = try? PushNotificationCrypto.liveValue.decrypt(
            ciphertext, timeMessageEncrypted, keyIdentifier
        )

        if let decryptedMessageSerialized,
           let decryptedMessage = try? JSONDecoder().decode(DecryptedMessage.self, from: decryptedMessageSerialized) {
            let notificationContent = Self.unNotificationContent(from: decryptedMessage)
            contentHandler(notificationContent)
        } else {
            let content = UNMutableNotificationContent()
            content.title = "Neue Nachricht"
            content.body = "Beim Laden der Nachricht ist ein Fehler aufgetreten, bitte öffnen Sie die App."
            contentHandler(content)
            return
        }
    }

    /// to do: is this needed?
    /// Called just before the extension will be terminated by the system.
    /// Use this as an opportunity to deliver your "best attempt" at modified content,
    ///  otherwise the original push payload will be used.
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    static func unNotificationContent(from message: DecryptedMessage) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Neue Nachricht"
        let body = """
        EventId: '\(message.channelId)', TaskId: '\(message.identifier)', IdentifierType: '\(message.identifierType)'
        """
        content.body = body
        content.categoryIdentifier = "myCategory"
        return content
    }

    struct DecryptedMessage: Codable {
        let channelId: String
        let identifier: String
        let identifierType: String

        enum CodingKeys: String, CodingKey {
            case channelId = "ChannelId"
            case identifier = "Identifier"
            case identifierType = "IdentifierType"
        }
    }
}
