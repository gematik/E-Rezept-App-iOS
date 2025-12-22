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
import DependenciesMacros
import eRpKit
import Foundation

/// Repository for the app to the MedicationSchedule data layer handling the syncing between its data stores.
@DependencyClient
public struct MedicationScheduleRepository {
    /// Create a MedicationSchedule
    public var create: @Sendable (MedicationSchedule) async throws -> Void
    /// Load all MedicationSchedule
    public var readAll: @Sendable () async throws -> [MedicationSchedule]
    /// Load a MedicationSchedule with `taskId`
    public var read: @Sendable (_ taskId: String) async throws -> MedicationSchedule?
    /// Delete all passed MedicationSchedule
    public var delete: @Sendable ([MedicationSchedule]) async throws -> Void
}

extension DependencyValues {
    /// Access to the `MedicationScheduleRepository dependency.
    public var medicationScheduleRepository: MedicationScheduleRepository {
        get { self[MedicationScheduleRepository.self] }
        set { self[MedicationScheduleRepository.self] = newValue }
    }
}

extension MedicationScheduleRepository: TestDependencyKey {
    public static let testValue: MedicationScheduleRepository = Self()
}
