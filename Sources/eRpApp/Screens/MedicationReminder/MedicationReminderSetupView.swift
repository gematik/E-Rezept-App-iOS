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
import SwiftUIIntrospect

struct MedicationReminderSetupView: View {
    @Perception.Bindable var store: StoreOf<MedicationReminderSetupDomain>

    init(store: StoreOf<MedicationReminderSetupDomain>) {
        self.store = store
    }

    @Dependency(\.uiDateFormatter) var dateFormatter
    @FocusState var focus: MedicationReminderSetupDomain.State.Field?

    var body: some View {
        WithPerceptionTracking {
            Form {
                WithPerceptionTracking {
                    Section {
                        Toggle(isOn: $store.medicationSchedule.isActive.animation()) {
                            Text(L10n.medReminderBtnActivationToggle)
                        }
                        .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnActivationToggle)

                        Button {
                            store.send(.showDosageInstructionsInfo)
                        } label: {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(store.medicationSchedule.dosageInstructions)
                                        .foregroundColor(Colors.text)
                                    Text(L10n.medReminderTxtDosageInstructionSubtitle)
                                        .font(.subheadline)
                                        .foregroundColor(Colors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: SFSymbolName.info)
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(Colors.primary)
                            }
                            .contentShape(Rectangle()) // iOS15 workaround to fix button tap area
                        }
                        .buttonStyle(.plain) // iOS15 workaround to fix button embedded in forms
                        .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnDosageInstruction)
                    } header: {
                        VStack(spacing: 16) {
                            Image(systemName: SFSymbolName.alarm)
                                .font(.largeTitle.bold())
                                .foregroundColor(Colors.primary)

                            Text(store.medicationSchedule.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderTxtScheduleHeader)
                        }
                    }
                    .headerProminence(.increased)

                    if store.medicationSchedule.isActive {
                        let repetitionValue = store.medicationSchedule.repetitionType == .infinite
                            ? L10n.medReminderTxtRepetitionTypeInfinite
                            : L10n.medReminderTxtRepetitionFiniteTill(
                                dateFormatter.relativeDate(from: store.medicationSchedule.end)
                            )
                        Section {
                            Button {
                                store.send(.showRepetitionDetails)
                            } label: {
                                HStack {
                                    Text(L10n.medReminderTxtRepetitionTitle)
                                        .foregroundColor(Colors.text)
                                    Spacer()

                                    Text(repetitionValue)
                                        .foregroundColor(Colors.textSecondary)
                                    Image(systemName: SFSymbolName.chevronForward)
                                        .foregroundColor(Color(.tertiaryLabel))
                                        .font(.body.weight(.semibold))
                                }
                                .contentShape(Rectangle()) // iOS15 workaround to fix button tap area
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(L10n.medReminderTxtRepetitionTitle)
                            .accessibilityValue(repetitionValue.text)
                            .buttonStyle(.plain) // iOS15 workaround to fix button embedded in forms
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionDetails)
                        } header: {
                            Label(L10n.medReminderTxtScheduleSectionHeader)
                                .font(.headline)
                                .accessibilityIdentifier(A11y.medicationReminder
                                    .medReminderTxtScheduleTimeSectionHeader)
                        }
                        .headerProminence(.increased)

                        Section {
                            ForEach($store.medicationSchedule.entries) { $entry in
                                HStack {
                                    // Dummy Element to fix cell separator length
                                    Text("")
                                        .accessibilityHidden(true)

                                    DatePicker(
                                        selection: .init(
                                            get: {
                                                let calendar = Calendar.autoupdatingCurrent
                                                return calendar.date(
                                                    from: .init(
                                                        hour: entry.hourComponent,
                                                        minute: entry.minuteComponent,
                                                        second: 0
                                                    )
                                                )! // swiftlint:disable:this force_unwrapping
                                            },
                                            set: { date in
                                                let calendar = Calendar.autoupdatingCurrent
                                                entry.hourComponent = calendar.component(.hour, from: date)
                                                entry.minuteComponent = calendar.component(.minute, from: date)
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    ) {}
                                        .offset(x: -16) // layout priority + offset makes it look correct
                                        .focused($focus, equals: .time(entry.id))
                                        .introspect(.datePicker, on: .iOS(.v15, .v16, .v17, .v18)) { datePicker in
                                            datePicker.minuteInterval = 5
                                            let calendar = Calendar.autoupdatingCurrent
                                            datePicker.calendar = calendar
                                        }
                                        .accessibilityIdentifier(A11y.medicationReminder
                                            .medReminderBtnScheduleTimeDatePicker)

                                    HStack {
                                        TextField(
                                            L10n.medReminderTxtTimeScheduleAmountPlaceholder,
                                            text: $entry.amount
                                        )
                                        .focused($focus, equals: .dose(entry.id))
                                        .multilineTextAlignment(.trailing)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .accessibilityIdentifier(A11y.medicationReminder
                                            .medReminderBtnScheduleTimeTextfieldAmount)

                                        Text(L10n.medReminderTxtTimeScheduleDosageLabel)
                                            .accessibilityHidden(true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .layoutPriority(100.0)
                                }
                            }
                            .onDelete { indexSet in
                                store.send(.delete(indexSet))
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnScheduleTimeList)

                            Button {
                                store.send(.addButtonPressed, animation: .default)
                            } label: {
                                Label(
                                    title: {
                                        Text(L10n.medReminderBtnTimeScheduleAddEntry)
                                            .foregroundColor(Colors.primary)
                                    },
                                    icon: {
                                        Image(systemName: SFSymbolName.plusCircleFill)
                                            .foregroundColor(.green)
                                            .offset(x: -2)
                                    }
                                )
                                .contentShape(Rectangle()) // iOS15 workaround to fix button tap area
                            }
                            .buttonStyle(.plain) // iOS15 workaround to fix button embedded in forms
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnScheduleTimeAddEntry)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .listStyle(.insetGrouped)
            .bind($store.focus, to: self.$focus)
            .smallSheet($store
                .scope(state: \.destination?.dosageInstructionsInfo,
                       action: \.destination.dosageInstructionsInfo)) { store in
                    DosageInstructionsDrawerView(store: store)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.repetitionDetails,
                    action: \.destination.repetitionDetails
                )
            ) { _ in
                RepetitionView(store: store)
            }
            .background(Colors.backgroundSecondary)
            .navigationTitle(L10n.medReminderTxtTitle.text)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.save)
                    } label: {
                        Text(L10n.medReminderBtnSaveSchedule)
                    }
                    .disabled(store.medicationSchedule.isActive && store.medicationSchedule.entries.isEmpty)
                    .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnSaveSchedule)
                }
            }
        }
    }
}

extension MedicationReminderSetupView {
    struct DosageInstructionsDrawerView: View {
        @Perception.Bindable var store: StoreOf<DosageInstructionsDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.title)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.medicationReminder.medReminderDrawerDosageInstructionInfoTitle)

                    Text(store.description)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibilityIdentifier(A11y.medicationReminder
                            .medReminderDrawerDosageInstructionInfoDescription)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(A11y.medicationReminder.medReminderDrawerDosageInstructionInfo)
            }
        }
    }
}

// swiftlint:disable:next type_name
struct MedicationReminderSetupView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView<MedicationReminderSetupView> {
            MedicationReminderSetupView(store: MedicationReminderSetupDomain.Dummies.store)
        }
    }
}
