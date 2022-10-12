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
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import IDP
import Nimble
import TestUtils
import TrustStore
import VAUClient
import XCTest

/// Runs ErxTaskFHIRDataStore client (Fachdienst) Integration Tests.
/// Set `APP_CONF` in runtime environment to setup the execution environment.
final class ErxTaskFHIRDataStoreIntegrationTests: XCTestCase {
    var environment: IntegrationTestsEnvironment!

    override func setUp() {
        super.setUp()

        if let integrationTestsEnvironmentString = ProcessInfo.processInfo.environment["APP_CONF"],
           let integrationTestsEnvironment = integrationTestsAppConfigurations[integrationTestsEnvironmentString] {
            environment = integrationTestsEnvironment
        } else {
            environment = integrationTestsEnvironmentDummy // change me for manual testing
        }
    }

    func testCompleteFlow() throws {
        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let memStorage = MemStorage()

        // TrustStore Session
        let trustStoreSession = DefaultTrustStoreSession(
            serverURL: environment.appConfiguration.erp,
            trustAnchor: environment.appConfiguration.trustAnchor,
            trustStoreStorage: memStorage,
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                    LoggingInterceptor(log: .body),
                ]
            )
        )

        // IDP Session
        let idpSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: environment.appConfiguration.idpDefaultScopes
        )

        let idpSession = DefaultIDPSession(
            config: idpSessionConfiguration,
            storage: memStorage,
            schedulers: schedulers,
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.idpAdditionalHeader),
                    LoggingInterceptor(log: .body),
                ]
            ),
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: PersistentExtAuthRequestStorage()
        )

        // VAU Session
        let vauAccessTokenProvider = IntegrationTestsIDPSessionTokenProvider(
            idpSession: idpSession,
            signer: signer
        )

        var vauAccessTokenProviderSuccess = false
        vauAccessTokenProvider.vauBearerToken
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)")
                },
                expectations: { vauBearerToken in
                    vauAccessTokenProviderSuccess = true
                    Swift.print("vauBearerToken", vauBearerToken)

                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(vauAccessTokenProviderSuccess) == true

        let vauSession = VAUSession(
            vauServer: environment.appConfiguration.erp,
            vauAccessTokenProvider: idpSession.asVAUAccessTokenProvider(),
            vauStorage: memStorage,
            trustStoreSession: trustStoreSession
        )

        // eRx task FHIR data store (Fachdienst)
        let erpHttpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                idpSession.httpInterceptor(delegate: nil),
                LoggingInterceptor(log: .body),
                vauSession.provideInterceptor(),
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )

        let fhirClient = FHIRClient(
            server: environment.appConfiguration.base,
            httpClient: erpHttpClient
        )

        let cloud = ErxTaskFHIRDataStore(fhirClient: fhirClient)

        var success = false
        cloud.listAllTasks(after: nil)
            .first()
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)")
                },
                expectations: { erxTasks in
                    success = true
                    Swift.print("erxTasks", erxTasks)
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(success) == true

        success = false

        let cancellable = cloud.listAllAuditEvents(after: nil, for: nil)
            .first()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    Swift.print(error)
                default: break
                }
                Swift.print(completion)
            }, receiveValue: { auditEvents in
                Swift.print("auditEvents: #", auditEvents.content.count)
                success = true
            })
        expect(success).toEventually(beTrue(), timeout: .seconds(300))

        cancellable.cancel()
    }
}

class IntegrationTestsIDPSessionTokenProvider: VAUAccessTokenProvider {
    let idpSession: IDPSession
    let signer: Brainpool256r1Signer

    init(idpSession: IDPSession, signer: Brainpool256r1Signer) {
        self.idpSession = idpSession
        self.signer = signer
    }

    var vauBearerToken: AnyPublisher<BearerToken, VAUError> {
        idpSession.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: self.signer, using: self.signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                self.idpSession.verifyAndExchange(signedChallenge: signedChallenge) { _ in
                    Result.success(true)
                }
            }
            .map(\.accessToken)
            .first()
            .mapError { error in
                VAUError.unspecified(error: error)
            }
            .eraseToAnyPublisher()
    }
}
