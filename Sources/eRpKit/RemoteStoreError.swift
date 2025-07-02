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

import FHIRClient
import Foundation

// sourcery: CodedError = "204"
/// Remote store error cases
public enum RemoteStoreError: Swift.Error, LocalizedError, Equatable {
    public static func ==(lhs: RemoteStoreError, rhs: RemoteStoreError) -> Bool {
        switch (lhs, rhs) {
        case let (fhirClient(lhsError), fhirClient(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (notImplemented, notImplemented): return true
        default: return false
        }
    }

    // sourcery: errorCode = "01"
    case fhirClient(FHIRClient.Error)
    // sourcery: errorCode = "02"
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case let .fhirClient(error):
            return error.localizedDescription
        case .notImplemented:
            return "ErxTaskFHIRDataStore: missing interface implementation"
        }
    }
}
