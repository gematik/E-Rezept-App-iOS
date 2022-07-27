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
@testable import eRpApp
import Foundation

class MockTracker: Tracker {
    var optInCallsCount: Int = 0
    var optInCalled: Bool {
        optInCallsCount > 0
    }

    var optInReturnValue = false

    var optIn: Bool {
        get {
            optInCallsCount += 1
            return optInReturnValue
        }
        set(value) {
            optInCallsCount += 1
            optInReturnValue = value
            underlyingOptInPublisher.send(value)
        }
    }

    var optInPublisherCallsCount: Int = 0
    var optInPublisherCalled: Bool {
        optInPublisherCallsCount > 0
    }

    private var underlyingOptInPublisher = CurrentValueSubject<Bool, Never>(false)

    var optInPublisher: AnyPublisher<Bool, Never> {
        optInPublisherCallsCount += 1
        return underlyingOptInPublisher.eraseToAnyPublisher()
    }
}
