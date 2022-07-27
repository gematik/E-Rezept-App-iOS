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

import AVS
import Combine
import Foundation
import OpenSSL

// swiftlint:disable large_tuple
final class MockAVSSession: AVSSession {
    // MARK: - redeem

    var redeemMessageEndpointRecipientsCallsCount = 0
    var redeemMessageEndpointRecipientsCalled: Bool {
        redeemMessageEndpointRecipientsCallsCount > 0
    }

    var redeemMessageEndpointRecipientsReceivedArguments: (
        message: AVSMessage,
        endpoint: AVSEndpoint,
        recipients: [X509]
    )?
    var redeemMessageEndpointRecipientsReceivedInvocations: [(message: AVSMessage, endpoint: AVSEndpoint,
                                                              recipients: [X509])] = []
    var redeemMessageEndpointRecipientsReturnValue: AnyPublisher<AVSSessionResponse, AVSError>!
    var redeemMessageEndpointRecipientsClosure: ((AVSMessage, AVSEndpoint, [X509])
        -> AnyPublisher<AVSSessionResponse, AVSError>)?

    func redeem(message: AVSMessage, endpoint: AVSEndpoint,
                recipients: [X509]) -> AnyPublisher<AVSSessionResponse, AVSError> {
        redeemMessageEndpointRecipientsCallsCount += 1
        redeemMessageEndpointRecipientsReceivedArguments = (
            message: message,
            endpoint: endpoint,
            recipients: recipients
        )
        redeemMessageEndpointRecipientsReceivedInvocations
            .append((message: message, endpoint: endpoint, recipients: recipients))
        return redeemMessageEndpointRecipientsClosure
            .map { $0(message, endpoint, recipients) } ?? redeemMessageEndpointRecipientsReturnValue
    }
}
