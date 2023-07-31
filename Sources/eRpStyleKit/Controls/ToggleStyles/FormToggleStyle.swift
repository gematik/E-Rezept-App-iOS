//
//  Copyright (c) 2023 gematik GmbH
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
