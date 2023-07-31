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

struct ProfilePicturePicker: View {
    @Binding var emoji: String?

    let acronym: String
    let color: Color
    let borderColor: Color

    @State var editEmoji = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                ZStack {
                    ZStack(alignment: .leading) {
                        Text(emoji ?? (editEmoji ? "" : acronym))
                            .font(.system(size: 64).weight(.bold))
                            .frame(width: 140, height: 140, alignment: .center)
                            .background(Circle().fill(color))
                            .foregroundColor(Color(.secondaryLabel))

                        if editEmoji {
                            Circle()
                                .stroke(borderColor, lineWidth: 2.0)
                                .frame(width: 140, height: 140, alignment: .center)
                                .transition(.endlessFade(from: 0, to: 1, duration: 0.7))
                        }
                    }
                    .onTapGesture {
                        guard !editEmoji else { return }

                        editEmoji = true
                        emoji = emoji ?? ""
                    }
                    .accessibility(identifier: A11y.controls.emojiPicker.ctlBtnEmojiPickerEditSave)
                    .accessibility(value: Text(emoji ?? acronym))
                    .accessibility(label: Text(L10n.ctlBtnProfilePickerPictureA11yLabel))
                    .accessibility(removeTraits: .isHeader)
                    .accessibility(addTraits: .isButton)

                    if editEmoji {
                        EmojiTextField(text: $emoji) {
                            if emoji?.lengthOfBytes(using: .utf8) == 0 {
                                emoji = nil
                            }
                            editEmoji = false
                        }
                        .textFieldKeepFirstResponder()
                        .frame(width: 140, height: 140, alignment: .center)
                        .opacity(0)
                        .accessibility(hidden: true)
                    }
                }

                Spacer()
            }

            Button(action: {
                guard !editEmoji else {
                    if emoji?.lengthOfBytes(using: .utf8) == 0 {
                        emoji = nil
                    }
                    editEmoji = false
                    return
                }

                if emoji != nil {
                    emoji = nil
                } else {
                    emoji = ""
                    editEmoji = true
                }
            }, label: {
                Text(editEmoji ?
                    L10n.ctlBtnProfilePickerSet :
                    (emoji != nil ? L10n.ctlBtnProfilePickerReset : L10n.ctlBtnProfilePickerEdit))
            })
                .accessibility(identifier: A11y.controls.emojiPicker.ctlBtnEmojiPickerEditSave)
        }
    }
}

struct ProfilePicture_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ProfilePicturePicker(
                emoji: .constant("🎃"),
                acronym: "DD",
                color: ProfileColor.blue.background,
                borderColor: ProfileColor.blue.border
            )
            ProfilePicturePicker(
                emoji: .constant(nil),
                acronym: "DD",
                color: ProfileColor.red.background,
                borderColor: ProfileColor.red.border
            )
        }
    }
}
