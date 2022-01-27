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
import Foundation
import OpenSSL

/// Bundles data needed for creating and verifiying a pairing.
/// [REQ:gemF_Biometrie:A_21415:Registration_Data]
/// [REQ:gemSpec_IDP_Frontend:A_21416] Data Structure
public struct RegistrationData: Claims, Codable {
    public init(
        authCert: String,
        signedParingData: String,
        deviceInformation: RegistrationData.DeviceInformation
    ) {
        self.authCert = authCert
        self.signedParingData = signedParingData
        self.deviceInformation = deviceInformation
        registrationDataVersion = "1.0"
    }

    // Certificate of the eGK
    public let authCert: String
    // JWT
    public let signedParingData: String
    public let deviceInformation: DeviceInformation
    let registrationDataVersion: String

    enum CodingKeys: String, CodingKey {
        case authCert = "auth_cert"
        case signedParingData = "signed_pairing_data"
        case deviceInformation = "device_information"
        case registrationDataVersion = "registration_data_version"
    }

    /// [REQ:gemF_Biometrie:A_21415:Device_Information]
    public struct DeviceInformation: Codable {
        public init(
            name: String,
            deviceType: RegistrationData.DeviceInformation.DeviceType
        ) {
            self.name = name
            self.deviceType = deviceType
            deviceInformationDataVersion = "1.0"
        }

        public let name: String
        public let deviceType: DeviceType

        let deviceInformationDataVersion: String

        /// [REQ:gemF_Biometrie:A_21415:Device_Type]
        /// [REQ:gemSpec_IDP_Frontend:A_21591]
        public struct DeviceType: Codable {
            public init(
                product: String,
                model: String,
                os: String, // swiftlint:disable:this identifier_name
                osVersion: String,
                manufacturer: String
            ) {
                self.product = product
                self.model = model
                self.os = os
                self.osVersion = osVersion
                self.manufacturer = manufacturer
                deviceTypeDataVersion = "1.0"
            }

            let deviceTypeDataVersion: String
            public let product: String
            public let model: String
            public let os: String // swiftlint:disable:this identifier_name
            public let osVersion: String
            public let manufacturer: String

            enum CodingKeys: String, CodingKey {
                case deviceTypeDataVersion = "device_type_data_version"
                case product
                case model
                case os // swiftlint:disable:this identifier_name
                case osVersion = "os_version"
                case manufacturer
            }
        }

        enum CodingKeys: String, CodingKey {
            case name
            case deviceInformationDataVersion = "device_information_data_version"
            case deviceType = "device_type"
        }
    }

    private static var defaultEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()

    /// [REQ:gemF_Biometrie:A_21415:Encrypted_Registration_Data] Returns JWE encrypted Registration_Data
    /// [REQ:gemSpec_IDP_Frontend:A_21416] Encryption
    func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
                   using cryptoBox: IDPCrypto) throws -> JWE {
        let algorithm = JWE.Algorithm.ecdh_es(JWE.Algorithm.KeyExchangeContext.bpp256r1(
            publicKey,
            keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
        ))
        guard let jweHeader = try? JWE.Header(algorithm: algorithm,
                                              encryption: .a256gcm,
                                              contentType: "JSON",
                                              type: "JWT"),
            let jwePayload = try? RegistrationData.defaultEncoder.encode(self),
            let signedChallengeJWE = try? JWE(header: jweHeader,
                                              payload: jwePayload,
                                              nonceGenerator: cryptoBox.aesNonceGenerator) else {
            throw IDPError.internalError("Unable to encrypt signed challenge")
        }

        return signedChallengeJWE
    }
}
