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
@testable import eRpFeatures
import Foundation
import HTTPClient
import HTTPClientLive
import Nimble
import OpenSSL
import TestUtils
@testable import TrustStore
import XCTest

/// Runs TrustStore Integration Tests.
/// Set `APP_CONF` in runtime environment to setup the execution environment.
final class TrustStoreIntegrationTests: XCTestCase {
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

    func testCompleteFlow() {
        let storage = MemStorage()
        let session = DefaultTrustStoreSession(
            serverURL: environment.appConfiguration.erp,
            trustAnchor: environment.appConfiguration.trustAnchor,
            trustStoreStorage: storage,
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                    LoggingInterceptor(log: .body),
                ]
            )
        )
        var success = false
        session.loadVauCertificate()
            .test(
                timeout: 120,
                failure: { error in
                    fail("Failed with error: \(error)")
                },
                expectations: { vauCertificate in
                    success = true
                    Swift.print("vauCertificate", (vauCertificate.derBytes?.base64EncodedString()) ?? "")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(success) == true
    }

    func testCompleteFlow_async() async throws {
        let storage = MemStorage()
        let session = DefaultTrustStoreSession(
            serverURL: environment.appConfiguration.erp,
            trustAnchor: environment.appConfiguration.trustAnchor,
            trustStoreStorage: storage,
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                    LoggingInterceptor(log: .body),
                ]
            )
        )

        let vauCertificate = try await session.vauCertificate()
        Swift.print("vauCertificate", (vauCertificate.derBytes?.base64EncodedString()) ?? "")
    }

    func testPKICertificatesEndpointsFlow() async throws {
        // There are several possible arguments as "currentRoot" possible that we want to test.
        let currentRoots: [String]
        let currentRootsTestEnvironment = [
            "GEM.RCA3 TEST-ONLY",
            "GEM.RCA4 TEST-ONLY",
            "GEM.RCA5 TEST-ONLY",
            "GEM.RCA6 TEST-ONLY",
        ]
        let currentRootsProdEnvironment = [
            "GEM.RCA3",
            "GEM.RCA4",
            "GEM.RCA5",
            "GEM.RCA6",
        ]
        if environment.appConfiguration == integrationTestsEnvironmentTU.appConfiguration
            || environment.appConfiguration == integrationTestsEnvironmentRU.appConfiguration
            || environment.appConfiguration == integrationTestsEnvironmentRUDev.appConfiguration {
            currentRoots = currentRootsTestEnvironment
        } else if environment.appConfiguration == integrationTestsEnvironmentPU.appConfiguration {
            currentRoots = currentRootsProdEnvironment
        } else {
            throw XCTSkip("No currentRoots found for this environment")
        }

        let realTrustStoreClient = RealTrustStoreClient(
            serverURL: environment.appConfiguration.erp,
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.erpAdditionalHeader),
                    LoggingInterceptor(log: .body),
                ]
            )
        )

        for rootSubjectCn in currentRoots {
            let pkiCertificates = try await realTrustStoreClient
                .loadPKICertificatesFromServer(rootSubjectCn: rootSubjectCn)
            expect(pkiCertificates.caCerts.count) > 0
        }

        // Load VAU certificate
        let vauCertificateResponse = try await realTrustStoreClient.loadVauCertificateFromServer()
        expect(vauCertificateResponse.count) > 0

        // Load VAU certificate OCSP response
        let vauCertificate = try X509(der: vauCertificateResponse)
        let issuerCn = try vauCertificate.issuerCn()
        let serialNr = try vauCertificate.serialNumber()
        let vauCertificateOSCPResponse = try await realTrustStoreClient.loadOcspResponseFromServer(
            issuerCn: issuerCn,
            serialNr: serialNr
        )
        expect(vauCertificateOSCPResponse.count) > 0
    }
}
