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
import HTTPClient

protocol VAUEndpointHandler {
    var vauEndpoint: AnyPublisher<URL, VAUError> { get }

    // [REQ:gemSpec_Krypt:A_20174:2]
    func didReceiveUserPseudonym(in httpResponse: HTTPResponse)
}

extension VAUSession: VAUEndpointHandler {
    var vauEndpoint: AnyPublisher<URL, VAUError> {
        vauStorage.userPseudonym
            .map { userPseudonym in
                // If the client has yet not been assigned a user pseudonym, then default to "0".
                let userPseudonymPathComponent = userPseudonym ?? "0"
                return self.vauEndpoint(withLastComponent: userPseudonymPathComponent)
            }
            .setFailureType(to: VAUError.self)
            .eraseToAnyPublisher()
    }

    private func vauEndpoint(withLastComponent: String) -> URL {
        vauServer.appendingPathComponent("VAU").appendingPathComponent(withLastComponent)
    }

    func didReceiveUserPseudonym(in httpResponse: HTTPResponse) {
        // [REQ:gemSpec_Krypt:A_20174:2]
        if let pseudonym = httpResponse.response.value(forHTTPHeaderField: "userpseudonym") {
            vauStorage.set(userPseudonym: pseudonym)
        }
    }
}
