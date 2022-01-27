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

import Foundation

struct HintState: Codable, Equatable {
    /// Indicates if there are any unread messages
    var hasUnreadMessages = false
    /// Indicates if there has been scanned at least one prescription
    var hasScannedPrescriptionsBefore = false
    /// Indicates if the `refresh` button (or pull to refresh) has been tapped while being in demo mode
    var hasCardWallBeenPresentedInDemoMode = false
    /// Indicates if there are any prescriptions loaded into the local store
    var hasTasksInLocalStore = false
    /// Indicates if the demo mode has been toggled at least once
    var hasDemoModeBeenToggledBefore = false
    /// Set of IDs for the hints that should not be displayed
    var hiddenHintIDs: Set<String> = []

    /// Decodes the given data into a HintState using `JSONDecoder`
    /// - Parameter data: The data that should be decoded
    /// - Parameter decoder: decoder used to decode `data`
    /// - Returns: A HintState if decoding was successful, otherwise returns nil
    static func from(_ data: Data, decoder: JSONDecoder) -> HintState? {
        try? decoder.decode(HintState.self, from: data)
    }

    /// Encodes `HintState` into a data object. Using `JSONEncoder`
    /// - Parameter encoder: encoder used to encode `data`
    /// - Returns: A Data object if encoding was successful, otherwise returns nil
    func asData(encoder: JSONEncoder) -> Data? {
        try? encoder.encode(self)
    }
}
