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
import TestUtils
import XCTest

final class EditProfileDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        EditProfileDomain.State,
        EditProfileDomain.Action,
        EditProfileDomain.State,
        EditProfileDomain.Action,
        EditProfileDomain.Environment
    >

    func testStore(for state: EditProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: EditProfileDomain.reducer,
            environment: EditProfileDomain.Environment(
                appSecurityManager: mockAppSecurityManager,
                schedulers: Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler()),
                profileDataStore: mockProfileDataStore,
                userDataStore: mockUserDataStore,
                profileSecureDataWiper: mockProfileSecureDataWiper,
                router: mockRouting,
                userSession: MockUserSession(),
                userSessionProvider: mockUserSessionProvider,
                secureEnclaveSignatureProvider: mockSecureEnclaveSignatureProvider,
                nfcSignatureProvider: mockSignatureProvider,
                signatureProvider: DummySecureEnclaveSignatureProvider(),
                accessibilityAnnouncementReceiver: { _ in }
            )
        )
    }

    let mainQueue = DispatchQueue.immediate

    var mockAppSecurityManager: MockAppSecurityManager!
    var mockProfileDataStore: MockProfileDataStore!
    var mockUserDataStore: MockUserDataStore!
    var mockProfileSecureDataWiper: MockProfileSecureDataWiper!
    var mockRouting: MockRouting!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockSignatureProvider: MockNFCSignatureProvider!
    var mockSecureEnclaveSignatureProvider: MockSecureEnclaveSignatureProvider!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockProfileDataStore = MockProfileDataStore()
        mockUserDataStore = MockUserDataStore()
        mockProfileSecureDataWiper = MockProfileSecureDataWiper()
        mockRouting = MockRouting()
        mockUserSessionProvider = MockUserSessionProvider()
        mockSignatureProvider = MockNFCSignatureProvider()
        mockSecureEnclaveSignatureProvider = MockSecureEnclaveSignatureProvider()
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

        sut.receive(.updateProfileReceived(.success(true)))

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

        sut.receive(.updateProfileReceived(.success(true)))

        sut.send(.setEmoji(nil)) { state in
            state.emoji = nil
        }

        sut.receive(.updateProfileReceived(.success(true)))

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

        sut.receive(.updateProfileReceived(.success(true)))

        sut.send(.setColor(.blue)) { state in
            state.color = .blue
        }

        sut.receive(.updateProfileReceived(.success(true)))

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

        sut.receive(.updateProfileReceived(.failure(LocalStoreError.notImplemented))) { state in
            state.route = .alert(.init(for: error))
        }
    }

    func testDismissAlert() {
        let sut = testStore(for: Fixtures.profileWithAlert)

        sut.send(.dismissAlert) { state in
            state.route = nil
        }
    }

    func testShowDeleteProfileConfirmationDialog() {
        let sut = testStore(for: Fixtures.profileA)

        // Should show a confirmation dialog
        sut.send(.showDeleteProfileAlert) { state in
            state.route = .alert(EditProfileDomain.AlertStates.deleteProfile)
        }
    }

    func testDeleteProfileConfirmationDialogConfirm() {
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
        sut.send(.confirmDeleteProfile)

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfReceivedInvocations)
            .to(equal([Fixtures.erxProfile.id]))
        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))

        sut.receive(.close)
    }

    func testDeleteProfileConfirmationDialogCancel() {
        let sut = testStore(for: Fixtures.profileWithDeleteConfirmation)

        // Should show a confirmation dialog
        sut.send(.dismissAlert) { state in
            state.route = nil
        }
    }

    func testDeletingProfileUpdatesSelectedProfile() {
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
        sut.send(.confirmDeleteProfile)

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
        sut.send(.confirmDeleteProfile)

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beFalse())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile])

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile, ProfilesDomainTests.Fixtures.erxProfileA])

        sut.receive(.close)

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beTrue())

        expect(self.mockUserDataStore.setSelectedProfileIdCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testListenerUpdatesSetTokenAndProfile() {
        let sut = testStore(for: Fixtures.profileA)

        let fetchProfileByPublisher: AnyPublisher<Profile?, LocalStoreError> = Just(Fixtures
            .erxProfileWithTokenAndDetails)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
        mockProfileDataStore.fetchProfileByReturnValue = fetchProfileByPublisher

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        mockProfileSecureDataWiper.secureStorageOfReturnValue = mockSecureUserStore
        let mockUserSession = MockUserSession()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession

        sut.send(.registerListener)

        sut.receive(.tokenReceived(Fixtures.token))

        sut.receive(.biometricKeyIDReceived(true)) {
            $0.hasBiometricKeyID = true
        }

        sut.receive(.canReceived(Fixtures.can)) {
            $0.can = Fixtures.can
        }

        sut.receive(.profileReceived(.success(Fixtures.erxProfileWithTokenAndDetails))) {
            $0.insuranceId = Fixtures.erxProfileWithTokenAndDetails.insuranceId
            $0.insurance = Fixtures.erxProfileWithTokenAndDetails.insurance
            $0.fullName = Fixtures.erxProfileWithTokenAndDetails.fullName
        }

        expect(self.mockUserSessionProvider.userSessionForCalled).to(beTrue())
        expect(self.mockProfileDataStore.fetchProfileByCalled).to(beTrue())

        sut.send(.close)
    }

    func testReloginProfileDeletesTokenAndRoutesToMain() {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.listAllProfilesReturnValue = Just([ProfilesDomainTests.Fixtures.erxProfileA])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.profileId)
            .eraseToAnyPublisher()

        mockProfileDataStore.deleteProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.relogin) {
            $0.token = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))
        expect(self.mockRouting.routeToReceivedEndpoint).to(equal(.mainScreen(.login)))
    }

    func testShowDeleteBiometricPairingAlert() {
        let sut = testStore(for: Fixtures.profileA)

        // Should show a confirmation dialog
        sut.send(.showDeleteBiometricPairingAlert) { state in
            state.route = .alert(EditProfileDomain.AlertStates.deleteBiometricPairing)
        }
    }

    func testDeleteBiometricPairingHappyPath() {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        let mockUserSession = MockUserSession()
        mockUserSession.secureUserStore = mockSecureUserStore
        let mockIDPSession = IDPSessionMock()
        mockIDPSession.unregisterDevice_Publisher = Just(true).setFailureType(to: IDPError.self).eraseToAnyPublisher()
        mockIDPSession.idpToken.send(Fixtures.token)
        mockUserSession.biometrieIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        sut.send(.confirmDeleteBiometricPairing) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.route = nil
        }

        expect(mockIDPSession.isLoggedIn_CallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_CallsCount).to(equal(1))

        let result = Result<Bool, IDPError>.success(true)
        sut.receive(.deleteBiometricPairingReceived(result))

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))
    }

    func testDeleteBiometricPairingFailedUnregisterCall() {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.set(token: Fixtures.token)
        mockSecureUserStore.set(keyIdentifier: Fixtures.keyIdentifier)
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        let mockUserSession = MockUserSession()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        let mockIDPSession = IDPSessionMock()
        let expectedError = IDPError.internal(error: IDPError.InternalError.notImplemented)
        mockIDPSession.unregisterDevice_Publisher = Fail(error: expectedError).eraseToAnyPublisher()
        mockIDPSession.idpToken.send(Fixtures.token)
        mockUserSession.biometrieIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        sut.send(.confirmDeleteBiometricPairing) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.route = nil
        }

        expect(mockIDPSession.isLoggedIn_CallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_CallsCount).to(equal(1))

        let result = Result<Bool, IDPError>.failure(expectedError)
        sut.receive(.deleteBiometricPairingReceived(result)) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.route = .alert(EditProfileDomain.AlertStates.deleteBiometricPairingFailed(with: expectedError))
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCalled).to(beFalse())
    }

    func testDeleteBiometricPairingWithMissingPairingTokenToDoRelogin() {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockUserSession = MockUserSession()
        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        let mockIDPSession = IDPSessionMock()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSession.biometrieIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        sut.send(.confirmDeleteBiometricPairing) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.route = nil
        }

        expect(mockIDPSession.isLoggedIn_CallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_Called).to(beFalse())

        sut.receive(.relogin) { state in
            state.token = nil
            state.hasBiometricKeyID = true
            state.route = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCalled).to(beTrue())
    }

    func testDeleteBiometricPairingConfirmationAlertCancelation() {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        sut.send(.dismissAlert) { state in
            state.route = nil
        }
    }
}

extension EditProfileDomainTests {
    enum Fixtures {
        static let uuid = UUID()
        static let createdA = Date()

        static let token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "redirect")
        static let can = "123132"
        static let keyIdentifier = "1234567890".data(using: .utf8)!

        static let profileA = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
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
            can: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            route: .alert(.init(for: LocalStoreError.notImplemented))
        )

        static let profileWithDeleteConfirmation = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            token: token,
            route: .alert(EditProfileDomain.AlertStates.deleteProfile)
        )

        static let profileWithDeleteBiometricPairingAlert = EditProfileDomain.State(
            name: "Anna Vetter",
            acronym: "AV",
            fullName: nil,
            insurance: nil,
            can: nil,
            insuranceId: nil,
            emoji: nil,
            color: .red,
            profileId: uuid,
            token: token,
            hasBiometricKeyID: true,
            route: .alert(EditProfileDomain.AlertStates.deleteBiometricPairing)
        )

        static let erxProfile = Profile(
            name: "Anna Vetter",
            identifier: uuid,
            created: createdA,
            insuranceId: nil,
            color: .red,
            emoji: nil,
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
