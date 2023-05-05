//
//  Copyright (c) 2023 gematik GmbH
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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class EditProfileNameDomainTest: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = ComposableArchitecture.TestStore<
        EditProfileNameDomain.State,
        EditProfileNameDomain.Action,
        EditProfileNameDomain.State,
        EditProfileNameDomain.Action,
        Void
    >

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: EditProfileNameDomain.Dummies.state)
    }

    func testStore(for state: EditProfileNameDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: EditProfileNameDomain()
        ) { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testEditProfileNameWithValidName() {
        let validName = "Niklas"
        let sut = testStore(
            for: EditProfileNameDomain.State(
                profileName: validName,
                profileId: Fixtures.profileA.id
            )
        )

        mockUserProfileService.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        sut.send(.saveEditedProfileName(name: "Crazy Niklas"))
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        testScheduler.run()
        sut.receive(.saveEditedProfileNameReceived(.success(true)))
        sut.receive(.delegate(.close))
    }

    func testEditProfileNameWithInvalidName() {
        let invalidName = " "
        let sut = testStore(
            for: EditProfileNameDomain.State(
                profileName: invalidName,
                profileId: Fixtures.profileA.id
            )
        )

        sut.send(.saveEditedProfileName(name: invalidName))
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        sut.receive(.delegate(.close))
    }
}

extension EditProfileNameDomainTest {
    enum Fixtures {
        static let token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "redirect")

        static let profileA = UserProfile(from: Profile(
            name: "Anna Vetter",
            identifier: UUID(),
            created: Date(),
            insuranceId: nil,
            color: .red,
            lastAuthenticated: nil,
            erxTasks: []
        ),
        token: token)
    }
}
