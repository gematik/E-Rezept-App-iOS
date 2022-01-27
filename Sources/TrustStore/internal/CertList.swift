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

/// Data structure according to */CertList* endpoint
/// [REQ:gemSpec_Krypt:A_21216]
public struct CertList: Codable, Equatable {
    let addRoots: [Data]
    let caCerts: [Data]
    let eeCerts: [Data]

    /// Initialize from json encoded string
    static func from(string: String) throws -> Self {
        try from(data: Data(string.utf8))
    }

    /// Initialize from json encoded data
    static func from(data: Data) throws -> Self {
        let certListBase64 = try Base64.from(data: data)
        let addRoots = try certListBase64.addRoots.map { try DataKit.Base64.decode(string: $0) }
        let caCerts = try certListBase64.caCerts.map { try DataKit.Base64.decode(string: $0) }
        let eeCerts = try certListBase64.eeCerts.map { try DataKit.Base64.decode(string: $0) }
        return CertList(addRoots: addRoots, caCerts: caCerts, eeCerts: eeCerts)
    }

    /// Intermediate helper structure for processing/decoding /CertList HTTP responses
    /// When decoding a CertList received from the service we expect the following json structure
    /// {
    ///     "add_roots" : [ "base64-kodiertes-Root-Cross-Zertifikat-1", ... ],
    ///     "ca_certs"  : [ "base64-kodiertes-Komponenten-CA-Zertifikat-1", ... ],
    ///     "ee_certs"  : [ "base64-kodiertes-EE-Zertifikat-1-aus-einer-Komponenten-CA", ... ]
    /// }
    struct Base64: Decodable {
        let addRoots: [String]
        let caCerts: [String]
        let eeCerts: [String]

        /// Initialize from json encoded string
        static func from(string: String) throws -> Self {
            try from(data: Data(string.utf8))
        }

        /// Initialize from json encoded data
        static func from(data: Data) throws -> Self {
            try Self.jsonDecoder.decode(Base64.self, from: data)
        }

        private static var jsonDecoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }
    }
}
