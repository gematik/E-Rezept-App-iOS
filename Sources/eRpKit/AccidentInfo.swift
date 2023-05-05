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

import Foundation

public struct AccidentInfo: Hashable, Codable {
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
    public enum AccidentType: String, Equatable, Codable {
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
