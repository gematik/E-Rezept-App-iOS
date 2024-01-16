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

import Combine
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class StandardUserSessionTests: XCTestCase {
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockCurrentProfile: AnyPublisher<Profile, LocalStoreError>!
    var mockProfileDataStore = MockProfileDataStore()

    let idToken: String =
        "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiSldUIiwia2lkIjoicHVrX2lkcF9zaWcifQ.eyJhdF9oYXNoIjoiUzc2aFllak83dHgwMFVuYVpjaEZ0USIsInN1YiI6IlFYWTNRTHZ0OGdfT0F1VmRmV04zbHJWMGE1OEhLNGExTWtJYnZiWmRCb0EiLCJvcmdhbml6YXRpb25OYW1lIjoiVGVzdCBHS1YtU1ZOT1QtVkFMSUQiLCJwcm9mZXNzaW9uT0lEIjoiMS4yLjI3Ni4wLjc2LjQuNDkiLCJpZE51bW1lciI6IlgxMTA0NDM4NzQiLCJhbXIiOlsibWZhIiwic2MiLCJwaW4iXSwiaXNzIjoiaHR0cHM6Ly9pZHAuZGV2LmdlbWF0aWsuc29sdXRpb25zIiwiZ2l2ZW5fbmFtZSI6IkhlaW56IEhpbGxiZXJ0Iiwibm9uY2UiOiI1NTU3NTc3QTc1NzY2MTUzNDciLCJhdWQiOiJlUmV6ZXB0QXBwIiwiYWNyIjoiZ2VtYXRpay1laGVhbHRoLWxvYS1oaWdoIiwiYXpwIjoiZVJlemVwdEFwcCIsImF1dGhfdGltZSI6MTYxOTUxNjk5NCwic2NvcGUiOiJlLXJlemVwdCBvcGVuaWQiLCJleHAiOjE2MTk1MTcyOTQsImlhdCI6MTYxOTUxNjk5NCwiZmFtaWx5X25hbWUiOiJDw7ZyZGVzIiwianRpIjoiZmUwY2QzYTEyMGVlYjRiMyJ9.VYUiZ6cG8-EZyyMu5IV_owIlJ_5oJmRsB66rdILBGxiRGnlj2jX1Oxe_hMPYigL9dD2PwU8sZWOvuA3p1HZE9w" // swiftlint:disable:this line_length

    func idTokenPayload() throws -> TokenPayload.IDTokenPayload {
        let idTokenJWT = try JWT(from: idToken)
        return try idTokenJWT.decodePayload(type: TokenPayload.IDTokenPayload.self)
    }

    func testIDTokenValidator_ProfileNotInStore() throws {
        let sut = MockUserSession()
        let profileIdNotInStore = UUID()
        sut.mockUserDataStore.underlyingSelectedProfileId = Just(profileIdNotInStore).eraseToAnyPublisher()
        sut.mockProfileDataStore.listAllProfilesReturnValue = Just([])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.idTokenValidator()
            .test(
                failure: { error in
                    expect(error) == IDTokenValidatorError.profileNotFound
                }, expectations: { _ in
                    fail("Did not expect to receive a value")
                }
            )
    }

    func testIDTokenValidator_WithMatchingIdToken() throws {
        let idTokenPayload = try idTokenPayload()
        let currentProfile = Profile(name: "CurrentProfile", insuranceId: idTokenPayload.idNummer)
        let otherProfile = Profile(name: "OtherProfile")

        let sut = MockUserSession()
        sut.profileId = currentProfile.id
        sut.mockProfileDataStore.listAllProfilesReturnValue = Just([currentProfile, otherProfile])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        var result: IDTokenValidator?
        sut.idTokenValidator()
            .test(expectations: { profileValidator in
                result = profileValidator
            })
        let expectedResult = try result?.validate(idToken: idTokenPayload).get()
        expect(expectedResult) == true
    }

    func testIDTokenValidator_CreatesExpectedOutput() throws {
        let currentProfile = Profile(name: "CurrentProfile", insuranceId: nil)
        let otherProfile = Profile(name: "OtherProfile")

        let sut = MockUserSession()
        sut.profileId = currentProfile.id
        sut.mockProfileDataStore.listAllProfilesReturnValue = Just([currentProfile, otherProfile])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.idTokenValidator()
            .test(expectations: { idTokenValidator in
                guard let profileValidator = idTokenValidator as? ProfileValidator else {
                    fail("cast should not fail")
                    return
                }
                expect(profileValidator.currentProfile) == currentProfile
                expect(profileValidator.otherProfiles) == [otherProfile]
            })
    }
}
