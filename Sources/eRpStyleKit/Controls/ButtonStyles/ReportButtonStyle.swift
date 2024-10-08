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

/// A button style that represents interaction that can be shared.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.report)`` modifier.
public struct ReportButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .foregroundColor(Color.white)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
            .background(Colors.red600)
            .cornerRadius(16)
    }
}

extension ButtonStyle where Self == ReportButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.Tertiary)`` modifier.
    public static var report: ReportButtonStyle { ReportButtonStyle() }
}
