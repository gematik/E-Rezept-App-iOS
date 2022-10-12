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

import Foundation

class MainViewHintsProvider: HintsProvider {
    func currentHint(for hintState: HintState, isDemoMode: Bool) -> Hint<MainViewHintsDomain.Action>? {
        if isDemoMode {
            return hintsForDemoMode(hintState)
        } else {
            return hintsForStandardSession(hintState)
        }
    }

    private func hintsForDemoMode(_ hintState: HintState) -> Hint<MainViewHintsDomain.Action>? {
        if !hintState.hasCardWallBeenPresentedInDemoMode,
           !hintState.hiddenHintIDs.contains(A18n.mainScreen.erxHntDemoModeWelcome) {
            return MainViewHintsProvider.demoModeWelcomeHint
        }
        return nil
    }

    private func hintsForStandardSession(_ hintState: HintState) -> Hint<MainViewHintsDomain.Action>? {
        if hintState.hasUnreadMessages {
            return MainViewHintsProvider.unreadMessagesHint
        }
        if !hintState.hasScannedPrescriptionsBefore {
            return MainViewHintsProvider.openScannerHint
        }
        if !hintState.hasDemoModeBeenToggledBefore,
           !hintState.hasTasksInLocalStore,
           hintState.hiddenHintIDs.contains(A18n.mainScreen.erxHntDemoModeTour) == false {
            return MainViewHintsProvider.demoModeTourHint
        }

        return nil
    }

    static var demoModeTourHint = Hint<MainViewHintsDomain.Action>(
        id: A18n.mainScreen.erxHntDemoModeTour,
        title: L10n.hintTxtDemoModeTitle.text,
        message: L10n.hintTxtTryDemoMode.text,
        actionText: L10n.hintBtnTryDemoMode,
        action: MainViewHintsDomain.Action.routeTo(.settings),
        image: AccessibilityImage(name: Asset.Illustrations.womanBlueCircle.name),
        closeAction: MainViewHintsDomain.Action.hideHint,
        style: .neutral,
        buttonStyle: .tertiary,
        imageStyle: .topAligned
    )

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

    static var openScannerHint = Hint<MainViewHintsDomain.Action>(
        id: A18n.mainScreen.erxHntOpenScanner,
        title: L10n.hintTxtOpenScnTitle.text,
        message: L10n.hintTxtOpenScn.text,
        actionText: L10n.hintBtnOpenScn,
        action: MainViewHintsDomain.Action.routeTo(.scanner),
        image: AccessibilityImage(
            name: Asset.Illustrations.redWoman23.name,
            accessibilityName: L10n.hintPicScanner.text
        ),
        closeAction: nil,
        style: .neutral,
        buttonStyle: .quaternary,
        imageStyle: .bottomAligned
    )

    static var unreadMessagesHint = Hint<MainViewHintsDomain.Action>(
        id: A11y.mainScreen.erxHntUnreadMessages,
        title: L10n.hintTxtUnreadMessagesTitle.text,
        message: L10n.hintTxtUnreadMessages.text,
        actionText: L10n.hintBtnUnreadMessages,
        action: MainViewHintsDomain.Action.routeTo(.orders),
        image: AccessibilityImage(name: Asset.Illustrations.pharmacistf1.name),
        style: .awareness,
        imageStyle: .bottomAligned
    )
}
