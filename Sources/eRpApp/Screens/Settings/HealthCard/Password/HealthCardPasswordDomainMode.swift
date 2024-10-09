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

import SwiftUI

enum HealthCardPasswordDomainMode {
    case forgotPin
    case setCustomPin
    case unlockCard

    var headLineText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroForgotPin)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroCustomPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroUnlockCard)
        }
    }

    var checkmarkText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPuk)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPuk)
        }
    }

    var hintText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroHint)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroHintCustomPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroHint)
        }
    }
}
