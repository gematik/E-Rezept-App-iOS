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

struct MedicationReminderOneDaySummaryView: View {
    @Perception.Bindable var store: StoreOf<MedicationReminderOneDaySummaryDomain>

    @ScaledMetric var headerPlusBottomPlusSomeHeight = 320 // use this for limiting the ScrollView's height

    init(store: StoreOf<MedicationReminderOneDaySummaryDomain>) {
        self.store = store
    }

    @Dependency(\.uiDateFormatter) var dateFormatter

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 40) {
                HeaderView { store.send(.closeButtonTapped) }

                if store.medicationSchedules.isEmpty {
                    EmptyMedicationEvent()
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 40) {
                            ForEach(store.medicationSchedules) { (schedule: MedicationSchedule) in
                                VStack(spacing: 8) {
                                    Text(schedule.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    ForEach(schedule.entries) { (entry: MedicationSchedule.Entry) in
                                        let formattedHourMinute =
                                            "\(entry.hourComponent.padWithLeadingZero):" +
                                            "\(entry.minuteComponent.padWithLeadingZero)"
                                        let dayTime = MedicationEvent.Daytime.from(hourComponent: entry.hourComponent)
                                        MedicationEvent(
                                            daytime: dayTime,
                                            text: "\(formattedHourMinute) \(entry.amount) \(entry.dosageForm)"
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: UIScreen.main.bounds.size.height - self.headerPlusBottomPlusSomeHeight)
                }

                Button {
                    store.send(.goToMedicationReminderListButtonTapped)
                } label: {
                    Text(L10n.medReminderBtnOneDaySummaryGoToRemindersOverviewButton)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Colors.primary700)
                .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnOneDaySummaryGoToRemindersOverviewButton)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Colors.systemBackground.ignoresSafeArea())
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    struct HeaderView: View {
        let closeButtonAction: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: 40) {
                VStack(spacing: 0) {
                    Capsule()
                        .foregroundColor(Colors.systemLabelQuarternary)
                        .frame(width: 32, height: 8, alignment: .center)

                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton(action: closeButtonAction)
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnOneDaySummaryCloseButton)
                    }
                    .padding(.horizontal)
                }

                Text(L10n.medReminderTxtOneDaySummaryTitle)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.top, 8)
        }

        struct CloseButton: View {
            let action: () -> Void

            var body: some View {
                Button(action: action) {
                    Image(systemName: SFSymbolName.crossIconPlain)
                        .font(Font.caption.weight(.bold))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(6)
                        .background(Circle().foregroundColor(Color(.systemGray6)))
                }
            }
        }
    }

    struct MedicationEvent: View {
        enum Daytime {
            case morning
            case noon
            case evening
            case night

            static func from(hourComponent: Int) -> Daytime {
                switch hourComponent {
                case 0 ... 3: return .night
                case 4 ... 10: return .morning
                case 11 ... 14: return .noon
                case 15 ... 17: return .evening
                case 18 ... 23: return .night
                default: return .night // actually programmatic error
                }
            }
        }

        var daytime: Daytime
        var text: String

        var iconName: String {
            switch daytime {
            case .morning:
                SFSymbolName.sunriseCircle
            case .noon:
                SFSymbolName.sunMaxCircle
            case .evening:
                SFSymbolName.sunsetCircle
            case .night:
                SFSymbolName.moonCircle
            }
        }

        var color: Color {
            switch daytime {
            case .morning:
                Color(red: 0x5A / 0xFF, green: 0xC8 / 0xFF, blue: 0xFA / 0xFF)
            case .noon:
                Color(red: 0xFF / 0xFF, green: 0xCC / 0xFF, blue: 0x00 / 0xFF)
            case .evening:
                Color(red: 0xFF / 0xFF, green: 0x9F / 0xFF, blue: 0x0A / 0xFF)
            case .night:
                Color(red: 0x58 / 0xFF, green: 0x56 / 0xFF, blue: 0xD6 / 0xFF)
            }
        }

        var title: String {
            switch daytime {
            case .morning:
                L10n.medReminderTxtOneDaySummaryInTheMorning.text
            case .noon:
                L10n.medReminderTxtOneDaySummaryInTheNoon.text
            case .evening:
                L10n.medReminderTxtOneDaySummaryInTheEvening.text
            case .night:
                L10n.medReminderTxtOneDaySummaryInTheNight.text
            }
        }

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.largeTitle)
                    .foregroundColor(color)
                    .padding([.top, .bottom, .leading])

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabel)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground))
            .border(Colors.separator, cornerRadius: 16)
        }
    }

    struct EmptyMedicationEvent: View {
        var body: some View {
            HStack(spacing: 8) {
                Image(SFSymbolName
                    .alarm)
                                    .font(.largeTitle)
                                    .foregroundColor(Colors.primary700)
                                    .padding([.top, .bottom, .leading])

                VStack(alignment: .leading) {
                    Text(L10n.medReminderTxtOneDaySummaryEmptyEventTitle)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabel)
                    Text(L10n.medReminderTxtOneDaySummaryEmptyEventSubtitle)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground))
            .border(Colors.separator, cornerRadius: 16)
        }
    }
}

// swiftlint:disable:next type_name
struct MedicationReminderOneDaySummaryView_Preview: PreviewProvider {
    private struct Preview: View {
        @State var visible = false
        var body: some View {
            VStack {
                Text("Must be in play mode to view interaction")

                Button {
                    visible.toggle()
                } label: {
                    Text("Show/Hide")
                }
            }
            .smallSheet(isPresented: $visible) {
                MedicationReminderOneDaySummaryView(store: .init(initialState: .init(entries: [UUID()])) {
                    MedicationReminderOneDaySummaryDomain()
                        .dependency(
                            \.medicationScheduleRepository,
                            MedicationScheduleRepository(
                                create: { _ in },
                                readAll: {
                                    let mock1 = MedicationSchedule.mock1
                                    let mock2 = MedicationSchedule.mock2
                                    return [mock1, mock2]
                                },
                                read: { _ in nil },
                                delete: { _ in
                                }
                            )
                        )
                })
            }
            .task {
                visible = true
            }
        }
    }

    private struct EmptyPreview: View {
        @State var visible = false
        var body: some View {
            VStack {
                Text("Must be in play mode to view interaction")

                Button {
                    visible.toggle()
                } label: {
                    Text("Show/Hide")
                }
            }
            .smallSheet(isPresented: $visible) {
                MedicationReminderOneDaySummaryView(store: .init(initialState: .init(entries: [UUID()])) {
                    MedicationReminderOneDaySummaryDomain()
                        .dependency(
                            \.medicationScheduleRepository,
                            MedicationScheduleRepository(
                                create: { _ in },
                                readAll: {
                                    []
                                },
                                read: { _ in nil },
                                delete: { _ in
                                }
                            )
                        )
                })
            }
            .task {
                visible = true
            }
        }
    }

    static var previews: some View {
        Preview()

        EmptyPreview()
    }
}

extension Int {
    var padWithLeadingZero: String {
        self < 10 ? "0\(self)" : "\(self)"
    }
}
