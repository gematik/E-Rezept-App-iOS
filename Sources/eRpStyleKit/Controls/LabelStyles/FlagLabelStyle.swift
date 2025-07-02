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
public struct FlagLabelStyle: LabelStyle {
    let flagType: FlagType

    init(_ type: FlagType = .blue) {
        flagType = type
    }

    enum FlagType {
        case blue
        case red
    }

    var backgroundColor: Color {
        switch flagType {
        case .blue:
            return Colors.primary100
        case .red:
            return Colors.red100
        }
    }

    var foregroundColor: Color {
        switch flagType {
        case .blue:
            return Colors.primary900
        case .red:
            return Colors.red900
        }
    }

    var iconColor: Color {
        switch flagType {
        case .blue:
            return Colors.primary700
        case .red:
            return Colors.red600
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.title
                .font(Font.subheadline)
                .foregroundColor(foregroundColor)
            configuration.icon
                .font(Font.subheadline.weight(.semibold))
                .foregroundColor(iconColor)
        }
        .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

extension LabelStyle where Self == FlagLabelStyle {
    /// A flag label style in blue .
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``Label/labelStyle(_:)`` modifier.
    public static var blueFlag: FlagLabelStyle { FlagLabelStyle(.blue) }

    /// A flag label style in red .
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``Label/labelStyle(_:)`` modifier.
    public static var redFlag: FlagLabelStyle { FlagLabelStyle(.red) }
}

struct FlagLabelStyle_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            Label("Simple Label", systemImage: SFSymbolName.ant)
                .labelStyle(.blueFlag)

            Label("Simple Label", systemImage: SFSymbolName.ant)
                .labelStyle(.redFlag)
        }
    }
}
