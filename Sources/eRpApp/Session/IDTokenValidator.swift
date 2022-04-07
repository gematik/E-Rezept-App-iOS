//
//  Copyright (c) 2022 gematik GmbH
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

import Combine
import eRpKit
import Foundation
import IDP

protocol IDTokenValidator {
    func validate(idToken: TokenPayload.IDTokenPayload) -> Result<Bool, Error>
}

enum IDTokenValidatorError: Error, LocalizedError, Equatable {
    case profileNotFound
    case profileNotMatchingInsuranceId(String?)
    case profileWithInsuranceIdExists(String)
    case other(error: Swift.Error)

    var errorDescription: String? {
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

    static func ==(lhs: IDTokenValidatorError, rhs: IDTokenValidatorError) -> Bool {
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

struct ProfileValidator: IDTokenValidator {
    let currentProfile: Profile
    let otherProfiles: [Profile]

    func validate(idToken: TokenPayload.IDTokenPayload) -> Result<Bool, Error> {
        guard idToken.idNummer == currentProfile.insuranceId || currentProfile.insuranceId == nil else {
            return .failure(IDTokenValidatorError.profileNotMatchingInsuranceId(currentProfile.insuranceId))
        }

        if let profile = otherProfiles.first(where: { $0.insuranceId == idToken.idNummer }) {
            return .failure(IDTokenValidatorError.profileWithInsuranceIdExists(profile.name))
        }

        return .success(true)
    }
}

extension UserSession {
    func idTokenValidator() -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        profileDataStore.listAllProfiles()
            .first()
            .mapError(IDTokenValidatorError.other(error:))
            .flatMap { [profileId = profileId] profiles -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> in
                guard let currentProfile = profiles.first(where: { $0.identifier == profileId }) else {
                    return Fail(error: IDTokenValidatorError.profileNotFound).eraseToAnyPublisher()
                }
                let otherProfiles = profiles.filter { $0.identifier != profileId }
                return Just(
                    ProfileValidator(
                        currentProfile: currentProfile,
                        otherProfiles: otherProfiles
                    )
                )
                .setFailureType(to: IDTokenValidatorError.self)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
