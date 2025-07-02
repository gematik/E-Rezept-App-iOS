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
import Nimble
import XCTest

@MainActor
final class CreateProfileDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = TestStoreOf<CreateProfileDomain>

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: CreateProfileDomain.Dummies.state)
    }

    func testStore(for state: CreateProfileDomain.State) -> TestStore {
        TestStore(initialState: state) {
            CreateProfileDomain()
        } withDependencies: { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testSavingProfileWithValidName() async {
        let validName = "Niklas"
        let sut = testStore(
            for: CreateProfileDomain.State(
                profileName: validName
            )
        )

        mockUserProfileService.saveProfilesReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.saveProfilesCalled).to(beFalse())
        await sut.send(.createAndSaveProfile(name: validName))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
        expect(self.mockUserProfileService.saveProfilesCalled).to(beTrue())

        let savedProfile = mockUserProfileService.saveProfilesReceivedProfiles!.first!
        mockUserProfileService.setSelectedProfileIdClosure = { profileId in
            expect(profileId) == savedProfile.id
        }

        await testScheduler.run()
        await sut.receive(.createAndSaveProfileReceived(.success(savedProfile.id)))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beTrue())

        await sut.receive(.delegate(.close))
    }

    func testSavingProfileWithInvalidName() async {
        let invalidName = " "
        let sut = testStore(
            for: CreateProfileDomain.State(
                profileName: invalidName
            )
        )

        await sut.send(.createAndSaveProfile(name: invalidName))
        expect(self.mockUserProfileService.saveProfilesCalled).to(beFalse())
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
    }
}
