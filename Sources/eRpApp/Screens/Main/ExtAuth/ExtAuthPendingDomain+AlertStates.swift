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

import ComposableArchitecture
import Foundation

extension ExtAuthPendingDomain {
    static func alertState(title: String, message _: String, url: URL) -> ErpAlertState<Destination.Alert> {
        ErpAlertState(
            title: { TextState(L10n.mainTxtPendingextauthFailed(title)) },
            actions: {
                ButtonState(action: .send(.externalLogin(url))) {
                    TextState(L10n.mainTxtPendingextauthRetry)
                }
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.mainTxtPendingextauthCancel)
                }
            },
            message: { TextState(L10n.cdwTxtRcAlertMessageSaveProfile) }
        )
    }

    static func alertState(title: String, message: String) -> ErpAlertState<Destination.Alert> {
        ErpAlertState(
            title: { TextState(title) },
            actions: {
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.mainTxtPendingextauthCancel)
                }
            },
            message: { TextState(message) }
        )
    }

    static var saveProfileAlert: ErpAlertState<Destination.Alert> = {
        ErpAlertState(
            title: { TextState(L10n.cdwTxtExtauthAlertTitleSaveProfile) },
            actions: {
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.cdwBtnExtauthAlertSaveProfile)
                }
            },
            message: { TextState(L10n.cdwTxtExtauthAlertMessageSaveProfile) }
        )
    }()
}
