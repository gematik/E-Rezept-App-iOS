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

/// `LabelStyle` switching the icon to be trailing instead of leading.
public struct TrailingIconLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    /// A label style that switches the icon to be trailing instead of leading.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``Label/labelStyle(_:)`` modifier.
    public static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

struct TrailingIconLabelStyle_Preview: PreviewProvider {
    static var previews: some View {
        Label("Simple Label", systemImage: SFSymbolName.ant)
            .labelStyle(.trailingIcon)
    }
}
