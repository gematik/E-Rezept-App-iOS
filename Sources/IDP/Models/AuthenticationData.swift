//
//  Copyright (c) 2023 gematik GmbH
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

/// Represents user/device data that is used for authentication for the idp while using alternative authentication/
/// biometrics.
public struct AuthenticationData: Claims, Codable {
    public init(authCert: String,
                challengeToken: String,
                deviceInformation: RegistrationData.DeviceInformation,
                amr: [String],
                keyIdentifier: String,
                exp: Int) {
        self.authCert = authCert
        self.challengeToken = challengeToken
        self.deviceInformation = deviceInformation
        self.amr = amr
        self.keyIdentifier = keyIdentifier
        self.exp = exp
        authenticationDataVersion = "1.0"
    }

    let authCert: String
    let challengeToken: String
    let deviceInformation: RegistrationData.DeviceInformation
    let amr: [String]
    let authenticationDataVersion: String
    let keyIdentifier: String
    let exp: Int

    enum CodingKeys: String, CodingKey {
        case authCert = "auth_cert"
        case challengeToken = "challenge_token"
        case deviceInformation = "device_information"
        case amr
        case authenticationDataVersion = "authentication_data_version"
        case keyIdentifier = "key_identifier"
        case exp
    }
}
