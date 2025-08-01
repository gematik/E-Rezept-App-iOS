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
import OpenSSL

/// Interface to the eRpApp
public protocol AVSSession {
    /// Redeem a prescription encoded into a `AVSMessage` by (encrypting it for (multiple) recipients and)
    /// sending it to a given endpoint.
    ///
    /// - Parameters:
    ///   - message: contains the information for redeeming of a prescription
    ///   - endpoint: (wrapped) `URL` to send the request to
    ///   - recipients: the message will potentially be prepared (encrypted) for them
    /// - Note: Only `AVSError`s are supposed to be thrown
    /// - Returns: The sent `AVSMessage` if successful, else `AVSError`
    func redeem(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509]) async throws -> AVSSessionResponse
}

/// Contains the response information from an `AVSSession`
public struct AVSSessionResponse {
    /// The original `AVSMessage` that was sent to the `AVSSession`
    public let message: AVSMessage
    /// The status code of the response
    public let httpStatusCode: Int

    /// Contains the response information from an `AVSSession`
    ///
    /// - Parameters:
    ///   - message: original `AVSMessage` that was sent to the `AVSSession`
    ///   - httpStatusCode: status code of the response
    public init(message: AVSMessage, httpStatusCode: Int) {
        self.message = message
        self.httpStatusCode = httpStatusCode
    }
}

public class DefaultAVSSession: AVSSession {
    let avsMessageConverter: AVSMessageConverter
    let avsClient: AVSClient
    let logger: ((AVSMessage, AVSEndpoint, HTTPResponse) -> Void)?

    public convenience init(
        httpClient: HTTPClient,
        logger: ((AVSMessage, AVSEndpoint, HTTPResponse) -> Void)? = nil
    ) {
        self.init(
            avsMessageConverter: AuthEnvelopedWithUnauthAttributes(),
            avsClient: RealAVSClient(httpClient: httpClient),
            logger: logger
        )
    }

    required init(
        avsMessageConverter: AVSMessageConverter,
        avsClient: AVSClient,
        logger: ((AVSMessage, AVSEndpoint, HTTPResponse) -> Void)?
    ) {
        self.avsMessageConverter = avsMessageConverter
        self.avsClient = avsClient
        self.logger = logger
    }

    public func redeem(
        message: AVSMessage,
        endpoint: AVSEndpoint,
        recipients: [X509]
    ) async throws -> AVSSessionResponse {
        do {
            let restMessage = try avsMessageConverter.convert(message, recipients: recipients)
            let httpResponse = try await avsClient.send(data: restMessage, to: endpoint)

            logger?(message, endpoint, httpResponse)

            guard httpResponse.status.isSuccessful else {
                let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
                throw HTTPClientError.httpError(urlError)
            }

            return .init(
                message: message,
                httpStatusCode: httpResponse.status.rawValue
            )
        } catch {
            throw error.asAVSError()
        }
    }
}

public class DemoAVSSession: AVSSession {
    public init() {}

    public func redeem(
        message: AVSMessage,
        endpoint _: AVSEndpoint,
        recipients _: [X509]
    ) async throws -> AVSSessionResponse {
        .init(message: message, httpStatusCode: 200)
    }
}
