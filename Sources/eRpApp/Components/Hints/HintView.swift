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

struct HintView<Action: Equatable>: View {
    let hint: Hint<Action>
    var closeAccessibilityLable: String?
    var textAction: (() -> Void)?
    var closeAction: (() -> Void)?

    var body: some View {
        HStack(alignment: hint.isTopAligned ? .top : .bottom, spacing: 0) {
            Image(hint.image.name)
                .foregroundColor(hint.actionColor)
                .font(.title3)
                .padding(.leading)
                .padding(.top, hint.isTopAligned ? 16 : 0)
                .accessibility(label: Text(hint.image.accessibilityName ?? ""))
                .accessibility(hidden: hint.image.accessibilityName == nil)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    if let title = hint.title {
                        Text(title)
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(hint.textColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let message = hint.message {
                        Text(message)
                            .font(Font.subheadline)
                            .foregroundColor(hint.textColor)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                            .layoutPriority(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let actionText = hint.actionText {
                        if let action = textAction {
                            if hint.buttonStyle == Hint.ButtonStyle.quaternary {
                                QuaternaryButton(text: actionText, action: action)
                            } else {
                                TertiaryButton(text: actionText, action: action)
                            }
                        } else {
                            Text(actionText)
                                .fontWeight(.regular)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.vertical)

                if hint.hasCloseAction, let action = closeAction {
                    Button(action: action) {
                        Image(systemName: SFSymbolName.crossIconPlain)
                            .font(Font.subheadline.weight(.semibold))
                            .foregroundColor(hint.actionColor)
                            .padding(.trailing)
                            .padding(.top)
                    }
                    .accessibility(label: Text(closeAccessibilityLable ?? L10n.hintBtnClose.text))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .accessibility(identifier: hint.id)
        .background(RoundedRectangle(cornerRadius: 16).fill(hint.fillColor))
        .border(hint.borderColor, width: 0.5, cornerRadius: 16)
    }
}

struct HintView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HintView(
                hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .awareness, buttonStyle: .tertiary),
                textAction: {},
                closeAction: {}
            )
            .previewLayout(.fixed(width: 400.0, height: 200.0))
            HintView(
                hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .awareness),
                textAction: {},
                closeAction: {}
            )
            .previewLayout(.fixed(width: 400.0, height: 200.0))
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraLarge)
            HintView(hint: MainViewHintsDomain.Dummies.hintTopAligned(with: .neutral), textAction: {}, closeAction: {})
                .previewLayout(.fixed(width: 400.0, height: 200.0))
            HintView(
                hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .neutral),
                textAction: {},
                closeAction: {}
            )
            .previewLayout(.fixed(width: 400.0, height: 200.0))
            .preferredColorScheme(.dark)
            HintView(
                hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .important),
                textAction: {},
                closeAction: {}
            )
            .previewLayout(.fixed(width: 400.0, height: 200.0))
            HintView(
                hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .important),
                textAction: {},
                closeAction: {}
            )
            .previewLayout(.fixed(width: 400.0, height: 200.0))
            .preferredColorScheme(.dark)
        }
    }
}
