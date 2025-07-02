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

import SwiftUI

// Source: https://stackoverflow.com/questions/65778208/accessibility-of-image-in-button-in-toolbaritem
extension View {
    /// Embeds the content in a view which removes some
    /// default styling in toolbars, so accessibility works.
    /// - Returns: Embedded content.
    @ViewBuilder func embedToolbarContent() -> some View {
        if #available(iOS 15, *) {
            self
        } else {
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)

                self
            }
        }
    }
}
