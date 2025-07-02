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

import Dependencies
import eRpKit
import eRpLocalStorage
import Foundation

extension MedicationScheduleRepository: @retroactive
DependencyKey {
    public static var liveValue: MedicationScheduleRepository {
        @Dependency(\.medicationScheduleStore) var medicationScheduleStore
        @Dependency(\.notificationScheduler) var notificationScheduler

        return .init(
            create: { schedule in
                _ = try medicationScheduleStore.save(medicationSchedules: [schedule])
                // todomedicationReminder: implementation executes asynchronously. can we wait for completion?
                try await notificationScheduler.cancelAllPendingRequests()

                let allMedicationSchedules = try await MainActor.run {
                    try medicationScheduleStore.fetchAll()
                }
                try await notificationScheduler.schedule(allMedicationSchedules)
            },
            readAll: {
                try await MainActor.run {
                    try medicationScheduleStore.fetchAll()
                }
            },
            read: { taskId in
                try await MainActor.run {
                    try medicationScheduleStore.fetch(by: taskId)
                }
            },
            delete: { schedules in
                try await notificationScheduler.cancelAllPendingRequests()
                try await MainActor.run {
                    try medicationScheduleStore.delete(medicationSchedules: schedules)
                }
                let allMedicationSchedules = try await MainActor.run {
                    try medicationScheduleStore.fetchAll()
                }
                try await notificationScheduler.schedule(allMedicationSchedules)
            }
        )
    }

    public static var testValue: MedicationScheduleRepository {
        .init { _ in
            unimplemented(".create not implemented")
        } readAll: {
            unimplemented(".readAll not implemented", placeholder: [])
        } read: { _ in
            unimplemented(".read not implemented", placeholder: nil)
        } delete: { _ in
            unimplemented(".delete not implemented")
        }
    }
}

extension DependencyValues {
    var medicationScheduleRepository: MedicationScheduleRepository {
        get { self[MedicationScheduleRepository.self] }
        set { self[MedicationScheduleRepository.self] = newValue }
    }
}
