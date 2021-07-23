//
//  Copyright (c) 2021 gematik GmbH
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
        if !hintState.hasSecurityOptionBeenSelected {
            return MainViewHintsProvider.appSecurityHint
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
    	title: NSLocalizedString("hint_txt_try_demo_mode_title", comment: ""),
    	message: NSLocalizedString("hint_txt_try_demo_mode", comment: ""),
    	actionText: L10n.hintBtnTryDemoMode,
    	action: MainViewHintsDomain.Action.routeTo(.settings),
    	imageName: Asset.Illustrations.womanBlueCircle.name,
    	closeAction: MainViewHintsDomain.Action.hideHint,
    	style: .neutral,
    	buttonStyle: .tertiary,
    	imageStyle: .topAligned
    )

    static var demoModeWelcomeHint = Hint<MainViewHintsDomain.Action>(
    	id: A18n.mainScreen.erxHntDemoModeWelcome,
    	title: NSLocalizedString("hint_txt_demo_mode_title", comment: ""),
    	message: NSLocalizedString("hint_txt_demo_mode", comment: ""),
    	actionText: nil,
    	action: nil,
    	imageName: Asset.Illustrations.celebrationYellowCircle.name,
    	closeAction: MainViewHintsDomain.Action.hideHint,
    	style: .neutral,
    	buttonStyle: .tertiary,
    	imageStyle: .topAligned
    )

    static var appSecurityHint = Hint<MainViewHintsDomain.Action>(
    	id: A18n.mainScreen.erxHntAppSecurity,
    	title: NSLocalizedString("hint_txt_app_security_title", comment: ""),
    	message: NSLocalizedString("hint_txt_app_security", comment: ""),
    	actionText: L10n.hintBtnAppSecurity,
    	action: MainViewHintsDomain.Action.routeTo(.settings),
    	imageName: Asset.Illustrations.arztRedCircle.name,
    	closeAction: nil,
    	style: .neutral,
    	buttonStyle: .tertiary,
    	imageStyle: .topAligned
    )

    static var openScannerHint = Hint<MainViewHintsDomain.Action>(
    	id: A18n.mainScreen.erxHntOpenScanner,
    	title: NSLocalizedString("hint_txt_open_scn_title", comment: ""),
    	message: NSLocalizedString("hint_txt_open_scn", comment: ""),
    	actionText: L10n.hintBtnOpenScn,
    	action: MainViewHintsDomain.Action.routeTo(.scanner),
    	imageName: Asset.Illustrations.redWoman23.name,
    	closeAction: nil,
    	style: .neutral,
    	buttonStyle: .quaternary,
    	imageStyle: .bottomAligned
    )

    static var unreadMessagesHint = Hint<MainViewHintsDomain.Action>(
    	id: A11y.mainScreen.erxHntUnreadMessages,
    	title: NSLocalizedString("hint_txt_unread_messages_title", comment: ""),
    	message: NSLocalizedString("hint_txt_unread_messages", comment: ""),
    	actionText: L10n.hintBtnUnreadMessages,
    	action: MainViewHintsDomain.Action.routeTo(.messages),
    	imageName: Asset.Illustrations.pharmacistf1.name,
    	style: .awareness,
    	imageStyle: .bottomAligned
    )
}
