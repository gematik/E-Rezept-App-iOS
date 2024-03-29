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

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @ViewBuilder func tabContainerToolBarBackground() -> some View {
        if #available(iOS 16, *) {
            content
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Asset.Colors.tabViewToolBarBackground.color, for: .tabBar)
        } else {
            content
        }
    }
}

extension Backport where Content: View {
    @ViewBuilder func navigationBarToolBarBackground(color: Color) -> some View {
        if #available(iOS 16, *) {
            content
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(color, for: .navigationBar)
        } else {
            content
        }
    }
}
