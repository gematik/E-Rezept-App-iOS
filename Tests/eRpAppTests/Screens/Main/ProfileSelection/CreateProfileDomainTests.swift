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
import Nimble
import XCTest

final class CreateProfileDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = ComposableArchitecture.TestStore<
        CreateProfileDomain.State,
        CreateProfileDomain.Action,
        CreateProfileDomain.State,
        CreateProfileDomain.Action,
        Void
    >

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: CreateProfileDomain.Dummies.state)
    }

    func testStore(for state: CreateProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: CreateProfileDomain()
        ) { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testSavingProfileWithValidName() {
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
        sut.send(.createAndSaveProfile(name: validName))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
        expect(self.mockUserProfileService.saveProfilesCalled).to(beTrue())

        let savedProfile = mockUserProfileService.saveProfilesReceivedProfiles!.first!
        mockUserProfileService.setSelectedProfileIdClosure = { profileId in
            expect(profileId) == savedProfile.id
        }

        testScheduler.run()
        sut.receive(.createAndSaveProfileReceived(.success(savedProfile.id)))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beTrue())

        sut.receive(.delegate(.close))
    }

    func testSavingProfileWithInvalidName() {
        let invalidName = " "
        let sut = testStore(
            for: CreateProfileDomain.State(
                profileName: invalidName
            )
        )

        sut.send(.createAndSaveProfile(name: invalidName))
        expect(self.mockUserProfileService.saveProfilesCalled).to(beFalse())
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
    }
}
