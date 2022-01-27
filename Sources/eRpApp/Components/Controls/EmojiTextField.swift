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
import UIKit

struct EmojiTextField: UIViewRepresentable {
    @Binding
    var text: String?

    var completion: () -> Void

    func makeUIView(context: Context) -> EmojiTextFieldWrapper {
        let textField = EmojiTextFieldWrapper()
        textField.contentMode = .center
        textField.contentVerticalAlignment = .center
        textField.textAlignment = .center
        textField.addTarget(
            context.coordinator,
            action: #selector(ObservationContainer.valueChanged(_:)),
            for: .editingChanged
        )
        textField.delegate = context.coordinator

        return textField
    }

    func updateUIView(_ uiView: EmojiTextFieldWrapper, context _: Context) {
        uiView.text = text
    }

    class ObservationContainer: NSObject, UITextFieldDelegate {
        @Binding
        var text: String?

        var completion: () -> Void

        init(text: Binding<String?>, editingEnded: @escaping () -> Void) {
            _text = text
            completion = editingEnded
        }

        @objc
        func valueChanged(_ textField: UITextField) {
            guard var text = textField.text else { return }

            if text.lengthOfBytes(using: .utf8) > 1 {
                text = String(text.suffix(1))
                textField.text = text
            }
            self.text = text
        }

        func textFieldDidEndEditing(_: UITextField) {
            completion()
        }
    }

    func makeCoordinator() -> ObservationContainer {
        ObservationContainer(text: $text, editingEnded: completion)
    }

    // Source: https://stackoverflow.com/questions/11382753/change-the-ios-keyboard-layout-to-emoji
    // Custom UITextField subclass to force emoji keyboard
    class EmojiTextFieldWrapper: UITextField {
        // required for iOS 13
        override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

        override var textInputMode: UITextInputMode? {
            for mode in UITextInputMode.activeInputModes where mode.primaryLanguage == "emoji" {
                return mode
            }
            return nil
        }
    }
}
