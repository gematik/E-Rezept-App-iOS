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

import SwiftUI

/// A toggle style that applies radio button like appearing as well as colors and paddings according to figma. Must be
/// applied manually to toggles.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.radio)`` modifier.
public struct FormRadioToggleStyle: ToggleStyle {
    var showSeparator: Bool
    let showNavigationIndicator: Bool

    public func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.$isOn.wrappedValue.toggle()
        }, label: {
            configuration.label
                .labelStyle(RadioLabelStyle(
                    isOn: configuration.$isOn,
                    showSeparator: showSeparator,
                    showNavigationIndicator: showNavigationIndicator
                ))
        })
    }
}

public struct RadioLabelStyle: LabelStyle {
    @Binding
    var isOn: Bool

    let showSeparator: Bool
    let showNavigationIndicator: Bool

    public func makeBody(configuration: Configuration) -> some View {
        Label {
            HStack(spacing: 8) {
                configuration.title

                Spacer()

                Image(systemName: isOn ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                    .font(.title3)
                    .foregroundColor(isOn ? Colors.primary : Color(.tertiaryLabel))

                if showNavigationIndicator {
                    Image(systemName: SFSymbolName.chevronForward)
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.body.weight(.semibold))
                }
            }
            .bottomDivider(showSeparator: showSeparator)

        } icon: {
            configuration.icon
        }
        .labelStyle(SectionContainerColoredIconLabelStyle(padding: true))
    }
}

extension ToggleStyle where Self == FormRadioToggleStyle {
    /// A toggle style that applies radio button like appearing as well as colors and paddings according to figma. Must
    /// be applied manually to toggles.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.radio)`` modifier.
    public static var radio: FormRadioToggleStyle {
        FormRadioToggleStyle(showSeparator: true, showNavigationIndicator: false)
    }

    /// A toggle style that applies radio button like appearing as well as colors and paddings according to figma. Must
    /// be applied manually to toggles.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.radio(showSeparator:))`` modifier.
    public static func radio(showSeparator: Bool = true) -> FormRadioToggleStyle {
        FormRadioToggleStyle(showSeparator: showSeparator, showNavigationIndicator: false)
    }

    /// A toggle style that applies radio button like appearing and also a navigation indicator. Must
    /// be applied manually to toggles.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.radioWithNavigation)`` modifier.
    public static var radioWithNavigation: FormRadioToggleStyle {
        FormRadioToggleStyle(showSeparator: true, showNavigationIndicator: true)
    }

    /// A toggle style that applies radio button like appearing and also a navigation indicator. Must
    /// be applied manually to toggles.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(.radioWithNavigation(showSeparator:))`` modifier.
    public static func radioWithNavigation(showSeparator: Bool = true) -> FormRadioToggleStyle {
        FormRadioToggleStyle(showSeparator: showSeparator, showNavigationIndicator: true)
    }
}

struct FormRadioToggleStyle_Preview: PreviewProvider {
    struct Wrapped: View {
        @State var statusA = true
        @State var statusB = false

        var body: some View {
            SectionContainer {
                Toggle("Normal Toggle", isOn: $statusB)

                Toggle("Normal Toggle", isOn: $statusA)

                Toggle("Radio Toggle", isOn: $statusB)
                    .toggleStyle(.radio)

                Toggle("Radio Toggle", isOn: $statusA)
                    .toggleStyle(.radio)
            }
        }
    }

    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Wrapped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
