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
