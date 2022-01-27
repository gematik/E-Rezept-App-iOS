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

extension SettingsView {
    var profilesStore: ProfilesDomain.Store {
        store.scope(state: \.profiles, action: SettingsDomain.Action.profiles)
    }

    var profileStore: Store<EditProfileDomain.State?, EditProfileDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.editProfile)
                .extract(from:),
            action: ProfilesDomain.Action.profile(action:)
        )
    }

    var profilesAlertStore: Store<AlertState<ProfilesDomain.Action>?, ProfilesDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.alert)
                .extract(from:)
        )
    }

    var newProfileStore: Store<NewProfileDomain.State?, NewProfileDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.newProfile)
                .extract(from:),
            action: ProfilesDomain.Action.newProfile(action:)
        )
    }

    struct ProfileSectionView: View {
        let store: ProfilesDomain.Store

        var body: some View {
            Section(
                header: SectionHeaderView(
                    text: L10n.stgTxtHeaderProfiles,
                    a11y: A11y.settings.profiles.stgTxtHeaderProfiles
                ).padding(.bottom, 8)
            ) {
                ProfilesView(store: store)
            }
            .textCase(.none)
        }
    }
}
