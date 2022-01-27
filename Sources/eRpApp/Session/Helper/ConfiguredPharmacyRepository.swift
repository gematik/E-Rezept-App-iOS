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
import FHIRClient
import Foundation
import HTTPClient
import Pharmacy

class ConfiguredPharmacyRepository: PharmacyRepository {
    private let sessionProvider: AnyPublisher<DefaultPharmacyRepository, Never>
    private var disposeBag: Set<AnyCancellable> = []

    init(
        _ configurationProvider: AnyPublisher<AppConfiguration, Never>
    ) {
        sessionProvider = configurationProvider
            .map { configuration in
                DefaultPharmacyRepository(
                    cloud: PharmacyFHIRDataSource(
                        fhirClient: FHIRClient(
                            server: configuration.apoVzd,
                            httpClient: Self.httpClient(configuration: configuration)
                        )
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    static func httpClient(configuration: AppConfiguration) -> HTTPClient {
        let interceptors: [Interceptor] = [
            AdditionalHeaderInterceptor(additionalHeader: configuration.apoVzdAdditionalHeader),
            LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
            DebugLiveLogger.LogInterceptor(),
        ]

        // Remote FHIR data source configuration
        return DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: interceptors
        )
    }

    func searchPharmacies(searchTerm: String,
                          position: Position?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        sessionProvider
            .map { $0.searchPharmacies(searchTerm: searchTerm, position: position) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
