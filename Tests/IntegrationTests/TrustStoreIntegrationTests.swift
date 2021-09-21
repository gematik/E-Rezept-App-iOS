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
import DataKit
import Foundation
import HTTPClient
import Nimble
import OpenSSL
import TestUtils
@testable import TrustStore
import XCTest

/// Runs TrustStore Integration Tests.
/// Set `FDV_URL` in runtime environment to setup service server url.
final class TrustStoreIntegrationTests: XCTestCase {
    func testCompleteFlow() {
        let fdvURLString = ProcessInfo.processInfo
//                .environment["FDV_URL"] ?? "https://erp.dev.gematik.solutions/fdv/"
            .environment["FDV_URL"] ?? "https://erp-ref.zentral.erp.splitdns.ti-dienste.de/"
        guard let fdvURL = URL(string: fdvURLString) else {
            fail("invalid fdv URL (injected?)")
            return
        }

        let storage = MemStorage()
        let session = DefaultTrustStoreSession(
            serverURL: fdvURL,
            trustStoreStorage: storage,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .ephemeral,
                                          interceptors: [
                                          ])
        )
        var success = false
        session.loadVauCertificate()
            .test(
                timeout: 20,
                expectations: { vauCertificate in
                    success = true
                    Swift.print("vauCertificate", (vauCertificate.derBytes?.base64EncodedString()) ?? "")
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(success) == true
    }
}
