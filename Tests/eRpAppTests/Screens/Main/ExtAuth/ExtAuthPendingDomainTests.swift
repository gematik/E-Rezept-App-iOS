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
final class ExtAuthPendingDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<ExtAuthPendingDomain>

    var idpSessionMock: IDPSessionMock!
    var extAuthRequestStorageMock: ExtAuthRequestStorageMock!
    lazy var testProfile = { Profile(name: "TestProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockProfileDataStore: MockProfileDataStore!
    let uiScheduler = DispatchQueue.test
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

        idpSessionMock = IDPSessionMock()
        extAuthRequestStorageMock = ExtAuthRequestStorageMock()
        mockProfileDataStore = MockProfileDataStore()
    }

    func testStore(for state: ExtAuthPendingDomain.State) -> TestStore {
        let mockUserSession = MockUserSession()
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
}
