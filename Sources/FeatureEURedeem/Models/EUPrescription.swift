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

/// This will be replaced by as soon as the real dependencies can be used
public struct EUPrescription: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let expiresOn: Date?
    public var isRedeemableInEU: Bool
    public var isSelected: Bool
    public var notRedeemableReason: String?

    public init(
        id: String,
        name: String,
        expiresOn: Date? = nil,
        isRedeemableInEU: Bool = true,
        isSelected: Bool = false,
        notRedeemableReason: String? = nil
    ) {
        self.id = id
        self.name = name
        self.expiresOn = expiresOn
        self.isRedeemableInEU = isRedeemableInEU
        self.isSelected = isSelected
        self.notRedeemableReason = notRedeemableReason
    }
}
