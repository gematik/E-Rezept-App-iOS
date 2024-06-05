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

import eRpStyleKit
import SwiftUI

struct MemojiPicker: View {
    @Binding var value: UIImage?
    @FocusState private var focused: Bool

    var body: some View {
        MemojiPickerTextField(value: $value)
            .frame(width: 0, height: 0)
            .opacity(0)
            .focused($focused)
            .onAppear {
                focused = true
            }
    }
}

private struct MemojiPickerTextField: UIViewRepresentable {
    @Binding var value: UIImage?

    func makeUIView(context: Context) -> EmojiTextFieldWrapper {
        let textField = EmojiTextFieldWrapper { image in
            value = image
        }
        textField.delegate = context.coordinator
        textField.allowsEditingTextAttributes = true
        textField.addTarget(
            context.coordinator,
            action: #selector(ObservationContainer.valueChanged(_:)),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_: EmojiTextFieldWrapper, context _: Context) {
        // View is only for creating new emojis
    }

    class ObservationContainer: NSObject, UITextFieldDelegate {
        var valueChanged: (String) -> Void
        var completion: () -> Void

        init(completion: @escaping () -> Void, valueChanged: @escaping (String) -> Void) {
            self.completion = completion
            self.valueChanged = valueChanged
        }

        @objc
        func valueChanged(_ textField: UITextField) {
            guard var text = textField.text else { return }

            if text.lengthOfBytes(using: .utf8) > 1 {
                text = String(text.suffix(1))
                textField.text = text
            }
            valueChanged(text)
        }

        func textFieldDidEndEditing(_: UITextField) {
            completion()
        }
    }

    func makeCoordinator() -> ObservationContainer {
        ObservationContainer {
            // completion todo
        } valueChanged: { emoji in
            value = renderingView(for: emoji).snapshot()
        }
    }

    @ViewBuilder func renderingView(for emoji: String) -> some View {
        let screenScale = UIScreen.main.scale
        Text(emoji)
            .baselineOffset(15 * screenScale)
            .font(.system(size: 100 * screenScale))
            .frame(width: 160 * screenScale, height: 160 * screenScale, alignment: .center)
    }

    // Source: https://stackoverflow.com/questions/11382753/change-the-ios-keyboard-layout-to-emoji
    // Custom UITextField subclass to force emoji keyboard
    class EmojiTextFieldWrapper: UITextField {
        var memojiSelected: (UIImage) -> Void

        internal init(memojiSelected: @escaping (UIImage) -> Void) {
            self.memojiSelected = memojiSelected

            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var textInputMode: UITextInputMode? {
            for mode in UITextInputMode.activeInputModes where mode.primaryLanguage == "emoji" {
                return mode
            }
            return nil
        }

        // Memojis are inserted by the pasteboard
        override func paste(_ sender: Any?) {
            guard let image = UIPasteboard.general.image else {
                super.paste(sender)
                return
            }

            memojiSelected(image)

            super.paste(sender)
        }
    }
}
