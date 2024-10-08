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

/// sourcery: StringAssetInitialized
struct DefaultTextButton: View {
    var text: LocalizedStringKey
    var a11y: String
    var style: Style = .primary
    var action: () -> Void

    var body: some View {
        switch style {
        case .primary:
            PrimaryTextButton(text: text, a11y: a11y, image: nil, isEnabled: true) {
                action()
            }
        case .secondary:
            SecondaryTextButton(text: text, a11y: a11y, action: action)
        }
    }

    enum Style {
        case primary
        case secondary
    }
}
