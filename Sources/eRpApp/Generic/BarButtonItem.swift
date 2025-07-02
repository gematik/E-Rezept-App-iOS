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

import UIKit

/// Subclass of UIBarButtonItem that provides a closure based action.
class BarButtonItem: UIBarButtonItem {
    var triggerAction: () -> Void

    override init() {
        triggerAction = {}
        super.init()
    }

    init(image _: UIImage?, style _: UIBarButtonItem.Style, action: @escaping (() -> Void)) {
        triggerAction = action

        super.init()

        target = self
        self.action = #selector(buttonPressed)
    }

    init(title: String?, style: UIBarButtonItem.Style, action: @escaping (() -> Void)) {
        triggerAction = action
        super.init()

        self.title = title
        self.style = style
        target = self
        self.action = #selector(buttonPressed)
    }

    @objc
    private func buttonPressed() {
        triggerAction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        triggerAction = {}
        super.init(coder: coder)
        assert(false, "This class is not meant to be used with serialization. Use `UIBarButtonItem` instead.")
    }
}
