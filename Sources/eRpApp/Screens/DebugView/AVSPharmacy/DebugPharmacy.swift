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

import DataKit
import Foundation
import OpenSSL
import Pharmacy

struct DebugPharmacy: Identifiable, Codable, CustomStringConvertible, Equatable, Hashable {
    var id = UUID()
    var name: String = "New Pharmacy"
    var onPremiseUrl = Endpoint()
    var shipmentUrl = Endpoint()
    var deliveryUrl = Endpoint()
    var certificates: [Certificate] = []

    struct Certificate: Identifiable, Codable, CustomStringConvertible, Equatable, Hashable {
        private(set) var id = UUID()
        var name: String
        // Base64 DER representation of a HCI encryption certificate (C.HCI.ENC)
        var derBase64: String

        init(id: UUID = UUID(), name: String, derBase64: String) {
            self.id = id
            self.name = name
            self.derBase64 = derBase64
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
            name = try container.decode(String.self, forKey: .name)
            derBase64 = try container.decode(String.self, forKey: .derBase64)
        }

        var x509: X509? {
            guard let base64 = try? Base64.decode(string: derBase64) else { return nil }
            return try? X509(der: base64)
        }

        var description: String {
            """
            Name: \(name)
            id: \(id)
            value: \(derBase64)
            """
        }
    }

    var description: String {
        """
        Name: \(name)
        id: \(id)
        onPremiseUrl: \(onPremiseUrl)
        shipmentUrl: \(shipmentUrl)
        deliveryUrl: \(deliveryUrl)
        certificates: \(certificates.description)
        """
    }

    struct Endpoint: Codable, Equatable, Hashable {
        var url: String = ""
        var additionalHeaders: [Header] = []

        var additionalHeadersDict: [String: String] {
            additionalHeaders.reduce([String: String]()) { partialResult, header in
                var partialResult = partialResult
                partialResult[header.key] = header.value
                return partialResult
            }
        }

        struct Header: Codable, Equatable, Hashable, Identifiable {
            var key: String = ""
            var value: String = ""

            private(set) var id = UUID()
        }
    }
}

extension DebugPharmacy {
    func asPharmacyViewModel() -> PharmacyLocationViewModel {
        .init(
            pharmacy: PharmacyLocation(
                id: id.uuidString,
                status: .active,
                telematikID: "telematik-id",
                name: name,
                types: [],
                hoursOfOperation: [],
                avsEndpoints: PharmacyLocation.AVSEndpoints(
                    onPremiseUrl: onPremiseUrl.url,
                    onPremiseUrlAdditionalHeaders: onPremiseUrl.additionalHeadersDict,
                    shipmentUrl: shipmentUrl.url,
                    shipmentUrlAdditionalHeaders: shipmentUrl.additionalHeadersDict,
                    deliveryUrl: deliveryUrl.url,
                    deliveryUrlAdditionalHeaders: deliveryUrl.additionalHeadersDict
                ),
                avsCertificates: certificates.compactMap(\.x509)
            )
        )
    }
}
