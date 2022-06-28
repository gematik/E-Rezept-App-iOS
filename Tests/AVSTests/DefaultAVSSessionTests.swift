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

@testable import AVS
import Combine
import DataKit
import Foundation
import Nimble
import OpenSSL
import XCTest

final class DefaultAVSSessionTests: XCTestCase {
    func testRedeem() {
        // given
        let message = AVSMessage.Fixtures.completeExample
        let endpoint = AVSEndpoint(url: URL(string: "https://beispielurlversand.de/")!)
        let mockAvsMessageConverter = MockAVSMessageConverter()
        mockAvsMessageConverter.convertRecipientsReturnValue = Data([0x00])

        let mockAvsClient = MockAVSClient()
        mockAvsClient.sendDataToTransactionIdReturnValue = Just(message.transactionID).setFailureType(to: AVSError.self)
            .eraseToAnyPublisher()
        let sut = DefaultAVSSession(
            avsMessageConverter: mockAvsMessageConverter,
            avsClient: mockAvsClient
        )

        // then
        sut.redeem(message: message, endpoint: endpoint, recipients: [])
            .test(
                expectations: { uuid in
                    expect(uuid) == message.transactionID
                    expect(mockAvsMessageConverter.convertRecipientsCalled) == true
                    expect(mockAvsMessageConverter.convertRecipientsCallsCount) == 1
                    expect(mockAvsClient.sendDataToTransactionIdCalled) == true
                    expect(mockAvsClient.sendDataToTransactionIdCallsCount) == 1
                }
            )
    }
}
