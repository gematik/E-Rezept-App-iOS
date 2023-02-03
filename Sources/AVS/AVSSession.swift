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
    /// - Returns: `AnyPublisher` that emits the sent `AVSMessage` if successful, else `AVSError`
    func redeem(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])
        -> AnyPublisher<AVSSessionResponse, AVSError>
}

/// Contains the response information from an `AVSSession`
public struct AVSSessionResponse {
    /// The original `AVSMessage` that was sent to the `AVSSession`
    public let message: AVSMessage
    /// Tne status code of the response
    public let httpStatusCode: Int
}

public class DefaultAVSSession: AVSSession {
    let avsMessageConverter: AVSMessageConverter
    let avsClient: AVSClient

    public convenience init(
        httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
    ) {
        self.init(
            avsMessageConverter: AuthEnvelopedWithUnauthAttributes(),
            avsClient: RealAVSClient(httpClient: httpClient)
        )
    }

    required init(
        avsMessageConverter: AVSMessageConverter,
        avsClient: AVSClient
    ) {
        self.avsMessageConverter = avsMessageConverter
        self.avsClient = avsClient
    }

    public func redeem(
        message: AVSMessage,
        endpoint: AVSEndpoint,
        recipients: [X509]
    ) -> AnyPublisher<AVSSessionResponse, AVSError> {
        Just((message, recipients))
            .tryMap(avsMessageConverter.convert)
            .mapError {
                $0.asAVSError()
            }
            .flatMap { restMessage -> AnyPublisher<AVSSessionResponse, AVSError> in
                self.avsClient.send(data: restMessage, to: endpoint)
                    .tryMap { httpResponse in
                        guard httpResponse.status.isSuccessful else {
                            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
                            throw HTTPError.httpError(urlError)
                        }
                        return .init(
                            message: message,
                            httpStatusCode: httpResponse.status.rawValue
                        )
                    }
                    .mapError { $0.asAVSError() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

public class DemoAVSSession: AVSSession {
    public init() {}

    public func redeem(
        message: AVSMessage,
        endpoint _: AVSEndpoint,
        recipients _: [X509]
    ) -> AnyPublisher<AVSSessionResponse, AVSError> {
        Just(.init(message: message, httpStatusCode: 200))
            .setFailureType(to: AVSError.self)
            .eraseToAnyPublisher()
    }
}
