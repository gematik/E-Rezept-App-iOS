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

import CodedError
import Foundation

/// Local store error cases
@CodedError("203")
public enum LocalStoreError: Swift.Error, LocalizedError, Equatable {
    @ErrorCode("01")
    case notImplemented
    @ErrorCode("02")
    case initialization(error: Swift.Error)
    @ErrorCode("03")
    case write(error: Swift.Error)
    @ErrorCode("04")
    case delete(error: Swift.Error)
    @ErrorCode("05")
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
