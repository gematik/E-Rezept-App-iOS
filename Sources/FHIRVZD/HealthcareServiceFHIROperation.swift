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

import Dependencies
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import Pharmacy

/// Operations the healthcare service can perform
public enum HealthcareServiceFHIROperation<Value, Handler: FHIRResponseHandler> where Handler.Value == Value {
    /// Search for pharmacies by name
    /// [REQ:gemSpec_eRp_FdV:A_20208]
    case searchPharmacies(
        searchTerm: String,
        position: Pharmacy.Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        accessToken: String?,
        handler: Handler
    )
    /// Search for pharmacies by telematikId
    case fetchPharmacy(telematikId: String, accessToken: String?, handler: Handler)
    /// Get the telematikID by the IK-Number of an organization
    case fetchInsurance(ikNumber: String, accessToken: String?, handler: Handler)
    /// Get all organizations related to DiGa
    case fetchAllInsurances(accessToken: String?, handler: Handler)
}

extension HealthcareServiceFHIROperation: FHIRClientOperation {
    public func handle(response: FHIRClient.Response) throws -> Value {
        switch self {
        case let .searchPharmacies(_, _, _, _, handler),
             let .fetchPharmacy(_, _, handler),
             let .fetchInsurance(_, _, handler),
             let .fetchAllInsurances(_, handler):
            return try handler.handle(response: response)
        }
    }

    public var relativeUrlString: String? {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "_include", value: "HealthcareService:organization"))
        queryItems.append(URLQueryItem(name: "_include", value: "HealthcareService:location"))
        queryItems.append(URLQueryItem(name: "organization.active", value: "true"))

        switch self {
        case let .searchPharmacies(searchTerm, position, filter, _, _):
            queryItems.append(URLQueryItem(name: "_count", value: "100"))
            queryItems
                .append(URLQueryItem(name: "organization.type",
                                     value: FHIRDirectory.Key.OrganizationProfession.publicPharmacy.rawValue))

            if !searchTerm.isEmpty {
                // Sanitize search term for special search characters (double quote, dot)
                let sanatizedSearchTerm = searchTerm
                    .replacingOccurrences(of: "\"", with: "", options: .literal)
                    .replacingOccurrences(of: ".", with: "", options: .literal)
                queryItems.append(URLQueryItem(
                    name: "_text",
                    value: sanatizedSearchTerm
                ))
            }
            if position != nil, let latitude = position?.latitude, let longitude = position?.longitude {
                queryItems.append(URLQueryItem(name: "_sortby", value: "near"))
                queryItems.append(URLQueryItem(name: "location.near", value: "\(latitude)|\(longitude)|20|km"))
            }
            queryItems.append(contentsOf: filter.map { filter in
                URLQueryItem(name: filter.key, value: filter.value)
            })
        case let .fetchPharmacy(telematikId, _, _):
            queryItems.append(URLQueryItem(name: "_count", value: "1"))
            queryItems.append(URLQueryItem(name: "organization.identifier", value: "\(telematikId)"))
        case let .fetchInsurance(ikNumber, _, _):
            queryItems.append(URLQueryItem(name: "_count", value: "1"))
            // Set type for only insurance companies
            queryItems
                .append(URLQueryItem(name: "organization.type",
                                     value: FHIRDirectory.Key.OrganizationProfession.insuranceCompany.rawValue))

            // Add ikNumber to identifier to filter for exact organization
            let telematikIDValue = "http://fhir.de/StructureDefinition/identifier-iknr|\(ikNumber)"
            queryItems
                .append(URLQueryItem(name: "organization.identifier",
                                     value: telematikIDValue))

            // add queryItems to filter the results should have a telematikId
            queryItems
                .append(URLQueryItem(name: "organization.identifier",
                                     value: "https://gematik.de/fhir/sid/telematik-id|"))
        case .fetchAllInsurances:
            // Set type for only insurance companies
            queryItems
                .append(URLQueryItem(name: "organization.type",
                                     value: FHIRDirectory.Key.OrganizationProfession.insuranceCompany.rawValue))

            // add queryItems to filter the results should have a telematikId
            queryItems
                .append(URLQueryItem(name: "organization.identifier",
                                     value: "https://gematik.de/fhir/sid/telematik-id|"))
        }

        var urlComps = URLComponents(string: "fdv/search/HealthcareService")
        urlComps?.queryItems = queryItems
        return urlComps?.string
    }

    // Note: Only .json for now
    public var httpHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Accept"] = acceptFormat.httpHeaderValue
        switch self {
        case let .searchPharmacies(_, _, _, token, _),
             let .fetchPharmacy(_, token, _),
             let .fetchInsurance(_, token, _),
             let .fetchAllInsurances(token, _):
            if let token {
                headers["Authorization"] = "Bearer \(token)"
            }
        }
        return headers
    }

    public var httpMethod: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    public var httpBody: Data? {
        nil
    }

    public var acceptFormat: FHIRAcceptFormat {
        switch self {
        case let .searchPharmacies(_, _, _, _, handler),
             let .fetchPharmacy(_, _, handler),
             let .fetchInsurance(_, _, handler),
             let .fetchAllInsurances(_, handler):
            return handler.acceptFormat
        }
    }
}
