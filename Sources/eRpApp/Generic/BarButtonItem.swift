//
//  Copyright (c) 2021 gematik GmbH
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
