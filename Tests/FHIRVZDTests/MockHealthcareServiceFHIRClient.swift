//
//  Copyright (c) 2025 gematik GmbH
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
import eRpKit
import FHIRClient
@testable import FHIRVZD
import Foundation
import Pharmacy

class MockHealthcareServiceFHIRClient: HealthcareServiceFHIRClient {
    var searchPharmaciesCallback: ((String, Pharmacy.Position?, [PharmacyRemoteDataStoreFilter], String?)
        -> AnyPublisher<[PharmacyLocation], FHIRClient.Error>)?

    func searchPharmacies(
        by searchTerm: String,
        position: Pharmacy.Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        accessToken: String?
    ) -> AnyPublisher<[PharmacyLocation], FHIRClient.Error> {
        if let searchPharmaciesCallback {
            return searchPharmaciesCallback(searchTerm, position, filter, accessToken)
        }
        return Just([PharmacyLocation]())
            .setFailureType(to: FHIRClient.Error.self)
            .eraseToAnyPublisher()
    }

    func fetchPharmacy(by _: String, accessToken _: String?) -> AnyPublisher<PharmacyLocation?, FHIRClient.Error> {
        Just(nil)
            .setFailureType(to: FHIRClient.Error.self)
            .eraseToAnyPublisher()
    }

    func fetchTelematikId(by _: String, accessToken _: String?) -> AnyPublisher<String?, FHIRClient.Error> {
        Just(nil)
            .setFailureType(to: FHIRClient.Error.self)
            .eraseToAnyPublisher()
    }
}
