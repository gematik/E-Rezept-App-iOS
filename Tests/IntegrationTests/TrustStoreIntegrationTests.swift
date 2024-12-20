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
import Foundation
import HTTPClient
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

    func testPKICertificatesEndpointsFlow() async throws {
        // Note: Work in progress. For now test only RealTrustStoreClient instead of DefaultTrustStoreSession
        guard environment.appConfiguration != integrationTestsEnvironmentPU.appConfiguration else {
            throw XCTSkip("Skip test because of faulty server side behavior in PU")
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
        let trustAnchor = environment.appConfiguration.trustAnchor

        // Load PKI certificates
        let rootSubjectCn = try trustAnchor.certificate.subjectCN()
        let pkiCertificates = try await realTrustStoreClient
            .loadPKICertificatesFromServer(rootSubjectCn: rootSubjectCn)
        expect(pkiCertificates.caCerts.count) > 0

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

extension X509 {
    // These helper methods will be moved to the module's code eventually
    func issuerCn() throws -> String {
        // this is a "bit" sketchy...
        // issuerOneLine() should be rather treated as a debug method
        // and parsing should probably not rely on a string representation of issuerOneLine, maybe look at:
        // let issuerX500PrincipalDEREncoded = try vauCertificate.issuerX500PrincipalDEREncoded()
        let issuerOneLine = try issuerOneLine()
        let split = issuerOneLine.split(separator: "/CN=")
        return String(split.last!)
    }

    func subjectCN() throws -> String {
        // Note: same implementation issues as issuerCN
        let subjectOneLine = try subjectOneLine()
        let split = subjectOneLine.split(separator: "/CN=")
        return String(split.last!)
    }
}
