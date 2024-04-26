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

import Dependencies
import StoreKit
import UIKit

struct ReviewRequester {
    var requestReview: () -> Void
}

extension ReviewRequester: DependencyKey {
    static var liveValue: ReviewRequester {
        .init {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }

    static var testValue: ReviewRequester {
        .init {
            unimplemented("requestReview called but unimplemented for tests")
        }
    }

    static var previewValue: ReviewRequester {
        .init {}
    }
}

extension DependencyValues {
    var reviewRequester: ReviewRequester {
        get { self[ReviewRequester.self] }
        set { self[ReviewRequester.self] = newValue }
    }
}
