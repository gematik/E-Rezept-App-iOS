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
import Foundation

@Reducer
struct MedicationReminderOneDaySummaryDomain {
    @ObservableState
    struct State: Equatable {
        init(entries: [UUID], medicationSchedules: [MedicationSchedule] = []) {
            self.entries = entries
            self.medicationSchedules = IdentifiedArray(uniqueElements: medicationSchedules)
        }

        let entries: [UUID]
        var medicationSchedules: IdentifiedArrayOf<MedicationSchedule>
    }

    enum Action: Equatable {
        case onAppear
        case schedulesReceived([MedicationSchedule])

        case goToMedicationReminderListButtonTapped
        case closeButtonTapped
    }

    @Dependency(\.medicationScheduleRepository) var medicationScheduleRepository
    @Dependency(\.date) var date
    @Dependency(\.router) var router: Routing
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let result = try await medicationScheduleRepository.readAll()
                    await send(.schedulesReceived(result))
                }
            case let .schedulesReceived(schedules):
                let now = date.now
                // present only schedules that are active today
                let activeToday: [MedicationSchedule] = schedules.filter {
                    $0.isActive
                        && $0.start <= now
                        && now <= $0.end
                }

                // present entries of each schedule in daytime based order (ascending)
                let entriesSorted: [MedicationSchedule] = activeToday.reduce([MedicationSchedule]()) { acc, next in
                    let timeSortedEntries = IdentifiedArray(
                        uniqueElements: next.entries.sorted { entry1, entry2 in
                            entry1.hourComponent < entry2.hourComponent ||
                                (
                                    entry1.hourComponent == entry2.hourComponent &&
                                        entry1.minuteComponent < entry2.minuteComponent
                                )
                        }
                    )
                    let scheduleWithTimeSortedEntries = MedicationSchedule.lens.entries.set(timeSortedEntries)(next)
                    return acc + [scheduleWithTimeSortedEntries]
                }

                // present schedules in order by medication name (ascending)

                let schedulesSorted: [MedicationSchedule] = entriesSorted
                    .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }

                state.medicationSchedules = IdentifiedArray(uniqueElements: schedulesSorted)
                return .none

            case .goToMedicationReminderListButtonTapped:
                return .run { _ in
                    await dismiss()
                    await router.routeTo(.settings(.medicationSchedule))
                }
            case .closeButtonTapped:
                return .run { _ in await dismiss(animation: .easeInOut) }
            }
        }
    }
}
