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
import Foundation
import HTTPClient
@testable import IDP
import Nimble
import TestUtils
import TrustStore
import XCTest

let token = "test-token"

final class IDPInterceptorTests: XCTestCase {
    let trustStoreSessionMock: TrustStoreSessionMock = {
        let mock = TrustStoreSessionMock()
        mock.validateCertificateReturnValue = Just(true).setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()
        return mock
    }()

    let extAuthRequestStorageMock = ExtAuthRequestStorageMock()

    func testInterceptWithoutDelegate() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: MemStorage(accessToken: token),
            schedulers: TestSchedulers(compute: DispatchQueue.test.eraseToAnyScheduler()),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)

        let sut = session.httpInterceptor(delegate: nil)
        sut.intercept(chain: chain)
            .test(expectations: { _, _, _ in
                expect(chain.incomingProceedRequests.count) == 1
                expect(chain.incomingProceedRequests[0].allHTTPHeaderFields?["Authorization"]) == "Bearer \(token)"
            })
    }

    func testInterceptWithoutDelegateAndNoToken() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: MemStorage(token: nil),
            schedulers: TestSchedulers(),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)

        let sut = session.httpInterceptor(delegate: nil)
        sut.intercept(chain: chain)
            .test(failure: { error in
                expect(error.isIDPTokenUnavailable) == true // Wrong error type when false
            }) { _, _, _ in
                fail("Test should have failed")
            }
    }

    func testInterceptWithDelegate() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: MemStorage(accessToken: token),
            schedulers: TestSchedulers(compute: DispatchQueue.test.eraseToAnyScheduler()),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let delegate = TestDelegate()
        delegate.shouldAuthorize = true

        let sut = session.httpInterceptor(delegate: delegate)
        sut.intercept(chain: chain)
            .test(expectations: { _, _, _ in
                expect(chain.incomingProceedRequests.count) == 1
                expect(chain.incomingProceedRequests[0].allHTTPHeaderFields?["Authorization"]) == "Bearer \(token)"
                expect(delegate.incomingRequests.count) == 1
                expect(delegate.incomingRequests[0]) == request
            })
    }

    func testInterceptWithDelegateReturningTrueAndNoToken() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: MemStorage(token: nil),
            schedulers: TestSchedulers(),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let delegate = TestDelegate()
        delegate.shouldAuthorize = true

        let sut = session.httpInterceptor(delegate: delegate)
        sut.intercept(chain: chain)
            .test(failure: { error in
                // assert error
                expect(error.isIDPTokenUnavailable) == true // Wrong error type when false
                expect(delegate.incomingRequests.count) == 1
                expect(delegate.incomingRequests[0]) == request
            }) { _, _, _ in
                fail("Test should have failed")
            }
    }

    func testInterceptWithDelegateReturningFalseAndNoToken() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: NoTokenStorage(),
            schedulers: TestSchedulers(),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let delegate = TestDelegate()
        delegate.shouldAuthorize = false

        let sut = session.httpInterceptor(delegate: delegate)
        sut.intercept(chain: chain)
            .test(expectations: { _, _, _ in
                expect(chain.incomingProceedRequests.count) == 1
                expect(chain.incomingProceedRequests[0].allHTTPHeaderFields?["Authorization"]).to(beNil())
                expect(delegate.incomingRequests[0]) == request
                expect(delegate.incomingRequests.count) == 1
            })
    }

    func testInterceptWithDelegateReturningFalse() {
        let idpClientMock = IDPClientMock()
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: MemStorage(accessToken: token),
            schedulers: TestSchedulers(),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let delegate = TestDelegate()
        delegate.shouldAuthorize = false

        let sut = session.httpInterceptor(delegate: delegate)
        sut.intercept(chain: chain)
            .test(expectations: { _, _, _ in
                expect(chain.incomingProceedRequests.count) == 1
                expect(chain.incomingProceedRequests[0].allHTTPHeaderFields?["Authorization"]).to(beNil())
                expect(delegate.incomingRequests[0]) == request
                expect(delegate.incomingRequests.count) == 1
            })
    }

    func testCallWith401UnauthorizedResponseInvalidatesAccessToken() {
        let idpClientMock = IDPClientMock()
        let storage = MemStorage(accessToken: token)
        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: TestSchedulers(),
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let delegate = TestDelegate()
        delegate.shouldAuthorize = true

        let sut = session.httpInterceptor(delegate: delegate)

        storage.token.first().test(expectations: { token in
            expect(token).toNot(beNil())
        })

        chain.httpResponse = HTTPResponse(
            data: Data(),
            response: HTTPURLResponse(),
            status: HTTPStatusCode.unauthorized
        )

        sut.intercept(chain: chain)
            .test(expectations: { _, _, _ in
                expect(chain.incomingProceedRequests.count) == 1
                expect(chain.incomingProceedRequests[0].allHTTPHeaderFields?["Authorization"]) == "Bearer \(token)"
                expect(delegate.incomingRequests[0]) == request
                expect(delegate.incomingRequests.count) == 1
            })

        storage.token.first().test(expectations: { token in
            expect(token).to(beNil())
        })
    }
}

class NoTokenStorage: IDPStorage {
    var tokenState: CurrentValueSubject<IDPToken?, Never> = CurrentValueSubject(nil)

    var token: AnyPublisher<IDPToken?, Never> {
        tokenState.eraseToAnyPublisher()
    }

    func set(token _: IDPToken?) {
        fail("set(token:) should not have been called")
    }

    @Published var discoveryDocumentState: DiscoveryDocument?
    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        $discoveryDocumentState.eraseToAnyPublisher()
    }

    func set(discovery doc: DiscoveryDocument?) {
        discoveryDocumentState = doc
    }
}

extension HTTPError {
    var isIDPTokenUnavailable: Bool {
        guard case let .authentication(err) = self, let idpError = err as? IDPError,
              case IDPError.tokenUnavailable = idpError else {
            return false
        }
        return true
    }
}

extension IDPInterceptorTests {
    class TestDelegate: IDPSessionDelegate {
        var incomingRequests = [URLRequest]()
        var shouldAuthorize = false

        func shouldAuthorize(request: URLRequest) -> Bool {
            incomingRequests.append(request)
            return shouldAuthorize
        }
    }
}
