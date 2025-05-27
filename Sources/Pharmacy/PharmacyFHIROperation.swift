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

import FHIRClient
import Foundation
import HTTPClient

/// Operations we expect the pharmacy service to possibly be able to perform
public enum PharmacyFHIROperation<Value, Handler: FHIRResponseHandler> where Handler.Value == Value {
    /// Search for pharmacies by name
    /// [REQ:gemSpec_eRp_FdV:A_20208]
    case searchPharmacies(
        searchTerm: String,
        position: Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        accessToken: String?,
        handler: Handler
    )
    /// Search for pharmacies by telematikId
    case fetchPharmacy(telematikId: String, accessToken: String?, handler: Handler)
    /// Load certificates used for redeeming via avs service
    case loadCertificates(locationId: String, handler: Handler)
    /// fetchTelematikID by IK Number
    case fetchTelematikID(ikNumber: String, accessToken: String?, handler: Handler)
}

extension PharmacyFHIROperation: FHIRClientOperation {
    public func handle(response: FHIRClient.Response) throws -> Value {
        switch self {
        case let .searchPharmacies(_, _, _, _, handler),
             let .fetchPharmacy(_, _, handler),
             let .loadCertificates(_, handler: handler),
             let .fetchTelematikID(_, _, handler):
            return try handler.handle(response: response)
        }
    }

    public var relativeUrlString: String? {
        switch self {
        case let .searchPharmacies(searchTerm, position, filter, _, _):
            var queryItems: [URLQueryItem] = []
            if !searchTerm.isEmpty {
                for singleSearchTerm in searchTerm.components(separatedBy: " ") {
                    queryItems.append(URLQueryItem(name: "name", value: singleSearchTerm))
                }
            }
            if position != nil, let latitude = position?.latitude, let longitude = position?.longitude {
                queryItems.append(URLQueryItem(name: "near", value: "\(latitude)|\(longitude)|999|km"))
            }
            queryItems.append(contentsOf: filter.map { filter in
                URLQueryItem(name: filter.key, value: filter.value)
            })
            var urlComps = URLComponents(string: "Location")
            urlComps?.queryItems = queryItems
            return urlComps?.string
        case let .fetchPharmacy(telematikId, _, _):
            var components = URLComponents(string: "Location")
            let item = URLQueryItem(
                name: "identifier",
                value: "\(telematikId)"
            )
            components?.queryItems = [item]
            return components?.string
        case let .loadCertificates(locationId: locationId, _):
            var components = URLComponents(string: "Binary")
            let item = URLQueryItem(
                name: "_securityContext",
                value: "Location/\(locationId)"
            )
            components?.queryItems = [item]
            return components?.string
        case let .fetchTelematikID(ikNumber, _, _):
            var components = URLComponents(string: "Organization")
            let item = URLQueryItem(
                name: "identifier",
                value: "http://fhir.de/StructureDefinition/identifier-iknr|\(ikNumber)"
            )
            components?.queryItems = [item]
            return components?.string
        }
    }

    // Note: Only .json for now
    public var httpHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Accept"] = acceptFormat.httpHeaderValue
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
             let .loadCertificates(_, handler),
             let .fetchTelematikID(_, _, handler):
            return handler.acceptFormat
        }
    }
}
