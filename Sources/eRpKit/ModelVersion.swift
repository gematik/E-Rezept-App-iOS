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

/// All available core data modal versions that require a manual migration step in `MigrationManager`
/// Add a new case every time you want to start a manual migration to a new `xcdatamodel`
/// The `rawValue` represents the `xcdatamodel`version
public enum ModelVersion: Int, Codable, CaseIterable {
    // Introduces status to `ErxTask`
    case taskStatus = 3
    // Introduces `Profile` entity
    case profiles = 4
    // Introduces audit events in `EditProfileDomain`.
    case auditEventsInProfile = 5
    // Introduces pKV profiles
    case pKV = 6
    // Introduces onboardingDate in userDataStore
    case onboardingDate = 7
    // Introduce displayName
    case displayName = 8
    // Introduces whether the Profile's name should be automatically updated when user logs in next time
    case shouldAutoUpdateNameAtNextLogin = 9

    /// Creates a `ModelVersion` of the next case related to self
    /// - Returns: Returns the next case if it is not the last case or returns nil
    public func next() -> ModelVersion? {
        guard let index = Self.allCases.firstIndex(of: self),
              let nextIndex = index < Self.allCases.endIndex - 1 ? index.advanced(by: 1) : nil else {
            return nil
        }

        return Self.allCases[nextIndex]
    }

    public var isLastVersion: Bool {
        self == Self.allCases.last! // swiftlint:disable:this force_unwrapping
    }

    public static var latestVersion: ModelVersion {
        Self.allCases.last! // swiftlint:disable:this force_unwrapping
    }
}
