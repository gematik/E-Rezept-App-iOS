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

import Combine
import Foundation
import HTTPClient

protocol VAUEndpointHandler {
    var vauEndpoint: AnyPublisher<URL, VAUError> { get }

    func didReceiveUserPseudonym(in httpResponse: HTTPResponse)
}

extension VAUSession: VAUEndpointHandler {
    // [REQ:gemSpec_Krypt:A_20161-01#17|10] 7: VAU-Endpoint respects userpseudonym if present
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
        // [REQ:gemSpec_Krypt:A_20174#12] 2:
        if let pseudonym = httpResponse.response.value(forHTTPHeaderField: "userpseudonym") {
            vauStorage.set(userPseudonym: pseudonym)
        }
    }
}
