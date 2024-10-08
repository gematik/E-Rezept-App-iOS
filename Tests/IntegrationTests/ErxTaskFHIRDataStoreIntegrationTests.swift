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
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import IdentifiedCollections
import IDP
import Nimble
import Pharmacy
import TestUtils
import TrustStore
import VAUClient
import XCTest

/// Runs ErxTaskFHIRDataStore client (Fachdienst) Integration Tests.
/// Set `APP_CONF` in runtime environment to setup the execution environment.
final class ErxTaskFHIRDataStoreIntegrationTests: XCTestCase {
    var environment: IntegrationTestsConfiguration!

    override func setUp() {
        super.setUp()

        if let integrationTestsEnvironmentString = ProcessInfo.processInfo.environment["APP_CONF"],
           let integrationTestsEnvironment = integrationTestsAppConfigurations[integrationTestsEnvironmentString] {
            environment = integrationTestsEnvironment
        } else {
            environment = integrationTestsEnvironmentDummy // change me for manual testing
        }
    }

    let memStorage = MemStorage()
    lazy var trustStoreSession: TrustStoreSession = {
        DefaultTrustStoreSession(
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
    }()

    lazy var idpSession: IDPSession = {
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())

        // IDP Session
        let idpSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: environment.appConfiguration.idpDefaultScopes
        )

        return DefaultIDPSession(
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
    }()

    lazy var cloudStorage: ErxRemoteDataStore = {
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
            httpClient: erpHttpClient,
            // use a receiveQueue that is not main since that one is blocked by the test()'s semaphore
            receiveQueue: DispatchQueue.global().eraseToAnyScheduler()
        )

        return ErxTaskFHIRDataStore(fhirClient: fhirClient)
    }()

    lazy var vauSession: VAUSession = {
        VAUSession(
            vauServer: environment.appConfiguration.erp,
            vauAccessTokenProvider: idpSession.asVAUAccessTokenProvider(),
            vauStorage: memStorage,
            trustStoreSession: trustStoreSession
        )
    }()

    func testLoadingDataFromRemote() throws {
        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let didLogin = login(with: signer)
        expect(didLogin).to(beTrue())

        _ = loadAllTasks()

        let success = loadAllAuditEvents()
        expect(success).to(beTrue())

        let didLoadCommunications = loadAllCommunications()
        expect(didLoadCommunications).to(beTrue())
    }

    func testConsentFlow() throws {
        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let didLogin = login(with: signer)
        expect(didLogin).to(beTrue())

        // trying to revoke consent precautiously in case test failed before
        cloudStorage.revokeConsent(.chargcons)
            .first()
            .replaceError(with: false)
            .test(timeout: 60.0, expectations: { _ in })

        let consent = grantConsent()
        expect(consent?.category).to(equal(.chargcons))
        expect(consent?.insuranceId).to(equal("X114428530"))

        let consents = getConsents()
        expect(consents.first).to(equal(consent))

        let didRevokeConsent = revokeConsent()
        expect(didRevokeConsent).to(beTrue())

        let consentsEmpty = getConsents()
        expect(consentsEmpty).to(beEmpty())
    }

    func redeem(_ erxTask: ErxTask) -> Bool {
        let order = erxTask.asOrder(orderId: UUID(), option: .shipment, for: testPharmacy, with: shipmentInfo)

        // eRx task FHIR data store (Fachdienst)
        let erpHttpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                idpSession.httpInterceptor(delegate: nil),
                LoggingInterceptor(log: .body),
                ExceptionInterceptor(order: order),
                vauSession.provideInterceptor(),
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )

        let fhirClient = FHIRClient(
            server: environment.appConfiguration.base,
            httpClient: erpHttpClient,
            // use a receiveQueue that is not main since that one is blocked by the test()'s semaphore
            receiveQueue: DispatchQueue.global().eraseToAnyScheduler()
        )
        let cloud = ErxTaskFHIRDataStore(fhirClient: fhirClient)

        let erxTaskRepository = DefaultErxTaskRepository(
            disk: MockErxLocalDataStore(),
            cloud: cloud,
            medicationScheduleRepository: .testValue,
            profile: Just(Profile(name: "Test User")).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        )

        let redeemService = ErxTaskRepositoryRedeemService(
            erxTaskRepository: erxTaskRepository,
            loginHandler: DefaultLoginHandler(
                idpSession: idpSession,
                signatureProvider: DefaultSecureEnclaveSignatureProvider(storage: memStorage)
            )
        )

        var receivedOrderResponses: [IdentifiedArrayOf<OrderResponse>] = []
        // Actual redeem call
        var success = false
        let cancellable = redeemService.redeem([order])
            .first()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    fail("expected to receive a response ")
                    success = false
                    Swift.print(error)
                default: break
                }
                Swift.print(completion)
            }, receiveValue: { orderResponses in
                receivedOrderResponses.append(orderResponses)
                Swift.print("✅ Sent \(orderResponses.count) erxTask orders")
            })

        expect(receivedOrderResponses.count).toEventually(equal(1))
        if let orderResponses = receivedOrderResponses.first {
            expect(orderResponses.count) == 1
            expect(orderResponses.first) == OrderResponse(requested: order, result: ProgressResponse.success(true))
            success = true
        } else {
            fail("expected to have an orderResponse in the received order Resposes array")
        }

        cancellable.cancel()
        return success
    }

    private func login(with signer: Brainpool256r1Signer) -> Bool {
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
                    Swift.print("✅ Loaded vauBearerToken:", vauBearerToken)
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(vauAccessTokenProviderSuccess).toEventually(equal(true))
        return vauAccessTokenProviderSuccess
    }

    private func loadAllTasks(file: FileString = #file, line: UInt = #line) -> [ErxTask] {
        var success = false
        var finished = false
        var receivedErxTasks: [ErxTask] = []
        cloudStorage.listAllTasks(after: nil)
            .first()
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)", file: file, line: line)
                    finished = true
                },
                expectations: { tasks in
                    receivedErxTasks = tasks.content
                    success = true
                    finished = true
                    Swift.print("✅ Loaded \(tasks.content.count) erxTasks!")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )

        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        return receivedErxTasks
    }

    private func loadAllAuditEvents(file: FileString = #file, line: UInt = #line) -> Bool {
        var finished = false
        var success = false

        let cancellable = cloudStorage.listAllAuditEvents(after: nil, for: nil)
            .first()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    Swift.print(error)
                default: break
                }
                Swift.print(completion)
                finished = true
            }, receiveValue: { auditEvents in
                Swift.print("✅ Loaded \(auditEvents.content.count) auditEvents!")
                success = true
                finished = true
            })
        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        cancellable.cancel()
        return success
    }

    private func loadAllCommunications(file: FileString = #file, line: UInt = #line) -> Bool {
        var finished = false
        var success = false

        let cancellable = cloudStorage.listAllCommunications(after: nil, for: .all)
            .first()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    Swift.print(error)
                default: break
                }
                Swift.print(completion)
                finished = true
            }, receiveValue: { communications in
                Swift.print("✅ Loaded \(communications.count) communications!")
                success = true
                finished = true
            })
        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        cancellable.cancel()
        return success
    }

    private func getConsents(file: FileString = #file, line: UInt = #line) -> [ErxConsent] {
        var finished = false
        var success = false
        var receivedConsents = [ErxConsent]()

        cloudStorage.fetchConsents()
            .first()
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)", file: file, line: line)
                    finished = true
                },
                expectations: { consents in
                    receivedConsents = consents
                    success = true
                    finished = true
                    Swift.print("✅ Loaded \(receivedConsents.count) consents!")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        return receivedConsents
    }

    private func grantConsent(file: FileString = #file, line: UInt = #line) -> ErxConsent? {
        var finished = false
        var success = false
        var receivedConsent: ErxConsent?

        let kvnr = "X114428530"
        let consent = ErxConsent(
            identifier: "\(ErxConsent.Category.chargcons.rawValue)-\(kvnr)",
            insuranceId: kvnr,
            timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
            scope: .patientPrivacy,
            category: .chargcons,
            policyRule: .optIn
        )

        cloudStorage.grantConsent(consent)
            .first()
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)", file: file, line: line)
                    finished = true
                },
                expectations: { consent in
                    receivedConsent = consent
                    success = true
                    finished = true
                    Swift.print("✅ Consent granted!")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        return receivedConsent
    }

    private func revokeConsent(file: FileString = #file, line: UInt = #line) -> Bool {
        var finished = false
        var success = false

        let consentCategory = ErxConsent.Category.chargcons

        cloudStorage.revokeConsent(consentCategory)
            .first()
            .test(
                timeout: 300,
                failure: { error in
                    fail("Failed with error: \(error)", file: file, line: line)
                    finished = true
                },
                expectations: { result in
                    success = result
                    finished = true
                    Swift.print("✅ Revoked \(consentCategory.rawValue) consent!")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(file: file, line: line, finished).toEventually(beTrue(), timeout: .seconds(300))
        expect(file: file, line: line, success).to(beTrue())
        return success
    }

    // swiftlint:disable line_length
    class ExceptionInterceptor: Interceptor {
        let order: OrderRequest

        init(order: OrderRequest) {
            self.order = order
        }

        func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
            if chain.request.url!.absoluteString.contains("Communication"),
               let body = chain.request.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                expect(bodyString) == """
                {"basedOn":[{"reference":"Task\\/\(order.taskID)\\/$accept?ac=\(order
                    .accessCode)"}],"identifier":[{"system":"https:\\/\\/gematik.de\\/fhir\\/NamingSystem\\/OrderID","value":"\(order
                    .orderID)"}],"meta":{"profile":["https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_PR_Communication_DispReq|1.2"]},"payload":[{"contentString":"{\\"address\\":[\\"Intergation Test Str. 1\\",\\"Address Details\\",\\"12345\\",\\"Berlin\\"],\\"hint\\":\\"Please use the key\\",\\"name\\":\\"Integration Test\\",\\"phone\\":\\"01772345674\\",\\"supplyOptionsType\\":\\"\(order
                    .redeemType
                    .rawValue)\\",\\"version\\":1}"}],"recipient":[{"identifier":{"system":"https:\\/\\/gematik.de\\/fhir\\/sid\\/telematik-id","value":"3-SMC-B-Testkarte-883110000094055"}}],"resourceType":"Communication","status":"unknown"}
                """
            }
            return chain.proceed(request: chain.request)
                .map { response in
                    if response.response.url!.absoluteString.contains("Communication"),
                       response.status.rawValue == 201,
                       let dataString = String(data: response.data, encoding: .utf8) {
                        expect(
                            dataString.contains(
                                """
                                "payload":[{"contentString":"{\\"address\\":[\\"Intergation Test Str. 1\\",\\"Address Details\\",\\"12345\\",\\"Berlin\\"],\\"hint\\":\\"Please use the key\\",\\"name\\":\\"Integration Test\\",\\"phone\\":\\"01772345674\\",\\"supplyOptionsType\\":\\"shipment\\",\\"version\\":1}"}]
                                """
                            )
                        ).to(beTrue())
                    }
                    return response
                }
                .eraseToAnyPublisher()
        }
    }

    // swiftlint:enable line_length

    let shipmentInfo = ShipmentInfo(
        name: "Integration Test",
        street: "Intergation Test Str. 1",
        addressDetail: "Address Details",
        zip: "12345",
        city: "Berlin",
        phone: "01772345674",
        mail: "mail@gematik.de",
        deliveryInfo: "Please use the key"
    )

    let testPharmacy = PharmacyLocation(
        id: "test",
        status: .active,
        telematikID: "3-SMC-B-Testkarte-883110000094055",
        name: "Adler ApothekeTEST-ONLY",
        types: [.pharm, .outpharm, .mobl],
        hoursOfOperation: []
    )
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
