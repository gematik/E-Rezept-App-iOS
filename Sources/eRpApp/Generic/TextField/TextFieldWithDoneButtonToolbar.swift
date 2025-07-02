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
import SwiftUIIntrospect
import UIKit

extension View {
    /// Modifier to keep a TextField as first responder, as long as it is on screen.
    func textFieldAddToolbarWithDoneButton(
        enabled: Bool,
        action: @escaping () -> Void,
        title: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String
    )
        -> some View {
        modifier(TextFieldWithDoneButtonToolbar(
            enabled: enabled,
            action: action,
            title: title,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel
        ))
    }
}

/// Modifier to keep a TextField as first responder, as log as it is on screen.
///
/// **Important:** Works only on SwiftUI components that rely on UITextField, such as TextField and SecureField
private struct TextFieldWithDoneButtonToolbar: ViewModifier {
    let enabled: Bool
    let action: () -> Void
    let title: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String

    func body(content: Content) -> some View {
        content
            .introspect(.textField, on: .iOS(.v15, .v16, .v17, .v18)) { textField in
                let toolBar = textField
                    .inputAccessoryView as? UIToolbar ??
                    UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 44))
                let flexButton = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                    target: nil,
                    action: nil
                )
                let doneButton = BarButtonItem(
                    title: "Done",
                    style: UIBarButtonItem.Style.done,
                    action: self.action
                )
                // TODO: replace color conversion when using iOS 14 // swiftlint:disable:this todo
//              #if os(iOS)
//              doneButton.tintColor = Colors.primary.uiColor()
//              #elseif os(macOS)
//              doneButton.tintColor = NSColor(Colors.primary)
//              #else
//              // use default
//              #endif
                doneButton.accessibilityTraits = [.keyboardKey, .button]
                doneButton.accessibilityIdentifier = self.accessibilityIdentifier
                doneButton.accessibilityLabel = self.accessibilityLabel
                doneButton.title = self.title
                doneButton.isEnabled = self.enabled
                toolBar.setItems([flexButton, doneButton], animated: false)
                textField.inputAccessoryView = toolBar
            }
    }
}
