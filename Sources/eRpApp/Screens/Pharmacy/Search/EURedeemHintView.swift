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

import eRpStyleKit
import SwiftUI

struct EURedeemHintView: View {
    let openAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        HintView(
            hint: Hint<PharmacySearchDomain.Action>(
                id: A11y.pharmacySearch.phaSearchHintEuRedeem,
                title: L10n.phaSearchHintEuRedeemTitleNoCountry,
                message: L10n.phaSearchHintEuRedeemTextNoCountry,
                actionText: L10n.phaSearchHintEuRedeemBtnRedeem,
                actionImageName: SFSymbolName.arrowForward,
                actionStyle: .rightAligned,
                emoji: "🇪🇺",
                style: .neutral,
                buttonStyle: .tertiary,
                imageStyle: .topAligned
            ),
            textAction: { openAction() },
            closeAction: { closeAction() }
        )
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding()
    }
}
