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
import eRpKit
import eRpStyleKit
import Perception
import SwiftUI

extension MedicationReminderSetupView {
    struct RepetitionView: View {
        @Perception.Bindable var store: StoreOf<MedicationReminderSetupDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    Form {
                        // Weekday selection
                        Section {
                            ForEach(MedicationSchedule.Weekday.allCases) { weekday in
                                Button {
                                    store.send(.repetitionWeekdayButtonTapped(weekday))
                                } label: {
                                    HStack {
                                        Text(weekday.name)
                                            .foregroundColor(Colors.text)
                                        Spacer()
                                        if store.isWeekdaySelected(weekday) {
                                            Image(systemName: SFSymbolName.checkmark)
                                                .font(.body.weight(.semibold))
                                                .foregroundColor(Colors.primary)
                                        }
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier(weekday.accessibilityIdentifier)
                                .accessibilityValue(
                                    store.isWeekdaySelected(weekday) ? L10n.sectionTxtIsActiveValue.text :
                                        L10n.sectionTxtIsInactiveValue.text
                                )
                            }
                        } header: {
                            Label(L10n.medReminderTxtFormSectionHeaderWeekday)
                                .font(.headline)
                        }
                        .headerProminence(.increased)

                        // Duration
                        Section {
                            Button {
                                store.send(.repetitionTypeChanged(.infinite))
                            } label: {
                                HStack {
                                    Text(L10n.medReminderTxtRepetitionTypeInfinite)
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    if store.medicationSchedule.repetitionType == .infinite {
                                        Image(systemName: SFSymbolName.checkmark)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(Colors.primary)
                                    }
                                }
                            }
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionInfinite)

                            Button {
                                store.send(.repetitionTypeChanged(.finite))
                            } label: {
                                HStack {
                                    Text(L10n.medReminderTxtRepetitionTypeFinite)
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    if store.medicationSchedule.repetitionType == .finite {
                                        Image(systemName: SFSymbolName.checkmark)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(Colors.primary)
                                    }
                                }
                            }
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionFinite)

                            if store.medicationSchedule.repetitionType == .finite {
                                DatePicker(
                                    L10n.medReminderBtnRepetitionDatepickerStart.text,
                                    selection: $store.medicationSchedule.start,
                                    in: Date() ... Date.distantFuture,
                                    displayedComponents: .date
                                )
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionDateStart)

                                DatePicker(
                                    L10n.medReminderBtnRepetitionDatepickerEnd.text,
                                    selection: $store.medicationSchedule.end,
                                    in: store.medicationSchedule.start ... Date.distantFuture,
                                    displayedComponents: .date
                                )
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionDateEnd)
                            }
                        } header: {
                            Text(L10n.medReminderTxtFormSectionHeaderDuration)
                                .font(.headline)
                        }
                        .headerProminence(.increased)
                    }
                    .navigationTitle(L10n.medReminderTxtRepetitionTitle)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    MedicationReminderSetupView.RepetitionView(
        store: .init(
            initialState: MedicationReminderSetupDomain.Dummies.state
        ) {
            MedicationReminderSetupDomain()
        }
    )
}
