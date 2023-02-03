//
//  Copyright (c) 2023 gematik GmbH
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
import FHIRClient
import Foundation
import HTTPClient
import Nimble
import Pharmacy
import XCTest

/// Runs Pharmacy (Apotheken Verzeichnis) Integration Tests.
/// Set `APP_CONF` in runtime environment to setup the execution environment.
final class PharmacyIntegrationTests: XCTestCase {
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

    func testCompleteFlow() {
        let mockPharmacyLocalDataStore = MockPharmacyLocalDataStore()
        mockPharmacyLocalDataStore.listPharmaciesCountReturnValue = Just([]).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut: PharmacyRepository = DefaultPharmacyRepository(
            disk: mockPharmacyLocalDataStore,
            cloud: PharmacyFHIRDataSource(
                fhirClient: FHIRClient(
                    server: environment.appConfiguration.apoVzd,
                    httpClient: DefaultHTTPClient(
                        urlSessionConfiguration: .ephemeral,
                        interceptors: [
                            AdditionalHeaderInterceptor(
                                additionalHeader: environment.appConfiguration.apoVzdAdditionalHeader
                            ),
                            LoggingInterceptor(log: .body),
                        ]
                    )
                )
            )
        )

        var success = false
        sut.searchRemote(searchTerm: "Adler", position: nil, filter: [])
            .test(
                timeout: 120,
                failure: { error in
                    fail("Failed with error: \(error)")
                },
                expectations: { pharmacyLocations in
                    if !pharmacyLocations.isEmpty {
                        success = true
                    }
                    Swift.print("pharmacyLocations", pharmacyLocations)
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(success) == true
    }
}
