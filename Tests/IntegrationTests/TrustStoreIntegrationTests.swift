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
import DataKit
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
    func testCompleteFlow() throws {
        var environment: IntegrationTestsConfiguration!

        if let integrationTestsEnvironmentString = ProcessInfo.processInfo.environment["APP_CONF"],
           let integrationTestsEnvironment = integrationTestsAppConfigurations[integrationTestsEnvironmentString] {
            environment = integrationTestsEnvironment
        } else {
            environment = integrationTestsEnvironmentDummy // change me for manual testing
        }
        if environment.appConfiguration == integrationTestsEnvironmentGMTKDEV.appConfiguration {
            throw XCTSkip("Skip test because FD components in gematik_dev environment are unstable.")
        }

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
}
