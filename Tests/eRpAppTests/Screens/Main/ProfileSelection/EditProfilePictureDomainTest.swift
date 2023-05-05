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

final class EditProfilePictureDomainTest: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = ComposableArchitecture.TestStore<
        EditProfilePictureDomain.State,
        EditProfilePictureDomain.Action,
        EditProfilePictureDomain.State,
        EditProfilePictureDomain.Action,
        Void
    >

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: EditProfilePictureDomain.Dummies.state)
    }

    func testStore(for state: EditProfilePictureDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: EditProfilePictureDomain()
        ) { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testEditProfilePictureColor() {
        let sut = testStore(
            for: EditProfilePictureDomain.State(
                profile: Fixtures.profileA
            )
        )

        mockUserProfileService.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        sut.send(.editColor(.blue)) { state in
            state.color = .blue
        }
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        testScheduler.run()
        sut.receive(.updateProfileReceived(.success(true)))
    }

    func testEditProfilePictureImage() {
        let sut = testStore(
            for: EditProfilePictureDomain.State(
                profile: Fixtures.profileA
            )
        )

        mockUserProfileService.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        sut.send(.editPicture(.boyWithCard)) { state in
            state.picture = .boyWithCard
        }
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        testScheduler.run()
        sut.receive(.updateProfileReceived(.success(true)))
    }
}

extension EditProfilePictureDomainTest {
    enum Fixtures {
        static let token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "redirect")

        static let profileA = UserProfile(from: Profile(
            name: "Anna Vetter",
            identifier: UUID(),
            created: Date(),
            insuranceId: nil,
            color: .red,
            image: .none,
            lastAuthenticated: nil,
            erxTasks: []
        ),
        token: token)
    }
}
