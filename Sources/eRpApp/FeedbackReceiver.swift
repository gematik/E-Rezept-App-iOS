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
import UIKit

protocol FeedbackReceiver {
    func hapticFeedbackSuccess()
}

struct DefaultFeedbackReceiver: FeedbackReceiver {
    func hapticFeedbackSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

struct DummyFeedbackReceiver: FeedbackReceiver {
    func hapticFeedbackSuccess() {
        // do nothing
    }
}

// MARK: TCA Dependency

struct FeedbackReceiverKey: DependencyKey {
    static let liveValue: FeedbackReceiver = DefaultFeedbackReceiver()

    static let previewValue: FeedbackReceiver = DummyFeedbackReceiver()

    static let testValue: FeedbackReceiver = UnimplementedFeedbackReceiver()
}

extension DependencyValues {
    var feedbackReceiver: FeedbackReceiver {
        get { self[FeedbackReceiverKey.self] }
        set { self[FeedbackReceiverKey.self] = newValue }
    }
}
