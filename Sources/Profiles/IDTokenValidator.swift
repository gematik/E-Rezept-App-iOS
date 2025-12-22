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
import Combine
import eRpKit
import eRpResources
import Foundation
import IDP

/// Validates IDTokenPayload against existing profiles in ProfileDataStore
public protocol IDTokenValidator {
    /// Validates IDTokenPayload against existing profiles in ProfileDataStore
    func validate(idToken: TokenPayload.IDTokenPayload) -> Result<Bool, Error>
}

@CodedError("021")
public enum IDTokenValidatorError: Error, LocalizedError, Equatable {
    @ErrorCode("01")
    case profileNotFound
    @ErrorCode("02")
    case profileNotMatchingInsuranceId(String?)
    @ErrorCode("03")
    case profileWithInsuranceIdExists(String)
    @ErrorCode("04")
    case other(error: Swift.Error)

    public var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return L10n.sessionErrorNoProfile.text
        case let .profileNotMatchingInsuranceId(kvnr):
            return L10n.sessionErrorCardProfileMismatch(kvnr ?? "").text
        case let .profileWithInsuranceIdExists(profileName):
            return L10n.sessionErrorCardConnectedWithOtherProfile(profileName).text
        case let .other(error: error):
            return error.localizedDescription
        }
    }

    public static func ==(lhs: IDTokenValidatorError, rhs: IDTokenValidatorError) -> Bool {
        switch (lhs, rhs) {
        case (profileNotFound, profileNotFound): return true
        case (profileNotMatchingInsuranceId, profileNotMatchingInsuranceId): return true
        case (profileWithInsuranceIdExists, profileWithInsuranceIdExists): return true
        case let (other(error: lhsError), other(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
