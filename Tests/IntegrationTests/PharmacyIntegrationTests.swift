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
import Dependencies
@testable import eRpFeatures
import eRpKit
import FHIRClient
import FHIRVZD
import Foundation
import HTTPClient
import Nimble
import Pharmacy
import XCTest

/// Runs Pharmacy (Apotheken Verzeichnis) Integration Tests.
/// Set `APP_CONF` in runtime environment to setup the execution environment.
final class PharmacyIntegrationTests: XCTestCase {
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
        withDependencies {
            $0.context = .live
        } operation: {
            let mockPharmacyLocalDataStore = MockPharmacyLocalDataStore()
            mockPharmacyLocalDataStore.listPharmaciesCountReturnValue = Just([])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let sut: PharmacyRepository = DefaultPharmacyRepository(
                disk: mockPharmacyLocalDataStore,
                cloud: HealthcareServiceFHIRDataSource(
                    fhirClient: FHIRClient(
                        server: environment.appConfiguration.fhirVzd,
                        httpClient: DefaultHTTPClient(
                            urlSessionConfiguration: .ephemeral,
                            interceptors: [
                                AdditionalHeaderInterceptor(
                                    additionalHeader: environment.appConfiguration.fhirVzdAdditionalHeader
                                ),
                                LoggingInterceptor(log: .body),
                            ]
                        ),
                        // use a receiveQueue that is not main since that one is blocked by the test()'s semaphore
                        receiveQueue: DispatchQueue.global().eraseToAnyScheduler()
                    ),
                    session: DefaultFHIRVZDSession(
                        config: FHIRVZDClient.Configuration(
                            eRezeptAPIServer: environment.appConfiguration.eRezept,
                            eRezeptAdditionalHeader: environment.appConfiguration.eRezeptAdditionalHeader
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
                    }
                )
            expect(success) == true
        }
    }
}
