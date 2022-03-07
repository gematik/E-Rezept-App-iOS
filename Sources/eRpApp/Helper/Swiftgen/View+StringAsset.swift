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

import ComposableArchitecture
import SwiftUI

// MARK: - SwiftUI Views

extension View {
    func navigationBarTitle(
        _ stringAsset: StringAsset,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarTitle(stringAsset.key, displayMode: displayMode)
    }

    func navigationTitle(_ stringAsset: StringAsset) -> some View {
        navigationTitle(stringAsset.key)
    }
}

extension ProgressView where CurrentValueLabel == EmptyView {
    init(_ stringAsset: StringAsset) where Label == Text {
        self.init(stringAsset.key)
    }
}

// MARK: TCA components

extension TextState {
    init(_ stringAsset: StringAsset) {
        self.init(stringAsset.key)
    }
}
