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

class MockAVSSession: AVSSession {
    init() {}

    var redeemCallsCount = 0
    var redeemCalled: Bool {
        redeemCallsCount > 0
    }

    var redeemParameters: (AVSMessage, AVSEndpoint, [X509])? // swiftlint:disable:this large_tuple
    var redeemReturnValue: AnyPublisher<AVSMessage, AVSError>!
    var redeemMessageEndpointRecipientClosure: ((AVSMessage) -> AnyPublisher<AVSMessage, AVSError>)?

    func redeem(
        message: AVSMessage,
        endpoint: AVSEndpoint,
        recipients: [X509]
    ) -> AnyPublisher<AVSMessage, AVSError> {
        redeemCallsCount += 1
        redeemParameters = (message, endpoint, recipients)
        return redeemMessageEndpointRecipientClosure.map { $0(message) } ?? redeemReturnValue
    }
}
