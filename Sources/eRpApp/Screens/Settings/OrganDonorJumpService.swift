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

import Dependencies
import DependenciesMacros
import eRpKit
import Foundation

@DependencyClient
struct OrganDonorJumpService {
    var jump: @Sendable () async throws -> Void
}

extension DependencyValues {
    var organDonorJumpService: OrganDonorJumpService {
        get { self[OrganDonorJumpService.self] }
        set { self[OrganDonorJumpService.self] = newValue }
    }
}

extension OrganDonorJumpService: TestDependencyKey {
    static var testValue = OrganDonorJumpService()
}

// sourcery: CodedError = "040"
enum OrganDonorJumpServiceError: Swift.Error, Equatable {
    // sourcery: errorCode = "01"
    case fetchingProfile
    // sourcery: errorCode = "02"
    case generatingGenericUrl
    // sourcery: errorCode = "03"
    case openingSpecificUrl
}

extension OrganDonorJumpService: DependencyKey {
    static var liveValue = OrganDonorJumpService {
        @Dependency(\.userDataStore) var userDataStore: UserDataStore
        @Dependency(\.userSession) var userSession: UserSession
        @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

        do {
            for try await userProfile in userSession.profile().first().values {
                let url: URL

                if let organDonationUrl = userDataStore.appConfiguration.organDonationUrl,
                   let idpIss = userProfile.gIdEntry?.identifier {
                    url = organDonationUrl.appending(queryItems: [URLQueryItem(name: "iss", value: idpIss)])
                } else {
                    guard let genericUrl = URL(string: AppConfiguration.Environment
                        .ORGAN_DONATION_REGISTER_FALLBACK_PU) else {
                        throw OrganDonorJumpServiceError.generatingGenericUrl
                    }
                    url = genericUrl
                }
                guard resourceHandler.canOpenURL(url) else {
                    throw OrganDonorJumpServiceError.openingSpecificUrl
                }
                Task { @MainActor in
                    resourceHandler.open(url)
                }
            }
        } catch let error as OrganDonorJumpServiceError {
            throw error
        } catch {
            throw OrganDonorJumpServiceError.fetchingProfile
        }
    }
}
