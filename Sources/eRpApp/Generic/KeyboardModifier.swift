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

private final class KeyboardHeight: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var height: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillShow(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillHide(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc
    func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            height = keyboardSize.cgRectValue.height
        }
    }

    @objc
    func keyBoardWillHide(notification _: Notification) {
        height = 0
    }
}

extension View {
    func respectKeyboardInsets() -> some View {
        modifier(KeyboardModifier())
    }
}

struct KeyboardModifier: ViewModifier {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static var keyboardHeight2 = KeyboardHeight()

    @ObservedObject private var keyboardHeight = keyboardHeight2

    func body(content: Content) -> some View {
        content.introspectScrollView { scrollView in

            if #available(iOS 14.0, *) {
            } else {
                let edgeInsets: UIEdgeInsets

                if self.keyboardHeight.height == 0 {
                    edgeInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: scrollView.safeAreaInsets.bottom,
                        right: 0
                    )
                } else {
                    edgeInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: self.keyboardHeight.height - scrollView.safeAreaInsets.bottom,
                        right: 0
                    )
                }

                scrollView.scrollIndicatorInsets = edgeInsets
                scrollView.contentInset = edgeInsets
            }
        }
    }
}
