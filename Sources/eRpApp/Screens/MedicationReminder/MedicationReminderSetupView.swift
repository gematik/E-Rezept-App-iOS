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
import SwiftUI

struct MedicationReminderSetupView: View {
    var store: StoreOf<MedicationReminderSetupDomain>

    init(store: StoreOf<MedicationReminderSetupDomain>) {
        self.store = store
    }

    @Dependency(\.uiDateFormatter) var dateFormatter
    @FocusState var focus: MedicationReminderSetupDomain.State.Field?

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
            VStack {
                Form {
                    Section {
                        Toggle(isOn: viewStore.$medicationSchedule.isActive.animation()) {
                            Text(L10n.medReminderBtnActivationToggle)
                        }
                        .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnActivationToggle)

                        Button {
                            store.send(.setNavigation(tag: .dosageInstructionsInfo))
                        } label: {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewStore.medicationSchedule.dosageInstructions)
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

                            Text(viewStore.medicationSchedule.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderTxtScheduleHeader)
                        }
                    }
                    .headerProminence(.increased)

                    if viewStore.medicationSchedule.isActive {
                        let repetitionValue = viewStore.medicationSchedule.repetitionType == .infinite
                            ? L10n.medReminderTxtRepetitionTypeInfinite
                            : L10n.medReminderTxtRepetitionFiniteTill(
                                dateFormatter.relativeDate(from: viewStore.medicationSchedule.end)
                            )
                        Section {
                            Button {
                                viewStore.send(.setNavigation(tag: .repetitionDetails))
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
                            ForEach(viewStore.$medicationSchedule.entries) { $entry in
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
                                        .introspectDatePicker { datePicker in
                                            datePicker.minuteInterval = 5
                                            let calendar = Calendar.autoupdatingCurrent
                                            datePicker.calendar = calendar
                                        }
                                        .accessibilityIdentifier(A11y.medicationReminder
                                            .medReminderBtnScheduleTimeDatePicker)

                                    HStack {
                                        TextField(L10n.medReminderTxtTimeScheduleAmountPlaceholder, text: $entry.amount)
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
                                viewStore.send(.delete(indexSet))
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnScheduleTimeList)

                            Button {
                                viewStore.send(.addButtonPressed, animation: .default)
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
                .environment(\.editMode, .constant(.active))
                .listStyle(.insetGrouped)
                .bind(viewStore.$focus, to: self.$focus)

                Navigations(store: store)
            }
            .background(Colors.backgroundSecondary)
            .navigationTitle(L10n.medReminderTxtTitle.text)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewStore.send(.save)
                    } label: {
                        Text(L10n.medReminderBtnSaveSchedule)
                    }
                    .disabled(viewStore.medicationSchedule.isActive && viewStore.medicationSchedule.entries.isEmpty)
                    .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnSaveSchedule)
                }
            }
        }
    }
}

extension MedicationReminderSetupView {
    struct DosageInstructionsDrawerView: View {
        @ObservedObject var viewStore: ViewStore<
            MedicationReminderSetupDomain.Destinations.DosageInstructionsState,
            MedicationReminderSetupDomain.Destinations.Action.None
        >

        init(store: Store<
            MedicationReminderSetupDomain.Destinations.DosageInstructionsState,
            MedicationReminderSetupDomain.Destinations.Action.None
        >) {
            viewStore = ViewStore(store) { $0 }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewStore.title)
                    .font(.headline)
                    .accessibilityIdentifier(A11y.medicationReminder.medReminderDrawerDosageInstructionInfoTitle)

                Text(viewStore.description)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .accessibilityIdentifier(A11y.medicationReminder.medReminderDrawerDosageInstructionInfoDescription)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Colors.systemBackground.ignoresSafeArea())
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11y.medicationReminder.medReminderDrawerDosageInstructionInfo)
        }
    }

    struct Navigations: View {
        let store: StoreOf<MedicationReminderSetupDomain>

        init(store: MedicationReminderSetupDomain.Store) {
            self.store = store
        }

        var body: some View {
            WithViewStore(store) { $0 } content: { viewStore in
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destination?.tag == .dosageInstructionsInfo },
                        set: { if !$0 { viewStore.send(.setNavigation(tag: nil), animation: .easeInOut) } }
                    )) {
                        IfLetStore(
                            store.scope(
                                state: \.$destination,
                                action: MedicationReminderSetupDomain.Action.destination
                            ),
                            state: /MedicationReminderSetupDomain.Destinations.State.dosageInstructionsInfo,
                            action: MedicationReminderSetupDomain.Destinations.Action.dosageInstructionsInfo,
                            then: DosageInstructionsDrawerView.init(store:)
                        )
                    }
                    .accessibility(hidden: true)

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: MedicationReminderSetupDomain.Action.destination),
                    state: /MedicationReminderSetupDomain.Destinations.State.repetitionDetails,
                    action: MedicationReminderSetupDomain.Destinations.Action.repetitionDetails,
                    onTap: { viewStore.send(.setNavigation(tag: .repetitionDetails)) },
                    destination: { _ in RepetitionView(store: store) },
                    label: { EmptyView() }
                ).accessibility(hidden: true)
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
