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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

@MainActor
final class EditProfilePictureDomainTest: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = TestStoreOf<EditProfilePictureDomain>

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: EditProfilePictureDomain.Dummies.state)
    }

    func testStore(for state: EditProfilePictureDomain.State) -> TestStore {
        TestStore(initialState: state) {
            EditProfilePictureDomain()
        } withDependencies: { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testEditProfilePictureColor() async {
        let sut = testStore(
            for: EditProfilePictureDomain.State(
                profileId: Fixtures.profileA.id
            )
        )

        mockUserProfileService.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        await sut.send(.editColor(.blue)) { state in
            state.color = .blue
        }
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        await testScheduler.run()
        await sut.receive(.updateProfileReceived(.success(true)))
    }

    func testEditProfilePictureImage() async {
        let sut = testStore(
            for: EditProfilePictureDomain.State(
                profileId: Fixtures.profileA.id
            )
        )

        mockUserProfileService.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        await sut.send(.editPicture(.boyWithCard)) { state in
            state.picture = .boyWithCard
        }
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        await testScheduler.run()
        await sut.receive(.updateProfileReceived(.success(true)))
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
