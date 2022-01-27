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
import IDP
import Nimble
import TestUtils
import XCTest

final class ExtAuthPendingDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ExtAuthPendingDomain.State,
        ExtAuthPendingDomain.State,
        ExtAuthPendingDomain.Action,
        ExtAuthPendingDomain.Action,
        ExtAuthPendingDomain.Environment
    >

    var idpSessionMock: IDPSessionMock!
    var extAuthRequestStorageMock: ExtAuthRequestStorageMock!

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
    }

    func testStore(for state: ExtAuthPendingDomain.State)
        -> TestStore {
        TestStore(
            initialState: state,
            reducer: ExtAuthPendingDomain.reducer,
            environment: .init(idpSession: idpSessionMock,
                               schedulers: schedulers,
                               extAuthRequestStorage: extAuthRequestStorageMock)
        )
    }

    func testStore()
        -> TestStore {
        testStore(for: .init())
    }

    func testNoRequestsResultsInEmptyState() {
        let sut = testStore(for: .pendingExtAuth(KKAppDirectory.Entry(name: "", identifier: "")))
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([]).eraseToAnyPublisher()

        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived([])) { state in
            state = .empty
        }
    }

    func testEntriesResultInPendingState() {
        let sut = testStore(for: .empty)
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived([session])) { state in
            state = .pendingExtAuth(healthInsurance)
        }
    }

    func testExternalURLFiresIDPRequestHappyPath() {
        let sut = testStore(for: .empty)
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived([session])) { state in
            state = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Just(IDPToken(
                accessToken: "SECRET ACCESSTOKEN",
                expires: Date(),
                idToken: "IDP TOKEN",
                ssoToken: "SSO TOKEN",
                tokenType: "type"
            ))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        sut.send(.externalLogin(urlFixture)) { state in
            state = .extAuthReceived(healthInsurance)
        }
        uiScheduler.run()
        sut.receive(.externalLoginReceived(.success(true))) { state in
            state = .extAuthSuccessful(healthInsurance)
        }
        uiScheduler.run()
        sut.receive(.hide) { state in
            state = .empty
        }
    }

    func testExternalURLFiresIDPRequestHappyPathWithState() {
        let sut = testStore(for: .empty)
        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived([session])) { state in
            state = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de?state=hallo")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Just(IDPToken(
                accessToken: "SECRET ACCESSTOKEN",
                expires: Date(),
                idToken: "IDP TOKEN",
                ssoToken: "SSO TOKEN",
                tokenType: "type"
            ))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        let requestingKK = KKAppDirectory.Entry(name: "Requested KK", identifier: "1234")
        let actualSessionResponse = ExtAuthChallengeSession(verifierCode: "code", nonce: "nonce", for: requestingKK)
        extAuthRequestStorageMock.getExtAuthRequestForReturnValue = actualSessionResponse
        sut.send(.externalLogin(urlFixture)) { state in
            state = .extAuthReceived(requestingKK)
        }
        uiScheduler.run()
        sut.receive(.externalLoginReceived(.success(true))) { state in
            state = .extAuthSuccessful(requestingKK)
        }
        uiScheduler.advance(by: .seconds(2.1))
        sut.receive(.hide) { state in
            state = .empty
        }
    }

    func testExternalURLFiresIDPRequestFailurePath() {
        let sut = testStore(for: .empty)
        let healthInsurance = KKAppDirectory.Entry(name: "Gematik KK", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived([session])) { state in
            state = .pendingExtAuth(healthInsurance)
        }
        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.extAuthVerifyAndExchange_Publisher =
            Fail(error: IDPError.extAuthOriginalRequestMissing).eraseToAnyPublisher()

        sut.send(.externalLogin(urlFixture)) { state in
            state = .extAuthReceived(healthInsurance)
        }
        uiScheduler.run()
        sut.receive(.externalLoginReceived(.failure(.idpError(.extAuthOriginalRequestMissing, urlFixture)))) { state in
            state = .extAuthFailed(
                ExtAuthPendingDomain.alertState(
                    title: healthInsurance.name,
                    message: "Error while processing external authentication: original request not found.",
                    url: urlFixture
                )
            )
        }
    }

    func testCancelPendingRequestsRemovesCorrectly() {
        let healthInsurance = KKAppDirectory.Entry(name: "Gematik KK", identifier: "123")
        let sut = testStore(for: .pendingExtAuth(healthInsurance))

        let pendingRequests = [
            ExtAuthChallengeSession(verifierCode: "VerifierCode1",
                                    nonce: "nonce1",
                                    for: healthInsurance),
            ExtAuthChallengeSession(verifierCode: "VerifierCode2",
                                    nonce: "nonce2",
                                    for: healthInsurance),
        ]
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = CurrentValueSubject(pendingRequests)
            .eraseToAnyPublisher()
        sut.send(.registerListener)
        uiScheduler.run()
        sut.receive(.pendingExtAuthRequestsReceived(pendingRequests)) { state in
            state = .pendingExtAuth(healthInsurance)
        }
        expect(self.extAuthRequestStorageMock.resetCalled).to(beFalse())
        sut.send(.cancelAllPendingRequests) { state in
            state = .empty
        }
        expect(self.extAuthRequestStorageMock.resetCalled).to(beTrue())
        sut.send(.unregisterListener)
    }

    func testCloseNilsTheState() {
        let sut = testStore(for: .pendingExtAuth(KKAppDirectory.Entry(name: "Gematik KK", identifier: "123")))

        sut.send(.hide) { state in
            state = .empty
        }
    }

    func testExistingEntriesMovingToZeroKeepsSuccessStateForAnimation() {
        let requestingKK = KKAppDirectory.Entry(name: "Requested KK", identifier: "1234")

        let sut = testStore(for: .empty)

        let healthInsurance = KKAppDirectory.Entry(name: "KK name", identifier: "kk id")
        let session = ExtAuthChallengeSession(verifierCode: "VerifierCode",
                                              nonce: "nonce",
                                              for: healthInsurance)
        extAuthRequestStorageMock.underlyingPendingExtAuthRequests = Just([session]).eraseToAnyPublisher()

        sut.send(.registerListener)

        uiScheduler.run()

        sut.receive(.pendingExtAuthRequestsReceived([session])) { state in
            state = .pendingExtAuth(healthInsurance)
        }

        let actualSessionResponse = ExtAuthChallengeSession(verifierCode: "code", nonce: "nonce", for: requestingKK)

        let publisher = CurrentValueSubject<[ExtAuthChallengeSession], Never>([actualSessionResponse])
        extAuthRequestStorageMock.pendingExtAuthRequests = publisher.eraseToAnyPublisher()

        publisher.send([])

        uiScheduler.advance(by: .seconds(2.1))
    }
}
