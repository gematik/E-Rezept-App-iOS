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

/// Wrapper for an URL
public struct AVSEndpoint: Equatable {
    let url: URL
    let additionalHeaders: [String: String]

    /// Public initializer that can be invoked by more convenient ones.
    public init(url: URL, additionalHeaders: [String: String] = [:]) {
        self.url = url
        self.additionalHeaders = additionalHeaders
    }
}
