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
import UIKit

struct FocusTextField: UIViewRepresentable {
    let placeholder: String?

    @Binding var isFirstResponder: Bool
    @Binding var text: String

    init(placeholder: String? = nil, text: Binding<String>, isFirstResponder: Binding<Bool>) {
        self.placeholder = placeholder
        _text = text
        _isFirstResponder = isFirstResponder
    }

    func makeUIView(context: UIViewRepresentableContext<FocusTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context _: UIViewRepresentableContext<FocusTextField>) {
        uiView.text = text

        switch isFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> FocusTextField.Coordinator {
        Coordinator(_text, isFirstResponder: _isFirstResponder)
    }
}

extension FocusTextField {
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self.text = text
            self.isFirstResponder = isFirstResponder
        }

        @objc
        func textViewDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_: UITextField) {
            isFirstResponder.wrappedValue = true
        }

        func textFieldDidEndEditing(_: UITextField) {
            isFirstResponder.wrappedValue = false
        }
    }
}
