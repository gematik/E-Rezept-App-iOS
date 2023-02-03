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

/// sourcery: StringAssetInitialized
struct ToggleCell: View {
    let text: LocalizedStringKey
    let a11y: String
    var systemImage: String?
    var textColor: Color
    var iconColor: Color
    var backgroundColor: Color
    @Binding<Bool> var isToggleOn: Bool
    @Binding<Bool> var isDisabled: Bool

    init(text: LocalizedStringKey,
         a11y: String,
         systemImage: String? = nil,
         textColor: Color = Colors.text,
         iconColor: Color = Colors.primary500,
         backgroundColor: Color = Colors.systemBackgroundTertiary,
         isToggleOn: Binding<Bool> = .constant(false),
         isDisabled: Binding<Bool> = .constant(false)) {
        self.text = text
        self.a11y = a11y
        self.systemImage = systemImage
        self.textColor = textColor
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        _isToggleOn = isToggleOn
        _isDisabled = isDisabled
    }

    var body: some View {
        Toggle(isOn: $isToggleOn) {
            HStack(spacing: 16) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(isDisabled ? Colors.systemGray : iconColor)
                        .disabled(isDisabled)
                }
                Text(text)
                    .font(.body)
                    .foregroundColor(isDisabled ? Colors.systemGray : textColor)
            }
        }
        .disabled(isDisabled)
        .background(backgroundColor)
        .padding(.vertical)
        .accessibility(identifier: a11y)
    }
}

struct ToggleCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                ToggleCell(text: "Peter picked a peck of peppers",
                           a11y: "dummy_a11y_a",
                           systemImage: SFSymbolName.wandAndStars,
                           isToggleOn: .constant(true))
                Spacer()
            }
            .background(Color.purple)

            VStack {
                Spacer()
                ToggleCell(text: "Peter picked a peck of peppers",
                           a11y: "dummy_a11y_a",
                           systemImage: SFSymbolName.wandAndStars,
                           isToggleOn: .constant(true),
                           isDisabled: .constant(true))
                Spacer()
            }
            .background(Color.purple)

            VStack {
                Spacer()
                ToggleCell(text: "Peter picked a peck of peppers",
                           a11y: "dummy_a11y_b",
                           systemImage: SFSymbolName.wandAndStars,
                           isToggleOn: .constant(true))
                Spacer()
            }
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .background(Color.purple)

            VStack {
                Spacer()
                ToggleCell(text: "Peter picked a peck of peppers",
                           a11y: "dummy_a11y_c",
                           isToggleOn: .constant(true))
                Spacer()
            }
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .background(Color.purple)

        }.previewLayout(.fixed(width: 400.0, height: 150.0))
    }
}
