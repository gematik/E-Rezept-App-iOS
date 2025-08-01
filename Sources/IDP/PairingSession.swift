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

import Foundation
import OpenSSL

/// Represents a Biometrics PairingSession that may be reset when registration of a biometric key failed.
public class PairingSession {
    /// The temporary key identifier used for the pairing session
    public let tempKeyIdentifier: Data
    /// Device information containing details about the device being paired
    public let deviceInformation: RegistrationData.DeviceInformation
    /// The X509 certificate associated with the pairing session
    public var certificate: X509?

    /// Initializes a new PairingSession with the given parameters
    /// - Parameters:
    ///   - tempKeyIdentifier: The temporary key identifier for this session
    ///   - deviceInformation: Information about the device being paired
    public init(
        tempKeyIdentifier: Data,
        deviceInformation: RegistrationData.DeviceInformation
    ) {
        self.tempKeyIdentifier = tempKeyIdentifier
        self.deviceInformation = deviceInformation
    }
}
