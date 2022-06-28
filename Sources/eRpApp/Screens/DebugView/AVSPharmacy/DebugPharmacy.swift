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
    var onPremiseUrl: String = ""
    var shipmentUrl: String = ""
    var deliveryUrl: String = ""
    var certificates: [Certificate] = []

    struct Certificate: Identifiable, Codable, CustomStringConvertible, Equatable, Hashable {
        var id = UUID()
        var name: String
        // Base64 DER representation of a HCI encryption certificate (C.HCI.ENC)
        var derBase64: String

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
}

extension DebugPharmacy {
    func asPharmacyViewModel() -> PharmacyLocationViewModel {
        .init(
            pharmacy: PharmacyLocation(
                id: id.uuidString,
                status: .active,
                telematikID: "telematik-id",
                name: name,
                types: [.mobl, .outpharm, .pharm],
                hoursOfOperation: [],
                avsEndpoints: PharmacyLocation.AVSEndpoints(
                    onPremiseUrl: URL(string: onPremiseUrl),
                    shipmentUrl: URL(string: shipmentUrl),
                    deliveryUrl: URL(string: deliveryUrl)
                ),
                avsCertificates: certificates.compactMap(\.x509)
            )
        )
    }
}
