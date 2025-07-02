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

public struct MultiplePrescription: Hashable, Codable, Sendable {
    public init(mark: Bool = false,
                numbering: Decimal? = nil,
                totalNumber: Decimal? = nil,
                startPeriod: String? = nil,
                endPeriod: String? = nil) {
        self.mark = mark
        self.numbering = numbering
        self.totalNumber = totalNumber
        self.startPeriod = startPeriod
        self.endPeriod = endPeriod
    }

    /// `True` if medication is of type multiple prescription, `false` if not
    public let mark: Bool
    /// Number of this medication within the `totalNumber` of all multiple prescriptions
    public let numbering: Decimal?
    /// Total number of multiple prescriptions
    public let totalNumber: Decimal?
    /// Start of period from when this multiple prescription is valid
    public let startPeriod: String?
    /// End of valid period
    public let endPeriod: String?
}
