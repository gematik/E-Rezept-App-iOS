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

@MainActor
final class EditProfileNameDomainTest: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = TestStoreOf<EditProfileNameDomain>

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: EditProfileNameDomain.Dummies.state)
    }

    func testStore(for state: EditProfileNameDomain.State) -> TestStore {
        TestStore(initialState: state) {
            EditProfileNameDomain()
        } withDependencies: { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testEditProfileNameWithValidName() async {
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
        await sut.send(.saveEditedProfileName(name: "Crazy Niklas"))
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beTrue())

        await testScheduler.run()
        await sut.receive(.saveEditedProfileNameReceived(.success(true)))
        await sut.receive(.delegate(.close))
    }

    func testEditProfileNameWithInvalidName() async {
        let invalidName = " "
        let sut = testStore(
            for: EditProfileNameDomain.State(
                profileName: invalidName,
                profileId: Fixtures.profileA.id
            )
        )

        await sut.send(.saveEditedProfileName(name: invalidName))
        expect(self.mockUserProfileService.updateProfileIdMutatingCalled).to(beFalse())
        await sut.receive(.delegate(.close))
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
