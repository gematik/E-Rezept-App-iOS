//
//  Copyright (c) 2022 gematik GmbH
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

final class EditProfileDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        EditProfileDomain.State,
        EditProfileDomain.State,
        EditProfileDomain.Action,
        EditProfileDomain.Action,
        EditProfileDomain.Environment
    >

    func testStore(for state: EditProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: EditProfileDomain.reducer,
            environment: EditProfileDomain.Environment(
                schedulers: Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler()),
                profileDataStore: mockProfileDataStore,
                userDataStore: mockUserDataStore,
                profileSecureDataWiper: mockProfileSecureDataWiper,
                router: mockRouting
            )
        )
    }

    let mainQueue = DispatchQueue.test

    var mockProfileDataStore: MockProfileDataStore!
    var mockUserDataStore: MockUserDataStore!
    var mockProfileSecureDataWiper: MockProfileSecureDataWiper!
    var mockRouting: MockRouting!

    override func setUp() {
        super.setUp()

        mockProfileDataStore = MockProfileDataStore()
        mockUserDataStore = MockUserDataStore()
        mockProfileSecureDataWiper = MockProfileSecureDataWiper()
        mockRouting = MockRouting()
    }

    func testSavingAnEmptyNameDisplaysError() {
        let sut = testStore(for: Fixtures.profileA)

        sut.send(.setName("")) { state in
            state.name = ""
            state.acronym = ""

            let showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0

            expect(showEmptyNameWarning).to(beTrue())
        }
    }

    func testSavingAnAlteredName() {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.setName("Anna Vette")) { state in
            state.name = "Anna Vette"

            let showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0
            expect(showEmptyNameWarning).to(beFalse())
        }

        mainQueue.run()

        sut.receive(.updateResultReceived(.success(true)))

        expect(self.mockProfileDataStore.updateProfileIdMutatingCallsCount).to(equal(1))
    }

    func testSavingEmoji() {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.setEmoji("👵🏻")) { state in
            state.emoji = "👵🏻"
        }

        mainQueue.run()
        sut.receive(.updateResultReceived(.success(true)))

        sut.send(.setEmoji(nil)) { state in
            state.emoji = nil
        }

        mainQueue.run()
        sut.receive(.updateResultReceived(.success(true)))

        expect(self.mockProfileDataStore.updateProfileIdMutatingCallsCount).to(equal(2))
    }

    func testSavingColor() {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.setColor(.green)) { state in
            state.color = .green
        }

        mainQueue.run()
        sut.receive(.updateResultReceived(.success(true)))

        sut.send(.setColor(.blue)) { state in
            state.color = .blue
        }

        mainQueue.run()
        sut.receive(.updateResultReceived(.success(true)))

        expect(self.mockProfileDataStore.updateProfileIdMutatingCallsCount).to(equal(2))
    }

    func testSavingFailsDisplaysAlert() {
        let sut = testStore(for: Fixtures.profileA)

        let error = LocalStoreError.notImplemented

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Fail(error: error)
            .eraseToAnyPublisher()

        sut.send(.setColor(.green)) { state in
            state.color = .green
        }

        mainQueue.run()
        sut.receive(.updateResultReceived(.failure(LocalStoreError.notImplemented))) { state in
            state.route = .alert(EditProfileDomain.AlertStates.for(error))
        }
    }

    func testDismissAlert() {
        let sut = testStore(for: Fixtures.profileWithAlert)

        sut.send(.dismissAlert) { state in
            state.route = nil
        }
    }

    func testDeletionShowsConfirmationDialog() {
        let sut = testStore(for: Fixtures.profileA)

        // Should show a confirmation dialog
        sut.send(.delete) { state in
            state.route = .alert(EditProfileDomain.AlertStates.deleteProfile)
        }
    }

    func testDeleteConfirmationDialogConfirm() {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        mockProfileDataStore.listAllProfilesReturnValue = Just(
            [
                Fixtures.erxProfile,
                ProfilesDomainTests.Fixtures.erxProfileA,
                ProfilesDomainTests.Fixtures.erxProfileB,
            ]
        )
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()

        mockUserDataStore.selectedProfileId = Just(nil).eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // Should show a confirmation dialog
        sut.send(.confirmDelete)

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfReceivedInvocations)
            .to(equal([Fixtures.erxProfile.id]))
        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))

        mainQueue.run()

        sut.receive(.close)
    }

    func testDeleteConfirmationDialogCancel() {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        // Should show a confirmation dialog
        sut.send(.dismissAlert) { state in
            state.route = nil
        }
    }

    func testDeleteUpdatesSelectedProfile() {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        mockProfileDataStore.listAllProfilesReturnValue = Just(
            [
                Fixtures.erxProfile,
                ProfilesDomainTests.Fixtures.erxProfileA,
                ProfilesDomainTests.Fixtures.erxProfileB,
            ]
        )
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileWithDeleteConfirmation.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        // Should show a confirmation dialog
        sut.send(.confirmDelete)

        mainQueue.run()

        sut.receive(.close)

        expect(self.mockUserDataStore.setSelectedProfileIdCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testDeleteLastProfileCreatesANewOne() {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        let listProfilesPublisher: PassthroughSubject<[Profile], LocalStoreError> = PassthroughSubject()
        mockProfileDataStore.listAllProfilesReturnValue = listProfilesPublisher.eraseToAnyPublisher()
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileWithDeleteConfirmation.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        // Should show a confirmation dialog
        sut.send(.confirmDelete)

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beFalse())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile])

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile, ProfilesDomainTests.Fixtures.erxProfileA])

        mainQueue.run()

        sut.receive(.close)

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beTrue())

        expect(self.mockUserDataStore.setSelectedProfileIdCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testListenerUpdatesSetTokenAndProfile() {
        let sut = testStore(for: Fixtures.profileA)

        let fetchProfileByPublisher: AnyPublisher<Profile?, LocalStoreError> = CurrentValueSubject(Fixtures
            .erxProfileWithTokenAndDetails)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
        mockProfileDataStore.fetchProfileByReturnValue = fetchProfileByPublisher

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.set(token: Fixtures.token)
        mockProfileSecureDataWiper.secureStorageReturnValue = mockSecureUserStore

        sut.send(.registerListener)

        mainQueue.run()

        sut.receive(.tokenReceived(Fixtures.token)) {
            $0.token = Fixtures.token
        }

        sut.receive(.profileReceived(.success(Fixtures.erxProfileWithTokenAndDetails))) {
            $0.insuranceId = Fixtures.erxProfileWithTokenAndDetails.insuranceId
            $0.insurance = Fixtures.erxProfileWithTokenAndDetails.insurance
            $0.fullName = Fixtures.erxProfileWithTokenAndDetails.fullName
        }

        expect(self.mockProfileSecureDataWiper.secureStorageCalled).to(beTrue())
        expect(self.mockProfileDataStore.fetchProfileByCalled).to(beTrue())

        sut.send(.close)
    }
}

extension EditProfileDomainTests {
    enum Fixtures {
        static let uuid = UUID()
        static let createdA = Date()

        static let token = IDPToken(accessToken: "", expires: Date(), idToken: "")

        static let profileA = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            token: token
        )

        static let profileWithAlert = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            route: .alert(EditProfileDomain.AlertStates.for(LocalStoreError.notImplemented))
        )

        static let profileWithDeleteConfirmation = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            token: token,
            route: .alert(EditProfileDomain.AlertStates.deleteProfile)
        )

        static let erxProfile = Profile(
            name: "Anna Vetter",
            identifier: uuid,
            created: createdA,
            insuranceId: nil,
            color: .red,
            emoji: nil,
            lastAuthenticated: nil,
            erxTasks: [],
            erxAuditEvents: []
        )

        static let erxProfileWithTokenAndDetails = Profile(
            name: "Anna Vetter",
            identifier: uuid,
            created: createdA,
            givenName: "Anna Regina",
            familyName: "Vetter",
            insurance: "Generic BKK",
            insuranceId: "X987654321",
            color: .red,
            erxTasks: [],
            erxAuditEvents: []
        )
    }
}
