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
import TestUtils
import XCTest

@MainActor
final class ExtAuthPendingDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<ExtAuthPendingDomain>

    var idpSessionMock: IDPSessionMock!
    var extAuthRequestStorageMock: ExtAuthRequestStorageMock!
    lazy var testProfile = { Profile(name: "TestProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockProfileDataStore: MockProfileDataStore!
    let uiScheduler = DispatchQueue.test
    var mockUserSession: MockUserSession!
    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: uiScheduler.eraseToAnyScheduler(),
            networkScheduler: DispatchQueue.immediate.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.immediate.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.immediate.eraseToAnyScheduler()
        )
    }()

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        idpSessionMock = IDPSessionMock()
        extAuthRequestStorageMock = ExtAuthRequestStorageMock()
        mockProfileDataStore = MockProfileDataStore()
    }

    func testStore(for state: ExtAuthPendingDomain.State) -> TestStore {
        mockUserSession.profileId = testProfile.id
        mockUserSession.profileDataStore = mockProfileDataStore
        mockUserSession.profileReturnValue = Just(testProfile).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockProfileValidator = Just(
            ProfileValidator(currentProfile: testProfile, otherProfiles: [testProfile])
        ).setFailureType(to: IDTokenValidatorError.self).eraseToAnyPublisher()
        mockProfileDataStore.listAllProfilesReturnValue = Just([testProfile])
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        return TestStore(initialState: state) {
            ExtAuthPendingDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.idpSession = idpSessionMock
            dependencies.profileDataStore = mockUserSession.profileDataStore
            dependencies.extAuthRequestStorage = extAuthRequestStorageMock
            dependencies.userSession = mockUserSession
        }
    }

    func testStore()
        -> TestStore {
        testStore(for: .init())
    }

    func testNoRequestsResultsInEmptyState() async {
        let sut = testStore(for: .init(extAuthState: .pendingExtAuth(KKAppDirectory.Entry(name: "", identifier: ""))))
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([]))) { state in
            state.extAuthState = .empty
        }
    }

    func testEntriesResultInPendingState() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
    }

    func testExternalURLFiresIDPRequestHappyPath() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Just(IDPSessionMock.fixtureIDPToken)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()

        await sut.send(.externalLogin(urlFixture)) { state in
            state.extAuthState = .extAuthReceived(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.response(.externalLoginReceived(.success(IDPSessionMock.fixtureIDPToken)))) { state in
            state.extAuthState = .extAuthSuccessful(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.hide) { state in
            state.extAuthState = .empty
        }
    }

    func testExternalURLFiresIDPRequestHappyPathWithState() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de?state=hallo")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Just(IDPSessionMock.fixtureIDPToken)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()

        let requestingKK = KKAppDirectory.Entry(name: "Requested KK", identifier: "1234")
        let actualSessionResponse = ExtAuthChallengeSession(verifierCode: "code", nonce: "nonce", for: requestingKK)
        extAuthRequestStorageMock.getExtAuthRequestForReturnValue = actualSessionResponse
        await sut.send(.externalLogin(urlFixture)) { state in
            state.extAuthState = .extAuthReceived(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.response(.externalLoginReceived(.success(IDPSessionMock.fixtureIDPToken)))) { state in
            state.extAuthState = .extAuthSuccessful(healthInsurance)
        }
        await uiScheduler.advance(by: .seconds(2.1))
        await sut.receive(.hide) { state in
            state.extAuthState = .empty
        }
    }

    func testExternalURLFiresIDPRequestFailurePath() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "Gematik KK", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Fail(error: IDPError.extAuthOriginalRequestMissing).eraseToAnyPublisher()

        await sut.send(.externalLogin(urlFixture)) { state in
            state.extAuthState = .extAuthReceived(healthInsurance)
        }
        await uiScheduler.run()
        await sut
            .receive(.response(.externalLoginReceived(.failure(.idpError(.extAuthOriginalRequestMissing,
                                                                         urlFixture))))) { state in
                state.extAuthState = .extAuthFailed
                state.destination = .extAuthAlert(
                    ExtAuthPendingDomain.alertState(
                        title: healthInsurance.name,
                        message: "Error while processing external authentication: original request not found.\n\nFehlernummern: \ni-10019",
                        // swiftlint:disable:previous line_length
                        url: urlFixture
                    )
                )
            }
    }

    func testCancelPendingRequestsRemovesCorrectly() async {
        let healthInsurance = KKAppDirectory.Entry(name: "Gematik KK", identifier: "123")
        let sut = testStore(for: .init(extAuthState: .pendingExtAuth(healthInsurance)))

        let pendingRequests = [
            ExtAuthChallengeSession(verifierCode: "VerifierCode1",
                                    nonce: "nonce1",
                                    for: healthInsurance),
            ExtAuthChallengeSession(verifierCode: "VerifierCode2",
                                    nonce: "nonce2",
                                    for: healthInsurance),
        ]
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just(pendingRequests)
            .eraseToAnyPublisher()
        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived(pendingRequests)))
        expect(self.extAuthRequestStorageMock.resetCalled).to(beFalse())
        await sut.send(.cancelAllPendingRequests) { state in
            state.extAuthState = .empty
        }
        expect(self.extAuthRequestStorageMock.resetCalled).to(beTrue())
    }

    func testCloseNilsTheState() async {
        let sut =
            testStore(for: .init(extAuthState: .pendingExtAuth(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "123"))))

        await sut.send(.hide) { state in
            state.extAuthState = .empty
        }
    }

    func testExistingEntriesMovingToZeroKeepsSuccessStateForAnimation() async {
        let requestingKK = KKAppDirectory.Entry(name: "Requested KK", identifier: "1234")

        let sut = testStore(for: .init(extAuthState: .empty))

        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)

        await uiScheduler.run()

        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }

        let actualSessionResponse = ExtAuthChallengeSession(verifierCode: "code", nonce: "nonce", for: requestingKK)

        let publisher = CurrentValueSubject<[ExtAuthChallengeSession], Never>([actualSessionResponse])
        extAuthRequestStorageMock.pendingExtAuthRequests = publisher.eraseToAnyPublisher()

        publisher.send([])

        await uiScheduler.advance(by: .seconds(2.1))
    }

    func testProfileValidatorWithError() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "Gematik KK", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!
        let expectedInternalError = IDTokenValidatorError.profileNotMatchingInsuranceId("X123")
        idpSessionMock.extAuthVerifyAndExchange_Publisher = Fail(
            error: .unspecified(error: expectedInternalError)
        ).eraseToAnyPublisher()

        await sut.send(.externalLogin(urlFixture)) { state in
            state.extAuthState = .extAuthReceived(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.response(
            .externalLoginReceived(.failure(.profileValidation(error: expectedInternalError)))
        )) { state in
            state.extAuthState = .extAuthFailed
            state.destination = .extAuthAlert(
                ExtAuthPendingDomain.alertState(
                    title: healthInsurance.name,
                    message: expectedInternalError.localizedDescriptionWithErrorList
                )
            )
        }
    }

    func testSaveProfileWithError() async {
        let sut = testStore(for: .init(extAuthState: .empty))
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        mockProfileDataStore.updateProfileIdMutatingReturnValue =
            Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        await sut.send(.registerListener)
        await uiScheduler.run()
        await sut.receive(.response(.pendingExtAuthRequestsReceived([session]))) { state in
            state.extAuthState = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Just(IDPSessionMock.fixtureIDPToken)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()

        await sut.send(.externalLogin(urlFixture)) { state in
            state.extAuthState = .extAuthReceived(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.response(.externalLoginReceived(.success(IDPSessionMock.fixtureIDPToken)))) { state in
            state.extAuthState = .extAuthSuccessful(healthInsurance)
        }
        await uiScheduler.run()
        await sut.receive(.saveProfile(error: LocalStoreError.notImplemented)) { state in
            state.extAuthState = .extAuthFailed
            state.destination = .extAuthAlert(ExtAuthPendingDomain.saveProfileAlert)
        }
    }

    let idpToken: IDPToken = {
        let decryptedTokenPayload: TokenPayload = {
            let tokenPath = Bundle.module
                .testResourceFilePath(in: "JWT", for: "idp_token_decrypted.json")
            let tokenData = try! tokenPath.readFileContents()
            return try! JSONDecoder().decode(TokenPayload.self, from: tokenData)
        }()
        let exchangeToken = IDPExchangeToken(code: "code", sso: "sso-token", state: "state", redirect: "redirect")
        return IDPToken(
            accessToken: decryptedTokenPayload.accessToken,
            expires: Date(),
            idToken: decryptedTokenPayload.idToken,
            ssoToken: exchangeToken.sso,
            redirect: "redirect"
        )
    }()

    func testSaveProfileWithDefaultNameOnFirstLogin() async {
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let sut = testStore(for: .init(extAuthState: .extAuthReceived(healthInsurance)))
        var profile = Profile(
            name: "Profil 1",
            shouldAutoUpdateNameAtNextLogin: true
        )
        mockUserSession.profileReturnValue = Just(profile).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileDataStore.updateProfileIdMutatingClosure = { _, mutating in
            mutating(&profile)
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        await sut.send(.response(.externalLoginReceived(.success(idpToken)))) {
            $0.extAuthState = .extAuthSuccessful(
                KKAppDirectory.Entry(
                    name: "KK name",
                    identifier: "kk id",
                    logo: nil
                )
            )
        }

        await uiScheduler.run()
        await sut.receive(.hide) { state in
            state.extAuthState = .empty
        }

        expect(profile.name) == "Heinz Hillbert Cördes"
    }

    func testSaveProfileWithDefaultNameLoggedInBefore() async {
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let sut = testStore(for: .init(extAuthState: .extAuthReceived(healthInsurance)))
        var profile = Profile(name: "Profil 1", lastAuthenticated: Date.distantPast)
        mockUserSession.profileReturnValue = Just(profile).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockProfileDataStore.updateProfileIdMutatingClosure = { _, mutating in
            mutating(&profile)
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        await sut.send(.response(.externalLoginReceived(.success(idpToken)))) {
            $0.extAuthState = .extAuthSuccessful(
                KKAppDirectory.Entry(
                    name: "KK name",
                    identifier: "kk id",
                    logo: nil
                )
            )
        }

        await uiScheduler.run()
        await sut.receive(.hide) { state in
            state.extAuthState = .empty
        }

        expect(profile.name) == "Profil 1"
    }
}
