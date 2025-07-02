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
