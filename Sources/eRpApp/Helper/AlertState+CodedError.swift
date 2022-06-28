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

import ComposableArchitecture

extension AlertState {
    init(for error: CodedError, title: StringAsset? = nil) {
        if #available(iOS 15, *) {
            self.init(
                title: title.map(TextState.init) ?? TextState(L10n.errTitleGeneric),
                message: TextState(error.localizedDescriptionWithErrorList),
                buttons: [
                    .cancel(TextState(L10n.alertBtnOk)),
                ]
            )
        } else {
            self.init(
                title: title.map(TextState.init) ?? TextState(L10n.errTitleGeneric),
                message: TextState(error.localizedDescriptionWithErrorList),
                dismissButton: .cancel(TextState(L10n.alertBtnOk))
            )
        }
    }

    init(for error: CodedError, title: StringAsset? = nil, primaryButton: Button) {
        if #available(iOS 15, *) {
            self.init(
                title: title.map(TextState.init) ?? TextState(L10n.errTitleGeneric),
                message: TextState(error.localizedDescriptionWithErrorList),
                buttons: [
                    .cancel(TextState(L10n.alertBtnOk)),
                    primaryButton,
                ]
            )
        } else {
            self.init(
                title: title.map(TextState.init) ?? TextState(L10n.errTitleGeneric),
                message: TextState(error.localizedDescriptionWithErrorList),
                primaryButton: primaryButton,
                secondaryButton: .cancel(TextState(L10n.errBtnCancel))
            )
        }
    }
}
