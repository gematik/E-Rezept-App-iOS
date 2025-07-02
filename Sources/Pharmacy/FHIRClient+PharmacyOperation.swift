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
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import ModelsR4
import OpenSSL

extension FHIRClient {
    /// Convenience function for searching for pharmacies
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19984] validate pharmacy data format conforming to FHIR
    ///
    /// - Parameters:
    ///   - searchTerm: String that send to the server for filtering the pharmacies response
    ///   - position: Position (latitude and longitude) of pharmacy
    ///   - filter: further filter parameters for pharmacies
    ///   - accessToken: access token to interact with the service
    /// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
    public func searchPharmacies(
        by searchTerm: String,
        position: Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        accessToken: String? = nil
    ) -> AnyPublisher<[PharmacyLocation], FHIRClient.Error> {
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
                accessToken: accessToken,
                handler: handler
            )
        )
    }

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    ///   - accessToken: access token to interact with the service
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    public func fetchPharmacy(
        by telematikId: String,
        accessToken: String? = nil
    ) -> AnyPublisher<PharmacyLocation?, Error> {
        let handler = DefaultFHIRResponseHandler(
            acceptFormat: FHIRAcceptFormat.json
        ) { (fhirResponse: FHIRClient.Response) -> PharmacyLocation? in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            return try resource.parsePharmacyLocations().first
        }
        return execute(
            operation: PharmacyFHIROperation.fetchPharmacy(
                telematikId: telematikId,
                accessToken: accessToken,
                handler: handler
            )
        )
    }

    /// Load `Insurance` by institution identifier (IK) from a remote (server).
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public func fetchInsurance(
        by ikNumber: String,
        accessToken: String? = nil
    ) -> AnyPublisher<Insurance?, Error> {
        let handler = DefaultFHIRResponseHandler(
            acceptFormat: FHIRAcceptFormat.json
        ) { (fhirResponse: FHIRClient.Response) -> Insurance? in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            // This should not call only the FHIRVZD API
            return nil
        }
        return execute(
            operation: PharmacyFHIROperation.fetchInsurance(
                ikNumber: ikNumber,
                accessToken: accessToken,
                handler: handler
            )
        )
    }

    /// Convenience function for requesting a telematikId by institution identifier (IK)
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public func fetchAllInsurances(
        accessToken: String? = nil
    ) -> AnyPublisher<[Insurance], Error> {
        let handler = DefaultFHIRResponseHandler(
            acceptFormat: FHIRAcceptFormat.json
        ) { (fhirResponse: FHIRClient.Response) -> [Insurance] in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            // This should not call only the FHIRVZD API
            return []
        }
        return execute(
            operation: PharmacyFHIROperation.fetchAllInsurances(
                accessToken: accessToken,
                handler: handler
            )
        )
    }

    /// Convenience function for requesting the certificates of a pharmacy
    ///
    /// - Parameters:
    ///   - locationId: The id of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits an array of `X509` certificates
    public func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], Error> {
        let handler = DefaultFHIRResponseHandler(
            acceptFormat: FHIRAcceptFormat.json
        ) { (fhirResponse: FHIRClient.Response) -> [X509] in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            return try resource.parseCertificates()
        }
        return execute(
            operation: PharmacyFHIROperation.loadCertificates(
                locationId: locationId,
                handler: handler
            )
        )
    }
}
