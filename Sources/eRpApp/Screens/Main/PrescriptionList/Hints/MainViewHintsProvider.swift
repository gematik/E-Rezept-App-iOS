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

import Foundation

class MainViewHintsProvider: HintsProvider {
    func currentHint(for hintState: HintState, isDemoMode: Bool) -> Hint<MainViewHintsDomain.Action>? {
        if isDemoMode {
            return hintsForDemoMode(hintState)
        } else {
            return nil
        }
    }

    private func hintsForDemoMode(_ hintState: HintState) -> Hint<MainViewHintsDomain.Action>? {
        if !hintState.hasCardWallBeenPresentedInDemoMode,
           !hintState.hiddenHintIDs.contains(A18n.mainScreen.erxHntDemoModeWelcome) {
            return MainViewHintsProvider.demoModeWelcomeHint
        }
        return nil
    }

    static var demoModeWelcomeHint = Hint<MainViewHintsDomain.Action>(
        id: A18n.mainScreen.erxHntDemoModeWelcome,
        title: L10n.hintTxtDemoModeTitle.text,
        message: L10n.hintTxtTryDemoMode.text,
        actionText: nil,
        action: nil,
        image: AccessibilityImage(
            name: Asset.Illustrations.celebrationYellowCircle.name
        ),
        closeAction: MainViewHintsDomain.Action.hideHint,
        style: .neutral,
        buttonStyle: .tertiary,
        imageStyle: .topAligned
    )
}
