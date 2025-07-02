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
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import TestUtils
import XCTest

final class DefaultProfileSecureDataWiperTests: XCTestCase {
    let mockUserSessionProvider = MockUserSessionProvider()

    func testwipingData() async throws {
        let mockIDPSession = IDPSessionMock()
        let mockSecureUserStore = MockSecureUserDataStore()
        let mockUserSession = MockUserSession(idpSession: mockIDPSession, secureUserStore: mockSecureUserStore)
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()

        let sut = DefaultProfileSecureDataWiper(userSessionProvider: mockUserSessionProvider)

        try await sut.wipeSecureData(of: UUID()).async()

        expect(self.mockUserSessionProvider.userSessionForCalled).to(beTrue())
        expect(mockSecureUserStore.wipeCalled).to(beTrue())
        expect(mockSecureUserStore.setKeyIdentifierCalled).to(beTrue())
        expect(mockIDPSession.invalidateAccessToken_Called).to(beTrue())
        expect(mockSecureUserStore.setKeyIdentifierCalled).to(beTrue())
    }
}
