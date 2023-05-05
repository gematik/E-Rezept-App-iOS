//
//  Copyright (c) 2023 gematik GmbH
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
