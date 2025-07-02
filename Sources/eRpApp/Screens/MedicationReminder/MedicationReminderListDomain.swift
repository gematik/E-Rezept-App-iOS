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

import Combine
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import Foundation
import SwiftUI

@Reducer
struct MedicationReminderListDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case medicationReminder(MedicationReminderSetupDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Never>)
    }

    // sourcery: CodedError = "042"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case generic(String)
    }

    @ObservableState
    struct State: Equatable {
        var profileMedicationReminder: [ProfileMedicationReminder] = []
        @Presents var destination: Destination.State?
    }

    struct ProfileMedicationReminder: Identifiable, Equatable {
        var id: UUID { profile.id }
        var profile: UserProfile
        var medicationProfileReminderList: [MedicationSchedule]
    }

    enum Action: Equatable {
        case loadAllProfiles
        case loadReceived(Result<[UserProfile], UserProfileServiceError>)

        case loadProfileMedicationReminder([UserProfile])
        case profileMedicationReminderReceived([MedicationSchedule], UserProfile)
        case profileMedicationReminderFailed(Error)

        case deleteFromProfileMedicationReminderList(UUID, IndexSet)

        case selectMedicationReminder(MedicationSchedule)
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.medicationScheduleRepository) var medicationScheduleRepository: MedicationScheduleRepository
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadAllProfiles:
            return .publisher(
                userProfileService.userProfilesPublisher()
                    .first()
                    .catchToPublisher()
                    .map(Action.loadReceived)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .loadReceived(.failure(error)):
            state.destination = .alert(.error(
                error: error,
                alertState: .init(for: error, actions: {
                    ButtonState(role: .cancel) {
                        .init(L10n.alertBtnOk)
                    }
                })
            ))
            return .none
        case let .loadReceived(.success(profiles)):
            state.profileMedicationReminder = []
            return .send(.loadProfileMedicationReminder(profiles))
        case let .loadProfileMedicationReminder(profiles):
            return .run { send in
                do {
                    for userProfile in profiles {
                        var schedule: [MedicationSchedule] = []
                        // sort the schedules in the same order the data store would order the corresponding tasks
                        // to the MainView
                        let tasksSorted = userProfile.profile.erxTasks.sorted { task1, task2 in
                            guard let authoredOn1 = task1.authoredOn,
                                  let authoredOn2 = task2.authoredOn
                            else { return true }
                            return authoredOn1 > authoredOn2
                        }
                        for task in tasksSorted {
                            if let single = try await medicationScheduleRepository.read(task.identifier) {
                                schedule.append(single)
                            }
                        }
                        await send(.profileMedicationReminderReceived(schedule, userProfile))
                    }
                } catch {
                    await send(.profileMedicationReminderFailed(.generic(error.localizedDescription)))
                }
            }
        case let .profileMedicationReminderReceived(reminder, profile):
            state.profileMedicationReminder
                .append(ProfileMedicationReminder(profile: profile, medicationProfileReminderList: reminder))
            return .none
        case let .profileMedicationReminderFailed(error):
            state.destination = .alert(.error(
                error: error,
                alertState: .init(for: error, actions: {
                    ButtonState(role: .cancel) {
                        .init(L10n.alertBtnOk)
                    }
                })
            ))
            return .none
        case let .deleteFromProfileMedicationReminderList(
            profileMedicationReminderId,
            profileMedicationReminderListIndexSet
        ):
            guard let index = state.profileMedicationReminder
                .firstIndex(where: { $0.id == profileMedicationReminderId }) else {
                return .none
            }
            let profile = state.profileMedicationReminder[index]
            let schedulesToDelete = profile.medicationProfileReminderList
                .enumerated()
                .filter { profileMedicationReminderListIndexSet.contains($0.offset) }
                .map(\.element)
            state.profileMedicationReminder[index].medicationProfileReminderList
                .removeAll(where: { schedulesToDelete.contains($0) })
            if state.profileMedicationReminder[index].medicationProfileReminderList.isEmpty {
                state.profileMedicationReminder.remove(at: index)
            }
            return .run { _ in
                try await medicationScheduleRepository.delete(schedulesToDelete)
            }
        case let .selectMedicationReminder(reminder):
            state.destination = .medicationReminder(.init(medicationSchedule: reminder))
            return .none
        case let .destination(.presented(.medicationReminder(.delegate(action)))):
            switch action {
            case .saveButtonTapped:
                state.destination = nil
                return .none
            }
        case .destination:
            return .none
        }
    }
}

extension MedicationReminderListDomain {
    enum Dummies {
        static let state = State()

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<MedicationReminderListDomain> {
            Store(
                initialState: state
            ) {
                MedicationReminderListDomain()
            }
        }
    }
}
