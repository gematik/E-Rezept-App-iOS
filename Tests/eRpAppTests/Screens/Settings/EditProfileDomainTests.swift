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
import FeatureCardWall
import FeatureHelpers
import IDP
import Nimble
import TestUtils
import XCTest

@MainActor
final class EditProfileDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<EditProfileDomain>

    func testStore(for state: EditProfileDomain.State) -> TestStore {
        TestStore(initialState: state) {
            EditProfileDomain()
        } withDependencies: { dependencies in
            dependencies.appSecurityManager = mockAppSecurityManager
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
            dependencies.userSessionProvider = mockUserSessionProvider
            dependencies.changeableUserSessionContainer = mockUsersSessionContainer
            dependencies.profileSecureDataWiper = mockProfileSecureDataWiper
            dependencies.profileDataStore = mockProfileDataStore
            dependencies.userDataStore = mockUserDataStore
            dependencies.router = mockRouting
        }
    }

    let mainQueue = DispatchQueue.immediate

    var mockUsersSessionContainer: UsersSessionContainerMock!
    var mockAppSecurityManager: AppSecurityManagerMock!
    var mockUserSession: MockUserSession!
    var mockProfileDataStore: ProfileDataStoreMock!
    var mockUserDataStore: UserDataStoreMock!
    var mockProfileSecureDataWiper: ProfileSecureDataWiperMock!
    var mockRouting: RoutingMock!
    var mockUserSessionProvider: UserSessionProviderMock!
    var mockSecureEnclaveSignatureProvider: SecureEnclaveSignatureProviderMock!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = AppSecurityManagerMock()
        mockUserSession = MockUserSession()
        mockProfileDataStore = ProfileDataStoreMock()
        mockUserDataStore = UserDataStoreMock()
        mockProfileSecureDataWiper = ProfileSecureDataWiperMock()
        mockRouting = RoutingMock()
        mockUserSessionProvider = UserSessionProviderMock()
        mockSecureEnclaveSignatureProvider = SecureEnclaveSignatureProviderMock()
        mockUsersSessionContainer = UsersSessionContainerMock()
    }

    func testSavingAnEmptyNameDisplaysError() async {
        let sut = testStore(for: Fixtures.profileA)

        await sut.send(\.binding.name, "") { state in
            state.name = ""
            state.acronym = ""

            let showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0

            expect(showEmptyNameWarning).to(beTrue())
        }
    }

    func testSavingAnAlteredName() async {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore
            .updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(\.binding.name, "Anna Vette") { state in
            state.name = "Anna Vette"

            let showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0
            expect(showEmptyNameWarning).to(beFalse())
        }

        await sut.receive(.response(.updateProfileReceived(.success(true))))

        expect(self.mockProfileDataStore
            .updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount).to(equal(1))
    }

    func testSavingColor() async {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore
            .updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(\.binding.color, .green) { state in
            state.color = .green
        }

        await sut.receive(.response(.updateProfileReceived(.success(true))))

        await sut.send(\.binding.color, .blue) { state in
            state.color = .blue
        }

        await sut.receive(.response(.updateProfileReceived(.success(true))))

        expect(self.mockProfileDataStore
            .updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount).to(equal(2))
    }

    func testSavingFailsDisplaysAlert() async {
        let sut = testStore(for: Fixtures.profileA)

        let error = LocalStoreError.notImplemented

        mockProfileDataStore
            .updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue =
            Fail(error: error)
                .eraseToAnyPublisher()

        await sut.send(\.binding.color, .green) { state in
            state.color = .green
        }

        await sut.receive(.response(.updateProfileReceived(.failure(LocalStoreError.notImplemented)))) { state in
            state.destination = .alert(.init(for: error))
        }
    }

    func testDismissAlert() async {
        let sut = testStore(for: Fixtures.profileWithAlert)

        await sut.send(.destination(.dismiss)) { state in
            state.destination = nil
        }
    }

    func testShowDeleteProfileConfirmationDialog() async {
        let sut = testStore(for: Fixtures.profileA)

        // Should show a confirmation dialog
        await sut.send(.showDeleteProfileAlert) { state in
            state.destination = .alert(EditProfileDomain.AlertStates.deleteProfile)
        }
    }

    func testDeleteProfileConfirmationDialogConfirm() async {
        mockUsersSessionContainer.userSession = mockUserSession
        mockUserSession.mockUserDataStore = mockUserDataStore

        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        mockProfileDataStore.listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue = Just(
            [
                Fixtures.erxProfile,
                ProfilesDomainTests.Fixtures.erxProfileA,
                ProfilesDomainTests.Fixtures.erxProfileB,
            ]
        )
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()

        mockUserDataStore.selectedProfileId = Just(nil).eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue = Just(())
            .eraseToAnyPublisher()

        // Should show a confirmation dialog
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReceivedInvocations)
            .to(equal([Fixtures.erxProfile.id]))
        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount)
            .to(equal(1))

        await sut.receive(.delegate(.close))
    }

    func testDeleteProfileConfirmationDialogCancel() async {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        // Should show a confirmation dialog
        await sut.send(.destination(.dismiss)) { state in
            state.destination = nil
        }
    }

    func testDeletingProfileUpdatesSelectedProfile() async {
        mockUsersSessionContainer.userSession = mockUserSession
        mockUserSession.mockUserDataStore = mockUserDataStore

        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        mockProfileDataStore.listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue = Just(
            [
                Fixtures.erxProfile,
                ProfilesDomainTests.Fixtures.erxProfileA,
                ProfilesDomainTests.Fixtures.erxProfileB,
            ]
        )
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue = Just(())
            .eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileWithDeleteConfirmation.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        // Should show a confirmation dialog
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        await sut.receive(.delegate(.close))

        expect(self.mockUserDataStore.setSelectedProfileIdUUIDVoidCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdUUIDVoidReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testDeleteLastProfileCreatesANewOne() async {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        mockUsersSessionContainer.userSession = mockUserSession
        mockUserSession.mockUserDataStore = mockUserDataStore

        let listProfilesPublisher: PassthroughSubject<[Profile], LocalStoreError> = PassthroughSubject()
        mockProfileDataStore.listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue = listProfilesPublisher
            .eraseToAnyPublisher()
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue = Just(())
            .eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileWithDeleteConfirmation.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.saveProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        // Should show a confirmation dialog
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        expect(self.mockProfileDataStore.saveProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beFalse())
        expect(self.mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile])

        expect(self.mockProfileDataStore.saveProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile, ProfilesDomainTests.Fixtures.erxProfileA])

        await sut.receive(.delegate(.close))

        expect(self.mockProfileDataStore.saveProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCalled).to(beTrue())

        expect(self.mockUserDataStore.setSelectedProfileIdUUIDVoidCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdUUIDVoidReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testListenerUpdatesSetTokenAndProfile() async {
        let sut = testStore(for: Fixtures.profileA)
        sut.dependencies.consentService = .previewValue

        let fetchProfileByPublisher: AnyPublisher<Profile?, LocalStoreError> = Just(Fixtures
            .erxProfileWithTokenAndDetails)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockProfileDataStore
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue =
            fetchProfileByPublisher

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        mockProfileSecureDataWiper.secureStorageOfProfileIdUUIDSecureUserDataStoreReturnValue = mockSecureUserStore
        let mockUserSession = MockUserSession()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSessionProvider.userSessionForUuidUUIDUserSessionReturnValue = mockUserSession

        await sut.send(.task)

        await sut.receive(.response(.tokenReceived(Fixtures.token)))

        await sut.receive(.response(.canReceived(Fixtures.can))) {
            $0.can = Fixtures.can
        }

        await sut.receive(.response(.profileReceived(.success(Fixtures.erxProfileWithTokenAndDetails)))) {
            $0.insuranceId = Fixtures.erxProfileWithTokenAndDetails.insuranceId
            $0.insurance = Fixtures.erxProfileWithTokenAndDetails.insurance
            $0.fullName = Fixtures.erxProfileWithTokenAndDetails.fullName
        }

        await sut.receive(.response(.euConsentCheckReceived(.success(.granted)))) {
            $0.euRedeemConsentCheck = .granted
        }

        expect(self.mockUserSessionProvider.userSessionForUuidUUIDUserSessionCalled).to(beTrue())
        expect(self.mockProfileDataStore.fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCalled)
            .to(beTrue())

        await sut.send(.delegate(.close))
    }

    func testReloginProfileDeletesTokenAndOpensCardWall() async {
        mockUsersSessionContainer.userSession = mockUserSession
        mockUserSession.mockUserDataStore = mockUserDataStore

        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore
            .listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue =
            Just([ProfilesDomainTests.Fixtures.erxProfileA])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue = Just(())
            .eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.relogin) {
            $0.token = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount)
            .to(equal(1))
        await sut.receive(.showCardWall) {
            $0.destination = .cardWall(.init(isNFCReady: true, profileId: Fixtures.uuid))
        }
    }

    func testLogoutProfileDeletesToken() async {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore
            .listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue =
            Just([ProfilesDomainTests.Fixtures.erxProfileA])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue = Just(())
            .eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.profileId)
            .eraseToAnyPublisher()
        mockUserSessionProvider.userSessionForUuidUUIDUserSessionReturnValue = mockUserSession
        mockProfileDataStore.deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.delegate(.logout)) {
            $0.token = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount)
            .to(equal(1))
    }
}

extension EditProfileDomainTests {
    enum Fixtures {
        static let uuid = UUID()
        static let createdA = Date()

        static let token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "redirect")
        static let can = "123132"
        static let keyIdentifier = Data("1234567890".utf8)

        static let profileA = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
            insuranceId: nil,
            image: ProfilePicture.none,
            userImageData: nil,
            color: .red,
            profileId: uuid,
            token: token
        )

        static let profileWithAlert = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
            insuranceId: nil,
            image: ProfilePicture.none,
            userImageData: nil,
            color: .red,
            profileId: uuid,
            destination: .alert(.init(for: LocalStoreError.notImplemented))
        )

        static let profileWithDeleteConfirmation = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
            insuranceId: nil,
            image: ProfilePicture.none,
            userImageData: nil,
            color: .red,
            profileId: uuid,
            token: token,
            destination: .alert(EditProfileDomain.AlertStates.deleteProfile)
        )

        static let erxProfile = Profile(
            name: "Anna Vetter",
            identifier: uuid,
            created: createdA,
            insuranceId: nil,
            color: .red,
            lastAuthenticated: nil,
            erxTasks: []
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
            erxTasks: []
        )
    }
}
