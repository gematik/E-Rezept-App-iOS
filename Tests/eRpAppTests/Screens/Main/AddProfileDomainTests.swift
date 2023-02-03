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

final class AddProfileDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var mockUserProfileService: MockUserProfileService!

    typealias TestStore = ComposableArchitecture.TestStore<
        AddProfileDomain.State,
        AddProfileDomain.Action,
        AddProfileDomain.State,
        AddProfileDomain.Action,
        AddProfileDomain.Environment
    >

    override func setUp() {
        super.setUp()

        mockUserProfileService = MockUserProfileService()
    }

    func testStore() -> TestStore {
        testStore(for: AddProfileDomain.Dummies.state)
    }

    func testStore(for state: AddProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: AddProfileDomain.reducer,
            environment: AddProfileDomain.Environment(
                userProfileService: mockUserProfileService,
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            )
        )
    }

    func testSavingProfileWithValidName() {
        let validName = "Niklas"
        let sut = testStore(
            for: AddProfileDomain.State(
                alertState: nil,
                profileName: validName
            )
        )

        mockUserProfileService.saveProfilesReturnValue = Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        expect(self.mockUserProfileService.saveProfilesCalled).to(beFalse())
        sut.send(.saveProfile(validName))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
        expect(self.mockUserProfileService.saveProfilesCalled).to(beTrue())

        let savedProfile = mockUserProfileService.saveProfilesReceivedProfiles!.first!
        mockUserProfileService.setSelectedProfileIdClosure = { profileId in
            expect(profileId) == savedProfile.id
        }

        testScheduler.run()
        sut.receive(.saveProfileReceived(.success(savedProfile.id)))
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beTrue())

        sut.receive(.close)
    }

    func testSavingProfileWithInvalidName() {
        let invalidName = " "
        let sut = testStore(
            for: AddProfileDomain.State(
                alertState: nil,
                profileName: invalidName
            )
        )

        sut.send(.saveProfile(invalidName))
        expect(self.mockUserProfileService.saveProfilesCalled).to(beFalse())
        expect(self.mockUserProfileService.setSelectedProfileIdCalled).to(beFalse())
    }
}
