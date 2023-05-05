//
//  Copyright (c) 2023 gematik GmbH
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
import eRpStyleKit
import SwiftUI

struct UserProfileSelectionToolbarItem: View {
    let store: ProfileSelectionToolbarItemDomain.Store
    let action: () -> Void

    @ObservedObject
    var viewStore: ViewStore<ViewState, ProfileSelectionToolbarItemDomain.Action>

    init(store: ProfileSelectionToolbarItemDomain.Store, action: @escaping () -> Void) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
        self.action = action
    }

    struct ViewState: Equatable {
        let profile: UserProfile?

        init(state: ProfileSelectionToolbarItemDomain.State) {
            profile = state.profile
        }
    }

    var accessibilityValue: String {
        guard let profile = viewStore.profile else {
            return "none"
        }

        if let fullName = profile.fullName {
            return "\(profile.name); \(fullName); \(profile.connectionStatus.accessibilityValue)"
        }

        return profile.name
    }

    var body: some View {
        Button(action: action) {
            if let profile = viewStore.profile {
                InitialsImage(
                    backgroundColor: profile.color.background,
                    text: profile.acronym,
                    statusColor: profile.connectionStatus.statusColor,
                    size: .large
                )
                .accessibilityLabel(L10n.ctlBtnProfileToolbarItem)
                .accessibilityValue(accessibilityValue)
                .padding(.vertical, 8)
                .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            } else {
                ProgressView()
                    .frame(minWidth: 44, minHeight: 44, alignment: .center)
                    .contentShape(Rectangle())
            }
        }
    }
}
