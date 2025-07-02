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

import Foundation

// sourcery: CodedError = "200"
/// Repository error cases
public enum ErxRepositoryError: Swift.Error, LocalizedError, Equatable {
    // sourcery: errorCode = "01"
    case local(LocalStoreError)
    // sourcery: errorCode = "02"
    case remote(RemoteStoreError)

    public var errorDescription: String? {
        switch self {
        case let .local(localError):
            return localError.localizedDescription
        case let .remote(remoteError):
            return remoteError.localizedDescription
        }
    }

    public static func ==(lhs: Self,
                          rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (local(lhsError), local(rhsError)): return lhsError == rhsError
        case let (remote(lhsError), remote(rhsError)): return lhsError == rhsError
        default: return false
        }
    }
}
