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

import eRpStyleKit
import SwiftUI

struct HintView<Action: Equatable>: View {
    let hint: Hint<Action>
    var closeAccessibilityLabel: String?
    var textAction: (() -> Void)?
    var closeAction: (() -> Void)?

    var body: some View {
        HStack(alignment: hint.isTopAligned ? .top : .bottom, spacing: 0) {
            if let image = hint.image {
                Image(asset: image.asset)
                    .font(.title3)
                    .foregroundColor(hint.actionColor)
                    .padding(.leading)
                    .padding(.top, hint.isTopAligned ? 16 : 0)
                    .accessibility(label: Text(image.accessibilityName ?? ""))
                    .accessibility(hidden: image.accessibilityName == nil)
            }
            if let emoji = hint.emoji {
                Text(emoji)
                    .font(.largeTitle)
                    .padding(.leading)
                    .padding(.top, hint.isTopAligned ? 16 : 0)
            }

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
                                Button {
                                    action()
                                } label: {
                                    Text(actionText)
                                }
                            } else {
                                Button {
                                    action()
                                } label: {
                                    if let actionImageName = hint.actionImageName {
                                        HStack {
                                            if hint.actionStyle.isRightAligned {
                                                Spacer()
                                                Text(actionText)
                                                Image(systemName: actionImageName)
                                            } else {
                                                Image(systemName: actionImageName)
                                                Text(actionText)
                                                Spacer()
                                            }
                                        }
                                    } else {
                                        Text(actionText)
                                    }
                                }
                                .buttonStyle(.tertiary)
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

                if let action = closeAction {
                    Button(action: action) {
                        Image(systemName: SFSymbolName.crossIconPlain)
                            .font(Font.subheadline.weight(.semibold))
                            .foregroundColor(hint.actionColor)
                            .padding(.trailing)
                            .padding(.top)
                    }
                    .accessibility(label: Text(closeAccessibilityLabel ?? L10n.hintBtnClose.text))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .accessibility(identifier: hint.id)
        .background(RoundedRectangle(cornerRadius: 16).fill(hint.fillColor))
        .border(hint.borderColor, width: 0.5, cornerRadius: 16)
    }
}
