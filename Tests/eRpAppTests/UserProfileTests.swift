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

import Combine
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

final class UserProfileTests: XCTestCase {
    func testUserProfileConnectionStatus() {
        let validTokenAndValidSSOToken = UserProfile(from: UserProfileTests.profile,
                                                     token: UserProfileTests.IDPTokenWithValidSSO)

        let validTokenAndExpiredSSOToken = UserProfile(from: UserProfileTests.profile,
                                                       token: UserProfileTests.IDPTokenWithExpiredSSO)

        let validTokenAndNoSSOToken = UserProfile(from: UserProfileTests.profile, token: IDPToken.Fixtures.valid)

        let expiredTokenAndOnceAuth = UserProfile(from: UserProfileTests.profile, token: IDPToken.Fixtures.inValid)

        let neverConnected = UserProfile(from: UserProfileTests.profileNoAuthenticated, token: nil)

        expect(validTokenAndValidSSOToken.connectionStatus) == ProfileConnectionStatus.connected

        expect(validTokenAndExpiredSSOToken.connectionStatus) == ProfileConnectionStatus.disconnected

        expect(validTokenAndNoSSOToken.connectionStatus) == ProfileConnectionStatus.connected

        expect(expiredTokenAndOnceAuth.connectionStatus) == ProfileConnectionStatus.disconnected

        expect(neverConnected.connectionStatus) == ProfileConnectionStatus.never
    }
}

extension UserProfileTests {
    static var profile: Profile = .init(name: "YesterDay", lastAuthenticated: Date())
    static var profileNoAuthenticated: Profile = .init(name: "Newer User")

    static let ssoTokenHeaderFuture: String = {
        "eyJlbmMiOiJBMjU2R0NNIiwiY3R5IjoiTkpXVCIsImV4cCI6NTYxODQ5MjE0MSwiYWxnIjoiZGlyIiwia2lkIjoiMDAwMSJ9"
    }()

    static let ssoTokenHeaderExpired: String = {
        "eyJlbmMiOiJBMjU2R0NNIiwiY3R5IjoiTkpXVCIsImV4cCI6MTYxODQ5MjE0MSwiYWxnIjoiZGlyIiwia2lkIjoiMDAwMSJ9"
    }()

    static let IDPTokenWithValidSSO = IDPToken(
        accessToken: "abs",
        expires: Date(),
        idToken: "token",
        ssoToken: ssoTokenHeaderFuture,
        redirect: "redirect"
    )

    static let IDPTokenWithExpiredSSO = IDPToken(
        accessToken: "abs",
        expires: Date(),
        idToken: "token",
        ssoToken: ssoTokenHeaderExpired,
        redirect: "redirect"
    )
}
