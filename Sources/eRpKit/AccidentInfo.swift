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

public struct AccidentInfo: Hashable, Codable, Sendable {
    public init(type: AccidentType?,
                workPlaceIdentifier: String? = nil,
                date: String?) {
        self.workPlaceIdentifier = workPlaceIdentifier
        self.date = date
        self.type = type
    }

    /// Type of accident
    public let type: AccidentType?
    /// Place of work
    public let workPlaceIdentifier: String?
    /// Date of accident
    public let date: String?

    /// https://simplifier.net/erezept/kbvvserpaccidenttype
    public enum AccidentType: String, Equatable, Codable, Sendable {
        /// Unfall
        case accident = "1"
        /// Arbeitsunfall (Berufsgenossenschaft/Unfallkasse)
        case workAccident = "2"
        ///  Berufskrankheit (Berufsgenossenschaft/Unfallkasse)
        case workRelatedDisease = "4"
        /// undefined type
        case unknown
    }
}
