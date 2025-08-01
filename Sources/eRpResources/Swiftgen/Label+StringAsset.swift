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

extension Label where Title == Text, Icon == Image {
    /// Initializes a `Label` with a `StringAsset` and a system image.
    public init(_ stringAsset: StringAsset, systemImage: String) {
        self.init {
            Text(stringAsset.key, bundle: .module)
        } icon: {
            Image(systemName: systemImage)
        }
    }

    /// Initializes a `Label` with a `StringAsset` and an asset image.
    public init(_ stringAsset: StringAsset, image name: String) {
        self.init {
            Text(stringAsset.key, bundle: .module)
        } icon: {
            Image(name, bundle: .module)
        }
    }
}

extension Label where Title == Text, Icon == EmptyView {
    /// Initializes a `Label` with a `StringAsset` and no icon.
    public init(_ stringAsset: StringAsset) {
        self.init(
            title: { Text(stringAsset.key, bundle: .module) },
            icon: {}
        )
    }
}

extension TextField where Label == Text {
    /// Initializes a `TextField` with a `StringAsset` as its label.
    public init(
        _ stringAsset: StringAsset,
        text: Binding<String>
    ) {
        self.init(text: text) {
            Text(stringAsset.key, bundle: .module)
        }
    }
}

extension TextField where Label == Text {
    init(
        _ stringAsset: StringAsset,
        text: Binding<String>,
        axis: Axis
    ) {
        self.init(text: text, axis: axis) {
            Text(stringAsset.key, bundle: .module)
        }
    }
}

extension SecureField where Label == Text {
    /// Initializes a `SecureField` with a `StringAsset` as its label.
    public init(
        _ stringAsset: StringAsset,
        text: Binding<String>
    ) {
        self.init(text: text) {
            Text(stringAsset.key, bundle: .module)
        }
    }
}

extension Button where Label == Text {
    /// Initializes a `Button` with a `StringAsset` as its label.
    public init(_ stringAsset: StringAsset, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(stringAsset.key, bundle: .module)
        }
    }
}

extension Link where Label == Text {
    /// Initializes a `Link` with a `StringAsset` as its label.
    public init(_ stringAsset: StringAsset, destination: URL) {
        self.init(destination: destination) {
            Text(stringAsset.key, bundle: .module)
        }
    }
}

@available(iOS 16.0, *)
extension LabeledContent where Label == Text, Content: View {
    /// Initializes a `LabeledContent` with a `StringAsset` as its label.
    @_disfavoredOverload
    public init(_ stringAsset: StringAsset, @ViewBuilder content: () -> Content) {
        self.init(stringAsset.text) {
            content()
        }
    }
}
