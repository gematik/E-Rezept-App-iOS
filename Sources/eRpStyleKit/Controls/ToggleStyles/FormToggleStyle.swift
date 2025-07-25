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

/// A toggle style that applies colors according to figma as well as paddings. Automatically applied to toggles
/// within content of ``SectionContainer``.
///
/// To manually apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.form)`` modifier.
public struct FormToggleStyle: ToggleStyle {
    let showSeparator: Bool

    public init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(ToggleLabelStyle(
                isOn: configuration.$isOn,
                showSeparator: showSeparator
            ))
            .labeledContentStyle(.automatic)
    }
}

public struct ToggleLabelStyle: LabelStyle {
    @Binding var isOn: Bool

    let showSeparator: Bool

    public func makeBody(configuration: Configuration) -> some View {
        Label {
            HStack {
                configuration.title

                Toggle(isOn: $isOn) {}
                    .toggleStyle(DefaultToggleStyle())
            }
            .bottomDivider(showSeparator: showSeparator)

        } icon: {
            configuration.icon
        }
        .labelStyle(SectionContainerColoredIconLabelStyle(padding: true))
    }
}

extension ToggleStyle where Self == FormToggleStyle {
    /// A toggle style that applies colors according to figma as well as paddings. Automatically applied to toggles
    /// within content of ``SectionContainer``.
    ///
    /// To manually apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.form)`` modifier.
    public static var plain: FormToggleStyle { FormToggleStyle(showSeparator: true) }
}
