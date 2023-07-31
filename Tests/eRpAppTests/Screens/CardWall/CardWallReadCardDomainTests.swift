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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import HTTPClient
import IDP
import NFCCardReaderProvider
import Nimble
import TestUtils
import XCTest

final class CardWallReadCardDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallReadCardDomain.State,
        CardWallReadCardDomain.Action,
        CardWallReadCardDomain.State,
        CardWallReadCardDomain.Action,
        Void
    >

    var idpMock: TestUtils.IDPSessionMock!
    var mockUserSession: MockUserSession!
    let idpError = IDPError.network(error: HTTPError.networkError("generic network error"))
    var mockNFCSessionProvider: MockNFCSignatureProvider!
    lazy var testProfile = { Profile(name: "TestProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockProfileDataStore = MockProfileDataStore()
    var mockProfileBasedIdpSessionProvider = MockProfileBasedSessionProvider()
    var mockResourceHandler = MockResourceHandler()

    let challenge = try! IDPChallengeSession(
        challenge: IDPChallenge(
            challenge: try! JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        ),
        verifierCode: "abc",
        state: "123",
        nonce: "123"
    )

    let networkScheduler = DispatchQueue.test
    let uiScheduler = DispatchQueue.test

    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: self.uiScheduler.eraseToAnyScheduler(),
            networkScheduler: networkScheduler.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )
    }()

    var sut: CardWallReadCardDomain.State!

    override func setUp() {
        super.setUp()

        idpMock = IDPSessionMock()
        mockNFCSessionProvider = MockNFCSignatureProvider()
        mockUserSession = MockUserSession()
        mockUserSession.idpSession = idpMock
        mockUserSession.nfcSessionProvider = mockNFCSessionProvider
        idpMock.requestChallenge_Publisher = Just(challenge)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        mockProfileBasedIdpSessionProvider.idpSessionForReturnValue = idpMock
        mockProfileBasedIdpSessionProvider.userDataStoreForReturnValue = mockUserSession.secureUserStore
        mockProfileBasedIdpSessionProvider.biometrieIdpSessionForReturnValue = mockUserSession.biometrieIdpSession
        mockProfileBasedIdpSessionProvider.idTokenValidatorForReturnValue = mockProfileValidator
    }

    lazy var signedChallenge: SignedChallenge = {
        try! SignedChallenge(
            originalChallenge: self.challenge,
            signedChallenge: JWT(header: JWT.Header(), payload: IDPChallengeResponse(njwt: "original-challenge"))
        )
    }()

    func testStore(initialState: CardWallReadCardDomain.State) -> TestStore {
        mockProfileValidator = Just(
            ProfileValidator(currentProfile: testProfile, otherProfiles: [testProfile])
        ).setFailureType(to: IDTokenValidatorError.self).eraseToAnyPublisher()
        mockProfileBasedIdpSessionProvider.idTokenValidatorForReturnValue = mockProfileValidator

        return TestStore(
            initialState: initialState,
            reducer: CardWallReadCardDomain(),
            prepareDependencies: { dependencies in
                dependencies.dateProvider = { Date() }
                dependencies.schedulers = schedulers
                dependencies.profileDataStore = mockProfileDataStore
                dependencies.secureEnclaveSignatureProvider = DummySecureEnclaveSignatureProvider()
                dependencies.profileBasedSessionProvider = mockProfileBasedIdpSessionProvider
                dependencies.nfcSessionProvider = mockNFCSessionProvider
                dependencies.resourceHandler = mockResourceHandler
            }
        )
    }

    var defaultState: CardWallReadCardDomain.State {
        CardWallReadCardDomain.State(isDemoModus: false,
                                     profileId: mockUserSession.profileId,
                                     pin: "123456",
                                     loginOption: .withoutBiometry,
                                     output: .challengeLoaded(challenge))
    }

    func testOnAppearTriggersRequestIDPChallenge() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .idle
            )
        )

        sut.send(.getChallenge)
        sut.receive(.response(.state(.retrievingChallenge(.loading)))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        networkScheduler.advance()
        uiScheduler.advance()
        sut.receive(.response(.state(.challengeLoaded(challenge)))) { state in
            state.output = .challengeLoaded(self.challenge)
        }
    }

    func testHappyPathSigning() {
        mockProfileValidator = Just(
            ProfileValidator(currentProfile: testProfile, otherProfiles: [testProfile])
        ).setFailureType(to: IDTokenValidatorError.self).eraseToAnyPublisher()
        mockProfileBasedIdpSessionProvider.idTokenValidatorForReturnValue = mockProfileValidator
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Just(signedChallenge)
            .setFailureType(to: NFCSignatureProviderError.self)
            .eraseToAnyPublisher()
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = testStore(initialState: defaultState)

        let idpToken = IDPSessionMock.fixtureIDPToken
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCanPinChallengeCalled).to(beTrue())
        uiScheduler.advance()
        sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(idpToken)
        }
        uiScheduler.advance()
        sut.receive(.delegate(.close))
    }

    func testWhenOnAppearIDPChallengeFails_ViewIsInErrorState() {
        let passthrough = PassthroughSubject<IDPChallengeSession, IDPError>()
        idpMock.requestChallenge_Publisher = passthrough.eraseToAnyPublisher()

        let sut = testStore(initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                                       profileId: mockUserSession.profileId,
                                                                       pin: "123456",
                                                                       loginOption: .withoutBiometry,
                                                                       output: .idle))

        sut.send(.getChallenge)
        sut.receive(.response(.state(.retrievingChallenge(.loading)))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        passthrough.send(completion: .failure(idpError))
        networkScheduler.advance()
        uiScheduler.advance()

        let error = CardWallReadCardDomain.State.Error.idpError(idpError)

        sut.receive(CardWallReadCardDomain.Action
            .response(.state(.retrievingChallenge(.error(error))))) { state in
                state.output = .retrievingChallenge(.error(error))
                state.destination = .alert(CardWallReadCardDomain.AlertStates.alertFor(error))
        }
    }

    func testWhenOnAppearIDPChallengeFails_ButtonPressStartsAnotherRequest() {
        let testStore = testStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .retrievingChallenge(.error(.idpError(idpError)))
            )
        )

        testStore.send(.getChallenge)
        testStore.receive(.response(.state(.retrievingChallenge(.loading)))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        uiScheduler.advance()
        testStore.receive(CardWallReadCardDomain.Action.response(.state(.challengeLoaded(challenge)))) { state in
            state.output = .challengeLoaded(self.challenge)
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_HappyPath() {
        let verifyPassthrough: PassthroughSubject<IDPExchangeToken, IDPError> = PassthroughSubject()
        let exchangeToken = IDPExchangeToken(code: "abc", sso: "def", state: "ghi", redirect: "redirect")

        idpMock.verify_Publisher = verifyPassthrough.eraseToAnyPublisher()

        let sut = testStore(initialState: defaultState)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Just(signedChallenge)
            .setFailureType(to: NFCSignatureProviderError.self)
            .eraseToAnyPublisher()
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(CardWallReadCardDomain.Action.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        verifyPassthrough.send(exchangeToken)
        verifyPassthrough.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(.response(.state(.loggedIn(IDPSessionMock.fixtureIDPToken)))) { state in
            state.output = .loggedIn(IDPSessionMock.fixtureIDPToken)
        }
        sut.receive(.delegate(.close))
    }

    func testWhenIDPChallengeAvailable_SigningStates_PinError() {
        let sut = testStore(initialState: defaultState)
        let pinError = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 2))
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: pinError).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        uiScheduler.advance()
        sut.receive(CardWallReadCardDomain.Action
            .response(.state(.signingChallenge(.error(.signChallengeError(pinError)))))) { state in
                state.output = .signingChallenge(.error(.signChallengeError(pinError)))
                state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongPIN(.signChallengeError(pinError)))
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_CanError() {
        let sut = testStore(initialState: defaultState)
        let canError = NFCSignatureProviderError.wrongCAN(GenericTestError.genericError)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: canError).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action
                .response(.state(.signingChallenge(.error(.signChallengeError(canError)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(canError)))
            state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongCAN(.signChallengeError(canError)))
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_Error_To_Report() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testSendingMail() {
        withDependencies { dependencies in
            dependencies.dateProvider = { Date() }
        } operation: {
            mockResourceHandler.canOpenURLReturnValue = true
            let sut = testStore(initialState: defaultState)

            let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
            let report = CardWallReadCardDomain.createNfcReadingReport(with: error, commands: [])
            let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: report)
            let expectedUrl = mailState.createEmailUrl()

            expect(self.mockResourceHandler.canOpenURLCalled).to(beFalse())
            expect(self.mockResourceHandler.openCalled).to(beFalse())
            sut.send(.openMail(report))
            expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
            expect(self.mockResourceHandler.openCalled).to(beTrue())
            expect(self.mockResourceHandler.openReceivedUrl?.absoluteString) == expectedUrl?.absoluteString
        }
    }

    func testUpdateProfileSaveError() {
        let sut = testStore(initialState: defaultState)

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Fail(error: .notImplemented).eraseToAnyPublisher()
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Just(signedChallenge)
            .setFailureType(to: NFCSignatureProviderError.self)
            .eraseToAnyPublisher()

        let idpToken = IDPSessionMock.fixtureIDPToken
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCanPinChallengeCalled).to(beTrue())

        uiScheduler.advance()
        sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(idpToken)
        }
        uiScheduler.advance()
        sut.receive(.saveError(.notImplemented)) { state in
            state.destination = .alert(CardWallReadCardDomain.AlertStates.saveProfile)
        }
    }

    func testValidateProfileFailure() {
        let sut = testStore(initialState: defaultState)

        let expectedInternalError = IDTokenValidatorError.profileNotMatchingInsuranceId("X12345")
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpMock.exchange_Publisher = Fail(
            error: .unspecified(error: expectedInternalError)
        ).eraseToAnyPublisher()
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Just(signedChallenge)
            .setFailureType(to: NFCSignatureProviderError.self)
            .eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCanPinChallengeCalled).to(beTrue())

        uiScheduler.advance()
        sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.response(.state(.verifying(.error(.profileValidation(expectedInternalError)))))) { state in
            state.output = .verifying(.error(.profileValidation(expectedInternalError)))
            state
                .destination = .alert(CardWallReadCardDomain.AlertStates
                    .alertFor(CardWallReadCardDomain.State.Error.profileValidation(expectedInternalError)))
        }
    }

    func testExpectedErrorAlertForPasswordNotFound() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.passwordNotFound)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForPasswordNotUsable() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.passwordNotUsable)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForSecurityStatusNotSatisfied() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.securityStatusNotSatisfied)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForMemoryFailure() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.memoryFailure)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForUnknownFailure() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.unknownFailure)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForWrongPIN() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 2))
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongPIN(stateError))
        }
    }

    func testExpectedErrorAlertForWrongPINAndNoRetry() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 0))
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertFor(stateError))
        }
    }

    func testExpectedErrorAlertForPasswordBlocked() {
        let sut = testStore(initialState: defaultState)
        let error = NFCSignatureProviderError.verifyCardError(.passwordBlocked)
        mockNFCSessionProvider.signCanPinChallengeReturnValue = Fail(error: error).eraseToAnyPublisher()

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(stateError))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertFor(stateError))
        }
    }
}
