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

import SwiftUI
import UIKit

extension View {
    /// Modifier to keep a TextField as first responder, as long as it is on screen.
    func textFieldKeepFirstResponder(pause: Bool = false) -> some View {
        modifier(TextFieldAsFirstResponder(pause: pause))
    }
}

/// Modifier to keep a TextField as first responder, as long as it is on screen.
///
/// **Important:** Works only on SwiftUI components that rely on UITextField, such as TextField and SecureField
private struct TextFieldAsFirstResponder: ViewModifier {
    let pause: Bool
    func body(content: Content) -> some View {
        content
            .introspectTextField { textField in
                if pause,
                   textField.isFirstResponder {
                    textField.resignFirstResponder()
                }

                guard !pause,
                      !textField.isFirstResponder else { return }

                // Async is necessary to not overlap the swiftui animation, which would cause flicker
                // 0.5 is an educated guess rather than anything else
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    textField.becomeFirstResponder()
                }
            }
    }
}
