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

struct MemojiPickerView: View {
    @State var value: UIImage?

    var valueReceived: (UIImage?) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            ZStack {
                CloseButton {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text(L10n.editPictureTxt)
                    .padding([.leading, .trailing])
                    .padding(.top, 40)
                    .font(.headline.bold())

                MemojiPicker(value: $value)
            }

            VStack {
                ProfilePictureView(
                    image: nil,
                    userImageData: value?.pngData(),
                    color: nil,
                    connection: nil,
                    style: .xxLarge,
                    isBorderOn: true
                ) {
                    valueReceived(value)
                }

                Spacer()

                Button {
                    valueReceived(value)
                } label: {
                    Text(L10n.eppBtnEmojiUse)
                }
                .buttonStyle(.primaryHugging)
                .accessibilityIdentifier(A11y.editProfilePicture.eppBtnEmojiUse)
            }
            .padding()
            .padding(.top, 8)
        }
        .interactiveDismissDisabled()
        .frame(maxWidth: .infinity)
        .background(Colors.systemBackground.ignoresSafeArea())
    }
}

// Example SwiftUI view using the custom text field
struct MemojiPickerViewContentView: View {
    var body: some View {
        Text("abc")
            .sheet(isPresented: .constant(true)) {
                MemojiPickerView { _ in }
            }
    }
}

#Preview {
    MemojiPickerViewContentView()
}
