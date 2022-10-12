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
import eRpKit
@testable import Pharmacy

final class MockPharmacyRemoteDataStore: PharmacyRemoteDataStore {
    // MARK: - searchPharmacy

    var searchByTermPositionFilterCallsCount = 0
    var searchByTermPositionFilterCalled: Bool {
        searchByTermPositionFilterCallsCount > 0
    }

    var searchByTermPositionFilterReceivedArguments: (
        searchTerm: String,
        position: Position?,
        filter: [String: String]
    )?
    var searchByTermPositionFilterReceivedInvocations: [(
        searchTerm: String,
        position: Position?,
        filter: [String: String]
    )] = []
    var searchByTermPositionFilterReturnValue: AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>!
    var searchByTermPositionFilterClosure: ((String, Position?, [String: String])
        -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>)?

    func searchPharmacies(by searchTerm: String, position: Position?,
                          filter: [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        searchByTermPositionFilterCallsCount += 1
        searchByTermPositionFilterReceivedArguments = (searchTerm, position, filter)
        searchByTermPositionFilterReceivedInvocations.append((searchTerm, position, filter))
        return searchByTermPositionFilterClosure
            .map { $0(searchTerm, position, filter) } ?? searchByTermPositionFilterReturnValue
    }

    // MARK: - fetchPharmacy

    var fetchByTelematikIdCallsCount = 0
    var fetchByTelematikIdCalled: Bool {
        fetchByTelematikIdCallsCount > 0
    }

    var fetchByTelematikIdReceivedArgument: String?
    var fetchByTelematikIdReceivedInvocations: [String] = []
    var fetchByTelematikIdReturnValue: AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>!
    var fetchByTelematikIdClosure: ((String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        fetchByTelematikIdCallsCount += 1
        fetchByTelematikIdReceivedArgument = telematikId
        fetchByTelematikIdReceivedInvocations.append(telematikId)
        return fetchByTelematikIdClosure.map { $0(telematikId) } ?? fetchByTelematikIdReturnValue
    }
}
