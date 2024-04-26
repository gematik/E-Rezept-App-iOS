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

import eRpKit
import Foundation

extension MedicationSchedule {
    enum Fixtures {
        static let medicationScheduleWForTask_id_1: MedicationSchedule = .init(
            id: UUID(uuidString: "beefbeef-0001-beef-beef-beefbeefbeef")!,
            start: "2021-06-10T10:55:10+02:00".date!,
            end: .distantFuture,
            title: "Test Schedule",
            dosageInstructions: "1-1-1",
            taskId: "id_1",
            isActive: false,
            entries: [
                .init(
                    id: UUID(uuidString: "beefbeef-0002-beef-beef-beefbeefbeef")!,
                    hourComponent: 10,
                    minuteComponent: 35,
                    dosageForm: "Pill",
                    amount: "1"
                ),
            ]
        )

        static let medicationScheduleWForTask_id_2: MedicationSchedule = .init(
            id: UUID(uuidString: "beefbeef-0003-beef-beef-beefbeefbeef")!,
            start: "2021-06-10T10:55:06+02:00".date!,
            end: .distantFuture,
            title: "Test Schedule",
            dosageInstructions: "1-1-1-1",
            taskId: "id_2",
            isActive: true,
            entries: [
                .init(
                    id: UUID(uuidString: "beefbeef-0004-beef-beef-beefbeefbeef")!,
                    hourComponent: 12,
                    minuteComponent: 55,
                    dosageForm: "Tab",
                    amount: "17"
                ),
            ]
        )
    }
}
