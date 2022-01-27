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
@testable import eRpApp

// MARK: - MockUserProfileService -

final class MockUserProfileService: UserProfileService {
    // MARK: - userProfilesPublisher

    var userProfilesPublisherCallsCount = 0
    var userProfilesPublisherCalled: Bool {
        userProfilesPublisherCallsCount > 0
    }

    var userProfilesPublisherReturnValue: AnyPublisher<[UserProfile], UserProfileServiceError>!
    var userProfilesPublisherClosure: (() -> AnyPublisher<[UserProfile], UserProfileServiceError>)?

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        userProfilesPublisherCallsCount += 1
        return userProfilesPublisherClosure.map { $0() } ?? userProfilesPublisherReturnValue
    }

    // MARK: - activeUserProfilePublisher

    var activeUserProfilePublisherCallsCount = 0
    var activeUserProfilePublisherCalled: Bool {
        activeUserProfilePublisherCallsCount > 0
    }

    var activeUserProfilePublisherReturnValue: AnyPublisher<UserProfile, UserProfileServiceError>!
    var activeUserProfilePublisherClosure: (() -> AnyPublisher<UserProfile, UserProfileServiceError>)?

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        activeUserProfilePublisherCallsCount += 1
        return activeUserProfilePublisherClosure.map { $0() } ?? activeUserProfilePublisherReturnValue
    }
}
