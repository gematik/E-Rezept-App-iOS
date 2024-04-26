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

import Dependencies
import eRpKit
import eRpLocalStorage
import Foundation

extension MedicationScheduleRepository: DependencyKey {
    public static var liveValue: MedicationScheduleRepository {
        @Dependency(\.medicationScheduleStore) var medicationScheduleStore
        @Dependency(\.notificationScheduler) var notificationScheduler

        return .init(
            create: { schedule in
                _ = try medicationScheduleStore.save(medicationSchedules: [schedule])
                // todomedicationReminder: implementation executes asynchronously. can we wait for completion?
                try await notificationScheduler.cancelAllPendingRequests()
                let allMedicationSchedules = try medicationScheduleStore.fetchAll()
                try await notificationScheduler.schedule(allMedicationSchedules)
            },
            readAll: {
                try medicationScheduleStore.fetchAll()
            },
            read: { taskId in
                try medicationScheduleStore.fetch(by: taskId)
            },
            delete: { schedules in
                try await notificationScheduler.cancelAllPendingRequests()
                try medicationScheduleStore.delete(medicationSchedules: schedules)
                let allMedicationSchedules = try medicationScheduleStore.fetchAll()
                try await notificationScheduler.schedule(allMedicationSchedules)
            }
        )
    }

    public static var testValue: MedicationScheduleRepository {
        .init { _ in
            unimplemented(".create not implemented")
        } readAll: {
            unimplemented(".readAll not implemented")
        } read: { _ in
            unimplemented(".read not implemented")
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
