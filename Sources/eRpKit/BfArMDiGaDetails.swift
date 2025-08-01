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

public struct BfArMDiGaDetails: Hashable, Equatable, Sendable, Codable {
    public var contractMedicalServicesRequired: Bool
    public var additionalDevices: [String]
    public var manufacturerCost: String?
    public var description: String?
    public var languageNames: [String]
    public var supportedPlatforms: [String]
    public var iconUrl: String?
    public var iconData: Data?
    public var handbookUrl: String?
    public var helpUrl: String?

    public init(
        contractMedicalServicesRequired: Bool,
        additionalDevices: [String],
        manufacturerCost: String? = nil,
        description: String? = nil,
        languageNames: [String],
        supportedPlatforms: [String],
        iconUrl: String? = nil,
        iconData: Data? = nil,
        handbookUrl: String? = nil,
        helpUrl: String? = nil
    ) {
        self.contractMedicalServicesRequired = contractMedicalServicesRequired
        self.additionalDevices = additionalDevices
        self.manufacturerCost = manufacturerCost
        self.description = description
        self.languageNames = languageNames
        self.supportedPlatforms = supportedPlatforms
        self.iconUrl = iconUrl
        self.iconData = iconData
        self.handbookUrl = handbookUrl
        self.helpUrl = helpUrl
    }
}
