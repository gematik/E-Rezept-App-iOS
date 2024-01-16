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

extension Label where Title == Text, Icon == Image {
    init(_ stringAsset: StringAsset, systemImage: String) {
        self.init(stringAsset.key, systemImage: systemImage)
    }

    init(_ stringAsset: StringAsset, image name: String) {
        self.init(stringAsset.key, image: name)
    }
}

extension Label where Title == Text, Icon == EmptyView {
    init(_ stringAsset: StringAsset) {
        self.init(title: { Text(stringAsset.key) }, icon: {})
    }
}

extension TextField where Label == Text {
    init(
        _ stringAsset: StringAsset,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {}
    ) {
        self.init(
            stringAsset.key,
            text: text,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
}

extension SecureField where Label == Text {
    init(
        _ stringAsset: StringAsset,
        text: Binding<String>,
        onCommit: @escaping () -> Void
    ) {
        self.init(stringAsset.key, text: text, onCommit: onCommit)
    }
}

extension Button where Label == Text {
    init(_ stringAsset: StringAsset, action: @escaping () -> Void) {
        self.init(stringAsset.key, action: action)
    }
}

extension SecureField where Label == Text {
    init(_ stringAsset: StringAsset, text: Binding<String>) {
        self.init(stringAsset.key, text: text)
    }
}

extension Link where Label == Text {
    init(_ stringAsset: StringAsset, destination: URL) {
        self.init(stringAsset.key, destination: destination)
    }
}
