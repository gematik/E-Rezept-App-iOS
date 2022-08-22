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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import HealthCardAccess
import HealthCardControl
import HTTPClient
import IDP
import Nimble
import TestUtils
import XCTest

final class CardWallReadCardDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallReadCardDomain.State,
        CardWallReadCardDomain.State,
        CardWallReadCardDomain.Action,
        CardWallReadCardDomain.Action,
        CardWallReadCardDomain.Environment
    >

    var idpMock: TestUtils.IDPSessionMock!
    var mockUserSession: MockUserSession!
    let idpError = IDPError.network(error: HTTPError.networkError("generic network error"))
    var mockNFCSessionProvider: NFCSignatureProviderMock!
    lazy var testProfile = { Profile(name: "TestProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockCurrentProfile: AnyPublisher<Profile, LocalStoreError>!
    var mockProfileDataStore = MockProfileDataStore()
    var mockProfileBasedIdpSessionProvider = MockProfileBasedSessionProvider()
    var mockApplication = MockUIApplication()

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

    var environment: CardWallReadCardDomain.Environment!

    var sut: CardWallReadCardDomain.State!

    override func setUp() {
        super.setUp()

        idpMock = IDPSessionMock()
        mockNFCSessionProvider = NFCSignatureProviderMock()
        mockUserSession = MockUserSession()
        mockUserSession.idpSession = idpMock
        mockUserSession.nfcSessionProvider = mockNFCSessionProvider
        idpMock.requestChallenge_Publisher = Just(challenge)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        mockProfileBasedIdpSessionProvider.idpSessionForReturnValue = idpMock
        mockProfileBasedIdpSessionProvider.signatureProviderForReturnValue = mockNFCSessionProvider
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
        mockCurrentProfile = Just(testProfile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockProfileBasedIdpSessionProvider.idTokenValidatorForReturnValue = mockProfileValidator

        return TestStore(
            initialState: initialState,
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                schedulers: schedulers,
                profileDataStore: mockProfileDataStore,
                signatureProvider: DummySecureEnclaveSignatureProvider(),
                sessionProvider: mockProfileBasedIdpSessionProvider,
                nfcSessionProvider: mockNFCSessionProvider,
                application: mockApplication
            )
        )
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
        sut.receive(.stateReceived(.retrievingChallenge(.loading))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        networkScheduler.advance()
        uiScheduler.advance()
        sut.receive(.stateReceived(.challengeLoaded(challenge))) { state in
            state.output = .challengeLoaded(self.challenge)
        }
    }

    func testHappyPathSigning() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .challengeLoaded(challenge)
            )
        )
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let idpToken = IDPSessionMock.fixtureIDPToken
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCalled).to(beTrue())
        mockNFCSessionProvider.signResult.send(signedChallenge)
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(.stateReceived(.verifying(.loading))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.stateReceived(.loggedIn(idpToken))) { state in
            state.output = .loggedIn(idpToken)
        }
        uiScheduler.advance()
        sut.receive(.close)
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
        sut.receive(.stateReceived(.retrievingChallenge(.loading))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        passthrough.send(completion: .failure(idpError))
        networkScheduler.advance()
        uiScheduler.advance()

        let error = CardWallReadCardDomain.State.Error.idpError(idpError)

        sut.receive(CardWallReadCardDomain.Action
            .stateReceived(.retrievingChallenge(.error(error)))) { state in
                state.output = .retrievingChallenge(.error(error))
                state.route = .alert(CardWallReadCardDomain.AlertStates.alertFor(error))
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
        testStore.receive(.stateReceived(.retrievingChallenge(.loading))) { state in
            state.output = .retrievingChallenge(.loading)
        }
        uiScheduler.advance()
        testStore.receive(CardWallReadCardDomain.Action.stateReceived(.challengeLoaded(challenge))) { state in
            state.output = .challengeLoaded(self.challenge)
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_HappyPath() {
        let verifyPassthrough: PassthroughSubject<IDPExchangeToken, IDPError> = PassthroughSubject()
        let exchangeToken = IDPExchangeToken(code: "abc", sso: "def", state: "ghi", redirect: "redirect")

        idpMock.verify_Publisher = verifyPassthrough.eraseToAnyPublisher()

        let sut = testStore(initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                                       profileId: mockUserSession.profileId,
                                                                       pin: "123456",
                                                                       loginOption: .withoutBiometry,
                                                                       output: .challengeLoaded(challenge)))

        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        mockNFCSessionProvider.signResult.send(signedChallenge)
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(CardWallReadCardDomain.Action.stateReceived(.verifying(.loading))) { state in
            state.output = .verifying(.loading)
        }
        verifyPassthrough.send(exchangeToken)
        verifyPassthrough.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(.stateReceived(.loggedIn(IDPSessionMock.fixtureIDPToken))) { state in
            state.output = .loggedIn(IDPSessionMock.fixtureIDPToken)
        }
        sut.receive(.close)
    }

    func testWhenIDPChallengeAvailable_SigningStates_PinError() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       profileId: mockUserSession.profileId,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge))
        )

        let pinError = NFCSignatureProviderError.wrongPin(retryCount: 2)
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        mockNFCSessionProvider.signResult.send(completion: .failure(pinError))
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(CardWallReadCardDomain.Action
            .stateReceived(.signingChallenge(.error(.signChallengeError(pinError))))) { state in
                state.output = .signingChallenge(.error(.signChallengeError(pinError)))
                state.route = .alert(CardWallReadCardDomain.AlertStates.wrongPIN(.signChallengeError(pinError)))
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_CanError() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       profileId: mockUserSession.profileId,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge))
        )

        let canError = NFCSignatureProviderError.wrongCAN(GenericTestError.genericError)

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        mockNFCSessionProvider.signResult.send(completion: .failure(canError))
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(
            CardWallReadCardDomain.Action
                .stateReceived(.signingChallenge(.error(.signChallengeError(canError))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(canError)))
            state.route = .alert(CardWallReadCardDomain.AlertStates.wrongCAN(.signChallengeError(canError)))
        }
    }

    func testWhenIDPChallengeAvailable_SigningStates_Error_To_Report() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       profileId: mockUserSession.profileId,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge))
        )

        let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()
        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        mockNFCSessionProvider.signResult.send(completion: .failure(error))
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        let report = CardWallReadCardDomain.createNfcReadingReport(with: error, commands: [])
        sut.receive(
            CardWallReadCardDomain.Action.stateReceived(.signingChallenge(.error(.signChallengeError(error))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.route = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(report, error: error))
        }
    }

    func testSendingMail() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       profileId: mockUserSession.profileId,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge))
        )
        let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
        let report = CardWallReadCardDomain.createNfcReadingReport(with: error, commands: [])
        let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: report)
        let expectedUrl = mailState.createEmailUrl()

        expect(self.mockApplication.canOpenURLCalled).to(beFalse())
        expect(self.mockApplication.openCalled).to(beFalse())
        sut.send(.openMail(report))
        expect(self.mockApplication.canOpenURLCalled).to(beTrue())
        expect(self.mockApplication.openCalled).to(beTrue())
        expect(self.mockApplication.openUrlParameter?.absoluteString) == expectedUrl?.absoluteString
    }

    func testUpdateProfileSaveError() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .challengeLoaded(challenge)
            )
        )
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Fail(error: .notImplemented).eraseToAnyPublisher()

        let idpToken = IDPSessionMock.fixtureIDPToken
        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCalled).to(beTrue())
        mockNFCSessionProvider.signResult.send(signedChallenge)
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(.stateReceived(.verifying(.loading))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.stateReceived(.loggedIn(idpToken))) { state in
            state.output = .loggedIn(idpToken)
        }
        uiScheduler.advance()
        sut.receive(.saveError(.notImplemented)) { state in
            state.route = .alert(CardWallReadCardDomain.AlertStates.saveProfile)
        }
    }

    func testValidateProfileFailure() {
        let sut = testStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .challengeLoaded(challenge)
            )
        )

        let expectedInternalError = IDTokenValidatorError.profileNotMatchingInsuranceId("X12345")
        mockProfileDataStore.updateProfileIdMutatingReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpMock.exchange_Publisher = Fail(
            error: .unspecified(error: expectedInternalError)
        ).eraseToAnyPublisher()

        sut.send(.signChallenge(challenge))
        uiScheduler.advance()

        sut.receive(.stateReceived(.signingChallenge(.loading))) { state in
            state.output = .signingChallenge(.loading)
        }
        expect(self.mockNFCSessionProvider.signCalled).to(beTrue())
        mockNFCSessionProvider.signResult.send(signedChallenge)
        mockNFCSessionProvider.signResult.send(completion: .finished)
        uiScheduler.advance()
        sut.receive(.stateReceived(.verifying(.loading))) { state in
            state.output = .verifying(.loading)
        }
        sut.receive(.stateReceived(.verifying(.error(.profileValidation(expectedInternalError))))) { state in
            state.output = .verifying(.error(.profileValidation(expectedInternalError)))
            state.route = .alert(CardWallReadCardDomain.AlertStates.alertFor(.profileValidation(expectedInternalError)))
        }
    }
}
