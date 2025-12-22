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
import CombineSchedulers
import ComposableArchitecture
import eRpKit
import eRpResources
@testable import FeatureCardWall
import FeatureHelpers
import HTTPClient
import IDP
import NFCCardReaderProvider
import Nimble
import Profiles
import Synchronization
import TestUtils
import XCTest

@MainActor
final class CardWallReadCardDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallReadCardDomain>

    var idpMock: TestUtils.IDPSessionMock!
    let idpError = IDPError.network(error: HTTPClientError.networkError("generic network error"))
    lazy var testProfile = { Profile(name: "TestProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!

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

    override func setUp() {
        super.setUp()

        idpMock = IDPSessionMock()
        idpMock.requestChallenge_Publisher = Just(challenge)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    }

    var sut: CardWallReadCardDomain.State!

    lazy var signedChallenge: SignedChallenge = {
        try! SignedChallenge(
            originalChallenge: self.challenge,
            signedChallenge: JWT(header: JWT.Header(), payload: IDPChallengeResponse(njwt: "original-challenge"))
        )
    }()

    func testStore(
        initialState: CardWallReadCardDomain.State,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        let fixedDate = Date()

        return TestStore(initialState: initialState) {
            CardWallReadCardDomain()
        } withDependencies: { dependencies in
            dependencies.dateProvider = { fixedDate }
            dependencies.schedulers = schedulers
            dependencies.secureUserDataStoreClient.can = { _ in Just("123456").eraseToAnyPublisher() }

            prepareDependencies(&dependencies)
        }
    }

    var defaultState: CardWallReadCardDomain.State {
        CardWallReadCardDomain.State(profileId: UUID(), // mockUserSession.profileId,
                                     pin: "123456",
                                     loginOption: .withoutBiometry,
                                     output: .idle)
    }

    func testHappyPathSigning() async {
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idTokenValidator = { _ in self.mockProfileValidator }
            dependencies.secureUserDataStoreClient.can = { _ in Just("123456").eraseToAnyPublisher() }
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.profilesStore.update = { _, _ in
                Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .success(self.signedChallenge)
            }
            dependencies.profileBasedSessionProvider.idTokenValidator
                = { _ in
                    Just(SuccessMockIdTokenValidator()).setFailureType(to: IDTokenValidatorError.self)
                        .eraseToAnyPublisher()
                }
        }

        let idpToken = IDPSessionMock.fixtureIDPToken
        await sut.send(.signChallenge)
        await uiScheduler.advance()

        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        await sut.receive(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(idpToken)
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.close))
    }

    func testWhenIDPChallengeFails_ViewIsInErrorState() async {
        let passthrough = PassthroughSubject<IDPChallengeSession, IDPError>()
        idpMock.requestChallenge_Publisher = passthrough.eraseToAnyPublisher()

        let sut = testStore(initialState: CardWallReadCardDomain
            .State(profileId: defaultState.profileId, // mockUserSession.profileId,
                   pin: "123456",
                   loginOption: .withoutBiometry,
                   output: .idle)) { dependencies in
                dependencies.secureUserDataStoreClient.can = { _ in Just("123456").eraseToAnyPublisher() }
                dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
        }

        await sut.send(.signChallenge)
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        passthrough.send(completion: .failure(idpError))
        await networkScheduler.advance()
        await uiScheduler.advance()

        let error = CardWallReadCardDomain.State.Error.idpError(idpError)

        await sut.receive(CardWallReadCardDomain.Action
            .response(.state(.signingChallenge(.error(error))))) { state in
                state.output = .signingChallenge(.error(error))
                state.destination = .alert(CardWallReadCardDomain.AlertStates.alertFor(error))
        }
    }

    func testSigningStates_HappyPath() async {
        let verifyPassthrough: PassthroughSubject<IDPExchangeToken, IDPError> = PassthroughSubject()
        let exchangeToken = IDPExchangeToken(code: "abc", sso: "def", state: "ghi", redirect: "redirect")

        idpMock.verify_Publisher = verifyPassthrough.eraseToAnyPublisher()

        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idTokenValidator = { _ in self.mockProfileValidator }
            dependencies.profilesStore.update = { _, _ in
                Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .success(self.signedChallenge)
            }
            dependencies.profileBasedSessionProvider.idTokenValidator
                = { _ in
                    Just(SuccessMockIdTokenValidator()).setFailureType(to: IDTokenValidatorError.self)
                        .eraseToAnyPublisher()
                }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(CardWallReadCardDomain.Action.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        verifyPassthrough.send(exchangeToken)
        verifyPassthrough.send(completion: .finished)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.loggedIn(IDPSessionMock.fixtureIDPToken)))) { state in
            state.output = .loggedIn(IDPSessionMock.fixtureIDPToken)
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.close))
    }

    func testSigningStates_PinError() async {
        let pinError = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 2))
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(pinError)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(CardWallReadCardDomain.Action
            .response(.state(.signingChallenge(.error(.signChallengeError(pinError)))))) { state in
                state.output = .signingChallenge(.error(.signChallengeError(pinError)))
                state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongPIN(.signChallengeError(pinError)))
        }
    }

    func testSigningStates_CanError() async {
        let canError = NFCSignatureProviderError.wrongCAN(GenericTestError.genericError)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(canError)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action
                .response(.state(.signingChallenge(.error(.signChallengeError(canError)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(canError)))
            state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongCAN(.signChallengeError(canError)))
        }
    }

    func testSigningStates_Error_To_Report() async {
        let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    @available(iOS 18.0, *)
    func testSendingMail() async {
        let openedURL = Mutex<URL?>(nil)

        await withDependencies { dependencies in
            dependencies.dateProvider = { Date() }
            dependencies.openURLHandler.canOpenURL = { _ in true }
            dependencies.openURLHandler.open = { url in
                openedURL.withLock { $0 = url }
            }
        } operation: {
            let sut = testStore(initialState: .init(
                profileId: defaultState.profileId, // mockUserSession.profileId,
                pin: "123456",
                loginOption: .withoutBiometry,
                output: .idle,
                destination: .alert(.info(.init(title: { TextState("dummy") })))
            ))

            let error = NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
            let report = CardWallReadCardDomain.createNfcReadingReport(with: error, commands: [])
            let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: report)
            let expectedUrl = mailState.createEmailUrl()

            expect(openedURL.withLock { $0 }).to(beNil())
            await sut.send(.destination(.presented(.alert(.openMail(report)))))
            expect(openedURL.withLock { $0 }).to(equal(expectedUrl))
        }
    }

    func testUpdateProfileSaveError() async {
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.profilesStore.update = { _, _ in
                Fail(error: .notImplemented).eraseToAnyPublisher()
            }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .success(self.signedChallenge)
            }
            dependencies.profileBasedSessionProvider.idTokenValidator
                = { _ in
                    Just(SuccessMockIdTokenValidator()).setFailureType(to: IDTokenValidatorError.self)
                        .eraseToAnyPublisher()
                }
        }

        let idpToken = IDPSessionMock.fixtureIDPToken
        await sut.send(.signChallenge)
        await uiScheduler.advance()

        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        await sut.receive(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(idpToken)
        }
        await uiScheduler.run()
        await uiScheduler.advance()
        await sut.receive(.saveError(.notImplemented)) { state in
            state.destination = .alert(CardWallReadCardDomain.AlertStates.saveProfile)
        }
    }

    func testValidateProfileFailure() async {
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.profilesStore.update = { _, _ in
                Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .success(self.signedChallenge)
            }
            dependencies.profileBasedSessionProvider.idTokenValidator = { _ in
                Just(SuccessMockIdTokenValidator()).setFailureType(to: IDTokenValidatorError.self).eraseToAnyPublisher()
            }
        }

        let expectedInternalError = IDTokenValidatorError.profileNotMatchingInsuranceId("X12345")
        idpMock.exchange_Publisher = Fail(
            error: .unspecified(error: expectedInternalError)
        ).eraseToAnyPublisher()

        await sut.send(.signChallenge)
        await uiScheduler.advance()

        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(.response(.state(.verifying(.loading)))) { state in
            state.output = .verifying(.loading)
        }
        await sut.receive(.response(.state(.verifying(.error(.profileValidation(expectedInternalError)))))) { state in
            state.output = .verifying(.error(.profileValidation(expectedInternalError)))
            state
                .destination = .alert(CardWallReadCardDomain.AlertStates
                    .alertFor(CardWallReadCardDomain.State.Error.profileValidation(expectedInternalError)))
        }
    }

    func testExpectedErrorAlertForPasswordNotFound() async {
        let error = NFCSignatureProviderError.verifyCardError(.passwordNotFound)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
            dependencies.profileBasedSessionProvider.idTokenValidator = { _ in
                Just(SuccessMockIdTokenValidator()).setFailureType(to: IDTokenValidatorError.self).eraseToAnyPublisher()
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForPasswordNotUsable() async {
        let error = NFCSignatureProviderError.verifyCardError(.passwordNotUsable)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForSecurityStatusNotSatisfied() async {
        let error = NFCSignatureProviderError.verifyCardError(.securityStatusNotSatisfied)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForMemoryFailure() async {
        let error = NFCSignatureProviderError.verifyCardError(.memoryFailure)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForUnknownFailure() async {
        let error = NFCSignatureProviderError.verifyCardError(.unknownFailure)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertWithReportButton(error: error))
        }
    }

    func testExpectedErrorAlertForWrongPIN() async {
        let error = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 2))
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.wrongPIN(stateError))
        }
    }

    func testExpectedErrorAlertForWrongPINAndNoRetry() async {
        let error = NFCSignatureProviderError.verifyCardError(.wrongSecretWarning(retryCount: 0))
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }

        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(.signChallengeError(error)))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertBlockedCard(stateError))
        }
    }

    func testExpectedErrorAlertForPasswordBlocked() async {
        let error = NFCSignatureProviderError.verifyCardError(.passwordBlocked)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpMock }
            dependencies.nfcSignatureProvider.sign = { _, _, _, _ in
                .failure(error)
            }
        }

        let stateError = CardWallReadCardDomain.State.Error.signChallengeError(error)
        await sut.send(.signChallenge)
        await uiScheduler.advance()
        await sut.receive(.response(.state(.signingChallenge(.loading)))) { state in
            state.output = .signingChallenge(.loading)
        }
        await uiScheduler.advance()
        await sut.receive(
            CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(stateError))))
        ) { state in
            state.output = .signingChallenge(.error(.signChallengeError(error)))

            state.destination = .alert(CardWallReadCardDomain.AlertStates.alertBlockedCard(stateError))
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
        var profile = Profile(
            name: "Profil 1",
            shouldAutoUpdateNameAtNextLogin: true
        )
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            }
            dependencies.profilesStore.update = { _, mutating in
                mutating(&profile)
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }

        await sut.send(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(self.idpToken)
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.close))

        expect(profile.name) == "Heinz Hillbert Cördes"
    }

    func testSaveProfileWithDefaultNameLoggedInBefore() async {
        var profile = Profile(name: "Profil 1", lastAuthenticated: Date.distantPast)
        let sut = testStore(initialState: defaultState) { dependencies in
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            }
            dependencies.profilesStore.update = { _, mutating in
                mutating(&profile)
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }

        await sut.send(.response(.state(.loggedIn(idpToken)))) { state in
            state.output = .loggedIn(self.idpToken)
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.close))

        expect(profile.name) == "Profil 1"
    }
}

enum GenericTestError: Error {
    case genericError
}

struct SuccessMockIdTokenValidator: IDTokenValidator {
    func validate(idToken _: TokenPayload.IDTokenPayload) -> Result<Bool, any Error> {
        .success(true)
    }
}

struct FailureMockIdTokenValidator: IDTokenValidator {
    func validate(idToken _: TokenPayload.IDTokenPayload) -> Result<Bool, any Error> {
        .failure(GenericTestError.genericError)
    }
}
