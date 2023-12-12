//
//  Copyright (c) 2023 gematik GmbH
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
