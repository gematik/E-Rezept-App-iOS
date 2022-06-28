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
import ModelsR4

extension FHIRClient {
    /// Convenience function for searching for pharmacies
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19984] validate pharmacy data format conforming to FHIR
    ///
    /// - Parameters:
    ///   - searchTerm: Search term
    ///   - position: Pharmacy position (latitude and longitude)
    /// - Returns: `AnyPublisher` that emits a list of pharmacies or nil when not found
    public func searchPharmacies(by searchTerm: String,
                                 position: Position?,
                                 filter: [String: String])
        -> AnyPublisher<[PharmacyLocation], FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler(
            acceptFormat: FHIRAcceptFormat.json
        ) { (fhirResponse: FHIRClient.Response) -> [PharmacyLocation] in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            return try resource.parsePharmacyLocations()
        }
        return execute(
            operation: PharmacyFHIROperation.searchPharmacies(
                searchTerm: searchTerm,
                position: position,
                filter: filter,
                handler: handler
            )
        )
    }
}
