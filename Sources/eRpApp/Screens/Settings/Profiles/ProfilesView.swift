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

import CasePaths
import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct ProfilesView: View {
    @Perception.Bindable var store: StoreOf<ProfilesDomain>

    var body: some View {
        WithPerceptionTracking {
            SectionContainer(
                header: {
                    Label(title: {
                        Text(L10n.stgTxtHeaderProfiles)
                    }, icon: {})
                        .accessibility(identifier: A11y.settings.profiles.stgTxtHeaderProfiles)
                }, content: {
                    ForEach(store.profiles) { profile in
                        WithPerceptionTracking {
                            Button(action: {
                                store.send(.editProfile(profile))
                            }, label: {
                                SingleProfileView(profile: profile, selectedProfileId: store.selectedProfileId)
                            })
                                .buttonStyle(.navigation)
                                .accessibility(identifier: A11y.settings.profiles.stgBtnProfile)
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: A11y.settings.profiles.stgConProfiles)

                    Button(action: {
                        store.send(.addNewProfile)
                    }, label: {
                        Label(L10n.stgBtnAddProfile, systemImage: SFSymbolName.plus)
                    })
                        .buttonStyle(.simple(showSeparator: false))
                        .accessibility(identifier: A11y.settings.profiles.stgBtnNewProfile)
                }
            )
            .task {
                await store.send(.registerListener).finish()
            }
        }
    }

    private struct SingleProfileView: View {
        let profile: UserProfile
        let selectedProfileId: UUID?

        var body: some View {
            Label(title: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                    Group {
                        if let date = profile.lastSuccessfulSync {
                            RelativeTimerView(date: date)

                        } else {
                            Text(L10n.ctlTxtProfileCellNotConnected)
                        }
                    }
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.subheadline)
                }
            }, icon: {
                ProfilePictureView(
                    image: profile.image,
                    userImageData: profile.userImageData,
                    color: profile.color,
                    connection: nil,
                    style: .small
                ) {}.padding(.leading, 16)
            })
        }
    }
}

struct ProfilesView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        ProfilesView(store: .init(
            initialState: .init(
                profiles: [
                    UserProfile.Dummies.profileA,
                    UserProfile.Dummies.profileB,
                    UserProfile.Dummies.profileC,
                ],
                selectedProfileId: UserProfile.Dummies.profileA.id
            )
        ) {
            EmptyReducer()
        })
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}
