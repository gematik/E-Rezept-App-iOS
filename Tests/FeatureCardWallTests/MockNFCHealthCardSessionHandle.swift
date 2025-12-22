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
// swiftlint:disable file_length

import HealthCardAccess
import NFCCardReaderProvider

final class MockNFCHealthCardSessionHandle: NFCHealthCardSessionHandle {
    // MARK: - card

    var card: HealthCardType {
        get { underlyingCard }
        set(value) { underlyingCard = value }
    }

    var underlyingCard: HealthCardType!

    // MARK: - updateAlert

    var updateAlertMessageCallsCount = 0
    var updateAlertMessageCalled: Bool {
        updateAlertMessageCallsCount > 0
    }

    var updateAlertMessageReceivedMessage: String?
    var updateAlertMessageReceivedInvocations: [String] = []
    var updateAlertMessageClosure: ((String) -> Void)?

    func updateAlert(message: String) {
        updateAlertMessageCallsCount += 1
        updateAlertMessageReceivedMessage = message
        updateAlertMessageReceivedInvocations.append(message)
        updateAlertMessageClosure?(message)
    }

    // MARK: - invalidateSession

    var invalidateSessionWithCallsCount = 0
    var invalidateSessionWithCalled: Bool {
        invalidateSessionWithCallsCount > 0
    }

    var invalidateSessionWithReceivedError: String?
    var invalidateSessionWithReceivedInvocations: [String?] = []
    var invalidateSessionWithClosure: ((String?) -> Void)?

    func invalidateSession(with error: String?) {
        invalidateSessionWithCallsCount += 1
        invalidateSessionWithReceivedError = error
        invalidateSessionWithReceivedInvocations.append(error)
        invalidateSessionWithClosure?(error)
    }
}
