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

/// Handles the chaining of `Interceptors`.
public protocol Chain {
    /// The request that the chain hold at the moment
    var request: URLRequest { get }

    /// Launch the chain processing of the given input.
    ///
    /// - Parameter request: the `URLRequest` to proceed
    /// - Note: Only `HTTPClientError`s are supposed to be thrown.
    /// - Returns: Response emitted as `HTTPClient.Response`
    func proceed(request: URLRequest) async throws -> HTTPResponse
}
