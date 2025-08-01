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

// MARK: - SwiftUI Views

extension View {
    /// Sets the navigation bar title using a `StringAsset`.
    public func navigationBarTitle(
        _ stringAsset: StringAsset,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarTitle(stringAsset.text, displayMode: displayMode)
    }

    /// Sets the navigation title using a `StringAsset`.
    public func navigationTitle(_ stringAsset: StringAsset) -> some View {
        navigationTitle(stringAsset.text)
    }

    /// Sets the accessibility label using a `StringAsset`.
    public func accessibilityLabel(_ stringAsset: StringAsset) -> some View {
        accessibilityLabel(stringAsset.text)
    }
}

extension ProgressView where CurrentValueLabel == EmptyView {
    /// Initializes a `ProgressView` with a `StringAsset` as its label.
    public init(_ stringAsset: StringAsset) where Label == Text {
        self.init(stringAsset.text)
    }
}

// MARK: TCA components
