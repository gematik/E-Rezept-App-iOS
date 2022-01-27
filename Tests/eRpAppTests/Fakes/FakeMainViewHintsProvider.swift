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

class FakeMainViewHintsProvider: MainViewHintsProvider {
    var currentHintCallsCount = 0
    var currentHintCalled: Bool {
        currentHintCallsCount > 0
    }

    var currentHintParameter: (hintState: HintState, isDemoMode: Bool)?
    var currentHintReturn: Hint<MainViewHintsDomain.Action>? =
        MainViewHintsDomain.Dummies.hintBottomAligned(with: .neutral)
    override func currentHint(for hintState: HintState, isDemoMode: Bool) -> Hint<MainViewHintsDomain.Action>? {
        currentHintCallsCount += 1
        currentHintParameter = (hintState, isDemoMode)
        if !hintState.hiddenHintIDs.isEmpty {
            return nil
        }
        return currentHintReturn
    }
}
