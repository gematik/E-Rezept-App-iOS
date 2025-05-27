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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Perception
import SwiftUI

struct MedicationReminderListView: View {
    @Perception.Bindable var store: StoreOf<MedicationReminderListDomain>

    init(store: StoreOf<MedicationReminderListDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.profileMedicationReminder.isEmpty ||
                    store.profileMedicationReminder.allSatisfy(\.medicationProfileReminderList.isEmpty) {
                    NoRemindersView()
                        .padding(.horizontal)
                } else {
                    List {
                        ForEach(store.profileMedicationReminder) { profileMedicationReminder in
                            if !profileMedicationReminder.medicationProfileReminderList.isEmpty {
                                Section {
                                    ForEach(profileMedicationReminder
                                        .medicationProfileReminderList) { medicationProfileReminderListEntry in
                                            Button {
                                                store
                                                    .send(.selectMedicationReminder(medicationProfileReminderListEntry))
                                            } label: {
                                                Label(
                                                    title: {
                                                        SubTitle(
                                                            title: medicationProfileReminderListEntry.title,
                                                            description: medicationProfileReminderListEntry.isActive ?
                                                                L10n.medReminderTxtListPlanActive.text :
                                                                L10n.medReminderTxtListPlanInactive.text
                                                        )
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .contentShape(Rectangle())
                                                        .accessibilityElement(children: .combine)
                                                        .accessibilityLabel(medicationProfileReminderListEntry.title)
                                                        .accessibilityValue(medicationProfileReminderListEntry
                                                            .isActive ?
                                                            L10n.medReminderTxtListPlanActive.text :
                                                            L10n.medReminderTxtListPlanInactive.text)
                                                    },
                                                    icon: {}
                                                )
                                            }
                                            .buttonStyle(.simpleNavigation)
                                            .accessibilityIdentifier(A11y.medicationReminderList.medReminderListCell)
                                    }
                                    .onDelete { indexSet in
                                        store.send(.deleteFromProfileMedicationReminderList(
                                            profileMedicationReminder.id, indexSet
                                        ))
                                    }
                                } header: {
                                    SectionHeaderView(profile: profileMedicationReminder.profile)
                                        .font(.headline)
                                }
                                .headerProminence(.increased)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color(.secondarySystemBackground))
                }
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.medicationReminder,
                    action: \.destination.medicationReminder
                )
            ) { store in
                MedicationReminderSetupView(store: store)
            }
            .navigationTitle(L10n.stgBtnMedicationReminder)
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .alert($store.scope(
                state: \.destination?.alert?.alert,
                action: \.destination.alert
            ))
            .onAppear {
                store.send(.loadAllProfiles)
            }
        }
    }
}

extension MedicationReminderListView {
    struct NoRemindersView: View {
        var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Text(L10n.medReminderTxtListEmptyListHeadline)
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(L10n.medReminderTxtListEmptyListSubheadline)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
        }
    }

    struct SectionHeaderView: View {
        let profile: UserProfile

        var body: some View {
            HStack {
                ProfilePictureView(
                    image: profile.image,
                    userImageData: profile.userImageData,
                    color: profile.color,
                    connection: nil,
                    style: .small,
                    isBorderOn: true
                ) {}.disabled(true)
                    .accessibilityHidden(true)

                Text(profile.name).bold()
            }
        }
    }
}

// swiftlint:disable:next type_name
struct MedicationReminderListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        MedicationReminderListView(store: .init(
            initialState: .init(profileMedicationReminder: [
                MedicationReminderListDomain.ProfileMedicationReminder(
                    profile: UserProfile.Dummies.profileE,
                    medicationProfileReminderList: [
                        MedicationSchedule.mock1,
                        MedicationSchedule.mock2,
                    ]
                ),
            ])
        ) {
            EmptyReducer()
        })

        MedicationReminderListView(store: .init(
            initialState: .init(
                profileMedicationReminder: [MedicationReminderListDomain.ProfileMedicationReminder]()
            )
        ) {
            EmptyReducer()
        })
    }
}
