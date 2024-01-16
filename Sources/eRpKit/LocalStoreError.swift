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

import Foundation

// sourcery: CodedError = "203"
/// Local store error cases
public enum LocalStoreError: Swift.Error, LocalizedError, Equatable {
    // sourcery: errorCode = "01"
    case notImplemented
    // sourcery: errorCode = "02"
    case initialization(error: Swift.Error)
    // sourcery: errorCode = "03"
    case write(error: Swift.Error)
    // sourcery: errorCode = "04"
    case delete(error: Swift.Error)
    // sourcery: errorCode = "05"
    case read(error: Swift.Error)

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "missing interface implementation"
        case let .initialization(error: error):
            return error.localizedDescription
        case let .write(error: error):
            return error.localizedDescription
        case let .delete(error: error):
            return error.localizedDescription
        case let .read(error: error):
            return error.localizedDescription
        }
    }

    public static func ==(lhs: LocalStoreError, rhs: LocalStoreError) -> Bool {
        switch (lhs, rhs) {
        case (notImplemented, notImplemented): return true
        case let (initialization(error: lhsError), initialization(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (write(error: lhsError), write(error: rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        case let (delete(error: lhsError), delete(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (read(error: lhsError), read(error: rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        default: return false
        }
    }
}
