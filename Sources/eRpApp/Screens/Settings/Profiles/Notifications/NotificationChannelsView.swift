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

import ComposableArchitecture
import eRpStyleKit
import FeatureCardWall
import Perception
import SwiftUI

struct NotificationChannelsView: View {
    @Bindable var store: StoreOf<NotificationChannelsDomain>

    var body: some View {
        ScrollView {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.stgTxtNotificationChannelsDescription)
                        .accessibilityIdentifier(A11y.settings.notificationChannels
                            .stgTxtNotificationChannelsDescription)
                        .font(.body)
                },
                content: {
                    ForEach(Array(store.channels.enumerated()), id: \.element.id) { index, channel in
                        Toggle(isOn: Binding(
                            get: { channel.value },
                            set: { store.send(.channelToggled(id: channel.id, enabled: $0)) }
                        )) {
                            Label {
                                Text(channel.name)
                            } icon: {
                                EmptyView()
                            }
                        }
                        .modifier(SectionContainerCellModifier(last: index == store.channels.count - 1))
                    }
                }
            )
        }
        .navigationTitle(L10n.stgBtnEditProfileNotifications)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.secondarySystemBackground))
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.task).finish() }
    }
}

#Preview("NotificationChannelsView") {
    NavigationStack {
        NotificationChannelsView(store: NotificationChannelsDomain.Dummies.store)
    }
}
