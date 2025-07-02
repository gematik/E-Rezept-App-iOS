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
/// `ButtonStyle` for navigation buttons with a chevron. This style must be applied manually to `Button`s that should be
/// presented as navigational buttons. This style is not meant to be used with `NavigationLink`and will probably not
/// work with these.
///
/// - Note: For Buttons within SectionContainer use DetailNavigationButtonStyle
public struct NavigationButtonStyle: ButtonStyle {
    let minChevronSpacing: CGFloat

    init(minChevronSpacing: CGFloat? = nil) {
        self.minChevronSpacing = minChevronSpacing ?? 16
    }

    @Environment(\.isEnabled) var isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer(minLength: minChevronSpacing)

            Image(systemName: SFSymbolName.chevronForward)
                .foregroundColor(Color(.tertiaryLabel))
                .font(.body.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(Color(.label))
    }
}

extension ButtonStyle where Self == NavigationButtonStyle {
    /// A button style that applies a navigation chevron and wraps the button with a divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    public static var simpleNavigation: NavigationButtonStyle { NavigationButtonStyle() }
}
