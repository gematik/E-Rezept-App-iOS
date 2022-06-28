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
        public func textViewDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        public func textFieldDidBeginEditing(_: UITextField) {
            isFirstResponder.wrappedValue = true
        }

        public func textFieldDidEndEditing(_: UITextField) {
            isFirstResponder.wrappedValue = false
        }
    }
}
