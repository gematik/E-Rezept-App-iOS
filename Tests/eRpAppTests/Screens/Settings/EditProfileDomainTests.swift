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
            dependencies.profileSecureDataWiper = mockProfileSecureDataWiper
            dependencies.profileDataStore = mockProfileDataStore
            dependencies.userDataStore = mockUserDataStore
            dependencies.router = mockRouting
        }
    }

    let mainQueue = DispatchQueue.immediate

    var mockAppSecurityManager: MockAppSecurityManager!
    var mockUserSession: MockUserSession!
    var mockProfileDataStore: MockProfileDataStore!
    var mockUserDataStore: MockUserDataStore!
    var mockProfileSecureDataWiper: MockProfileSecureDataWiper!
    var mockRouting: MockRouting!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockSecureEnclaveSignatureProvider: MockSecureEnclaveSignatureProvider!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockUserSession = MockUserSession()
        mockProfileDataStore = MockProfileDataStore()
        mockUserDataStore = MockUserDataStore()
        mockProfileSecureDataWiper = MockProfileSecureDataWiper()
        mockRouting = MockRouting()
        mockUserSessionProvider = MockUserSessionProvider()
        mockSecureEnclaveSignatureProvider = MockSecureEnclaveSignatureProvider()
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

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(\.binding.name, "Anna Vette") { state in
            state.name = "Anna Vette"

            let showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0
            expect(showEmptyNameWarning).to(beFalse())
        }

        await sut.receive(.response(.updateProfileReceived(.success(true))))

        expect(self.mockProfileDataStore.updateProfileIdMutatingCallsCount).to(equal(1))
    }

    func testSavingColor() async {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
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

        expect(self.mockProfileDataStore.updateProfileIdMutatingCallsCount).to(equal(2))
    }

    func testSavingFailsDisplaysAlert() async {
        let sut = testStore(for: Fixtures.profileA)

        let error = LocalStoreError.notImplemented

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Fail(error: error)
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
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfReceivedInvocations)
            .to(equal([Fixtures.erxProfile.id]))
        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))

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
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        await sut.receive(.delegate(.close))

        expect(self.mockUserDataStore.setSelectedProfileIdCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testDeleteLastProfileCreatesANewOne() async {
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
        await sut.send(.destination(.presented(.alert(.confirmDeleteProfile))))

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beFalse())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile])

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beFalse())

        listProfilesPublisher.send([Fixtures.erxProfile, ProfilesDomainTests.Fixtures.erxProfileA])

        await sut.receive(.delegate(.close))

        expect(self.mockProfileDataStore.saveProfilesCalled).to(beTrue())
        expect(self.mockProfileDataStore.deleteProfilesCalled).to(beTrue())

        expect(self.mockUserDataStore.setSelectedProfileIdCalled).to(beTrue())
        expect(self.mockUserDataStore.setSelectedProfileIdReceivedInvocations)
            .to(contain(ProfilesDomainTests.Fixtures.erxProfileA.id))
    }

    func testListenerUpdatesSetTokenAndProfile() async {
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

        await sut.send(.task) {
            $0.availableSecurityOptions = [.password]
        }

        await sut.receive(.response(.tokenReceived(Fixtures.token)))

        await sut.receive(.response(.biometricKeyIDReceived(true))) {
            $0.hasBiometricKeyID = true
        }

        await sut.receive(.response(.canReceived(Fixtures.can))) {
            $0.can = Fixtures.can
        }

        await sut.receive(.response(.profileReceived(.success(Fixtures.erxProfileWithTokenAndDetails)))) {
            $0.insuranceId = Fixtures.erxProfileWithTokenAndDetails.insuranceId
            $0.insurance = Fixtures.erxProfileWithTokenAndDetails.insurance
            $0.fullName = Fixtures.erxProfileWithTokenAndDetails.fullName
        }

        expect(self.mockUserSessionProvider.userSessionForCalled).to(beTrue())
        expect(self.mockProfileDataStore.fetchProfileByCalled).to(beTrue())

        await sut.send(.delegate(.close))
    }

    func testReloginProfileDeletesTokenAndRoutesToMain() async {
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

        await sut.send(.relogin) {
            $0.token = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))
        expect(self.mockRouting.routeToReceivedEndpoint).to(equal(.mainScreen(.login)))
    }

    func testLogoutProfileDeletesToken() async {
        let sut = testStore(for: Fixtures.profileA)

        mockProfileDataStore.listAllProfilesReturnValue = Just([ProfilesDomainTests.Fixtures.erxProfileA])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.profileId)
            .eraseToAnyPublisher()
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileDataStore.deleteProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.delegate(.logout)) {
            $0.token = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))
    }

    func testShowDeleteBiometricPairingAlert() async {
        let sut = testStore(for: Fixtures.profileA)

        // Should show a confirmation dialog
        await sut.send(.showDeleteBiometricPairingAlert) { state in
            state.destination = .alert(EditProfileDomain.AlertStates.deleteBiometricPairing)
        }
    }

    func testDeleteBiometricPairingHappyPath() async {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        mockUserSession.secureUserStore = mockSecureUserStore
        let mockBiometricsIdpSessionLoginHandler = MockLoginHandler()
        mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.pairingIdpSessionLoginHandler = mockBiometricsIdpSessionLoginHandler
        let mockIDPSession = IDPSessionMock()
        mockIDPSession.unregisterDevice_Publisher = Just(true).setFailureType(to: IDPError.self).eraseToAnyPublisher()
        mockIDPSession.idpToken.send(Fixtures.token)
        mockUserSession.pairingIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        await sut.send(.destination(.presented(.alert(.confirmDeleteBiometricPairing)))) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.destination = nil
        }

        expect(mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateCallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_CallsCount).to(equal(1))

        let result = Result<Bool, IDPError>.success(true)
        await sut.receive(.response(.deleteBiometricPairingReceived(result)))

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCallsCount).to(equal(1))
    }

    func testDeleteBiometricPairingFailedUnregisterCall() async {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.set(token: Fixtures.token)
        mockSecureUserStore.set(keyIdentifier: Fixtures.keyIdentifier)
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        let mockBiometricsIdpSessionLoginHandler = MockLoginHandler()
        mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.pairingIdpSessionLoginHandler = mockBiometricsIdpSessionLoginHandler
        let mockIDPSession = IDPSessionMock()
        let expectedError = IDPError.internal(error: IDPError.InternalError.notImplemented)
        mockIDPSession.unregisterDevice_Publisher = Fail(error: expectedError).eraseToAnyPublisher()
        mockIDPSession.idpToken.send(Fixtures.token)
        mockUserSession.pairingIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        await sut.send(.destination(.presented(.alert(.confirmDeleteBiometricPairing)))) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.destination = nil
        }

        expect(mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateCallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_CallsCount).to(equal(1))

        let result = Result<Bool, IDPError>.failure(expectedError)
        await sut.receive(.response(.deleteBiometricPairingReceived(result))) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.destination = .alert(EditProfileDomain.AlertStates.deleteBiometricPairingFailed(with: expectedError))
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCalled).to(beFalse())
    }

    func testDeleteBiometricPairingWithMissingPairingTokenToDoRelogin() async {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        let mockSecureUserStore = MockSecureUserStore()
        mockSecureUserStore.tokenState = Just(Fixtures.token).eraseToAnyPublisher()
        mockSecureUserStore.can = Just(Fixtures.can).eraseToAnyPublisher()
        mockSecureUserStore.underlyingKeyIdentifier = Just(Data()).eraseToAnyPublisher()
        let mockBiometricsIdpSessionLoginHandler = MockLoginHandler()
        mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(false))
            .eraseToAnyPublisher()
        mockUserSession.pairingIdpSessionLoginHandler = mockBiometricsIdpSessionLoginHandler
        let mockIDPSession = IDPSessionMock()
        mockUserSession.secureUserStore = mockSecureUserStore
        mockUserSession.pairingIdpSession = mockIDPSession
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
        mockProfileSecureDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        // when confirming deletion
        await sut.send(.destination(.presented(.alert(.confirmDeleteBiometricPairing)))) { state in
            state.token = Fixtures.token
            state.hasBiometricKeyID = true
            state.destination = nil
        }

        expect(mockBiometricsIdpSessionLoginHandler.isAuthenticatedOrAuthenticateCallsCount).to(equal(1))
        expect(mockIDPSession.autoRefreshedToken_Called).to(beTrue())
        expect(mockIDPSession.unregisterDevice_Called).to(beFalse())

        await sut.receive(.relogin) { state in
            state.token = nil
            state.hasBiometricKeyID = true
            state.destination = nil
        }

        expect(self.mockProfileSecureDataWiper.wipeSecureDataOfCalled).to(beTrue())
    }

    func testDeleteBiometricPairingConfirmationAlertCancelation() async {
        let sut = testStore(for: Fixtures.profileWithDeleteBiometricPairingAlert)

        await sut.send(.destination(.dismiss)) { state in
            state.destination = nil
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

        static let profileWithDeleteBiometricPairingAlert = EditProfileDomain.State(
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
            hasBiometricKeyID: true,
            destination: .alert(EditProfileDomain.AlertStates.deleteBiometricPairing)
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
