//
//  Copyright (c) 2021 gematik GmbH
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
    }

    lazy var signedChallenge: SignedChallenge = {
        try! SignedChallenge(
            originalChallenge: self.challenge,
            signedChallenge: JWT(header: JWT.Header(), payload: IDPChallengeResponse(njwt: "original-challenge"))
        )
    }()

    func testOnAppearTriggersRequestIDPChallenge() {
        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .idle
            ),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        testStore.assert(
            .send(.getChallenge),
            .receive(.stateReceived(.retrievingChallenge(.loading))) { state in
                state.output = .retrievingChallenge(.loading)
            },
            .do {
                self.networkScheduler.advance()
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.challengeLoaded(challenge))) { state in
                state.output = .challengeLoaded(self.challenge)
            }
        )
    }

    func testHappyPathSigning() {
        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .challengeLoaded(challenge)
            ),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        testStore.assert(
            .send(.signChallenge(challenge)),
            .do {
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.signingChallenge(.loading))) { state in
                state.output = .signingChallenge(.loading)
            },
            .do {
                expect(self.mockNFCSessionProvider.signCalled).to(beTrue())
                self.mockNFCSessionProvider.signResult.send(self.signedChallenge)
                self.mockNFCSessionProvider.signResult.send(completion: .finished)
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.verifying(.loading))) { state in
                state.output = .verifying(.loading)
            },
            .receive(.stateReceived(.loggedIn)) { state in
                state.output = .loggedIn
            }
        )
    }

    func testWhenOnAppearIDPChallengeFails_ViewIsInErrorState() {
        let passthrough = PassthroughSubject<IDPChallengeSession, IDPError>()
        idpMock.requestChallenge_Publisher = passthrough.eraseToAnyPublisher()

        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .idle),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        testStore.assert(
            .send(.getChallenge),
            .receive(.stateReceived(.retrievingChallenge(.loading))) { state in
                state.output = .retrievingChallenge(.loading)
            },
            .do {
                passthrough.send(completion: .failure(self.idpError))
                self.networkScheduler.advance()
                self.uiScheduler.advance()
            },
            .receive(CardWallReadCardDomain.Action
                .stateReceived(.retrievingChallenge(.error(.idpError(idpError))))) { state in
                state.output = .retrievingChallenge(.error(.idpError(self.idpError)))
            }
        )
    }

    func testWhenOnAppearIDPChallengeFails_ButtonPressStartsAnotherRequest() {
        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(
                isDemoModus: false,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .retrievingChallenge(.error(.idpError(idpError)))
            ),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        testStore.assert(
            .send(.getChallenge),
            .receive(.stateReceived(.retrievingChallenge(.loading))) { state in
                state.output = .retrievingChallenge(.loading)
            },
            .do {
                self.uiScheduler.advance()
            },
            .receive(CardWallReadCardDomain.Action.stateReceived(.challengeLoaded(challenge))) { state in
                state.output = .challengeLoaded(self.challenge)
            }
        )
    }

    func testWhenIDPChallengeAvailable_SigningStates_HappyPath() {
        let verifyPassthrough: PassthroughSubject<IDPExchangeToken, IDPError> = PassthroughSubject()
        let exchangeToken = IDPExchangeToken(code: "abc", sso: "def", state: "ghi")

        idpMock.verify_Publisher = verifyPassthrough.eraseToAnyPublisher()

        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge)),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        testStore.assert(
            .send(.signChallenge(challenge)),
            .do {
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.signingChallenge(.loading))) { state in
                state.output = .signingChallenge(.loading)
            },
            .do {
                self.mockNFCSessionProvider.signResult.send(self.signedChallenge)
                self.mockNFCSessionProvider.signResult.send(completion: .finished)
                self.uiScheduler.advance()
            },
            .receive(CardWallReadCardDomain.Action.stateReceived(.verifying(.loading))) { state in
                state.output = .verifying(.loading)
            },
            .do {
                verifyPassthrough.send(exchangeToken)
                verifyPassthrough.send(completion: .finished)
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.loggedIn)) { state in
                state.output = .loggedIn
            }
        )
    }

    func testWhenIDPChallengeAvailable_SigningStates_PinError() {
        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge)),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        let pinError = NFCSignatureProviderError.wrongPin(retryCount: 2)

        testStore.assert(
            .send(.signChallenge(challenge)),
            .do {
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.signingChallenge(.loading))) { state in
                state.output = .signingChallenge(.loading)
            },
            .do {
                self.mockNFCSessionProvider.signResult.send(completion: .failure(pinError))
                self.mockNFCSessionProvider.signResult.send(completion: .finished)
                self.uiScheduler.advance()
            },
            .receive(CardWallReadCardDomain.Action
                .stateReceived(.signingChallenge(.error(.signChallengeError(pinError))))) { state in
                state.output = .signingChallenge(.error(.signChallengeError(pinError)))
            }
        )
    }

    func testWhenIDPChallengeAvailable_SigningStates_CanError() {
        let testStore = TestStore(
            initialState: CardWallReadCardDomain.State(isDemoModus: false,
                                                       pin: "123456",
                                                       loginOption: .withoutBiometry,
                                                       output: .challengeLoaded(challenge)),
            reducer: CardWallReadCardDomain.reducer,
            environment: CardWallReadCardDomain.Environment(
                userSession: mockUserSession,
                schedulers: schedulers,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )

        let canError = NFCSignatureProviderError.wrongCAN(GenericTestError.genericError)

        testStore.assert(
            .send(.signChallenge(challenge)),
            .do {
                self.uiScheduler.advance()
            },
            .receive(.stateReceived(.signingChallenge(.loading))) { state in
                state.output = .signingChallenge(.loading)
            },
            .do {
                self.mockNFCSessionProvider.signResult.send(completion: .failure(canError))
                self.mockNFCSessionProvider.signResult.send(completion: .finished)
                self.uiScheduler.advance()
            },
            .receive(CardWallReadCardDomain.Action
                .stateReceived(.signingChallenge(.error(.signChallengeError(canError))))) { state in
                state.output = .signingChallenge(.error(.signChallengeError(canError)))
            }
        )
    }
}
