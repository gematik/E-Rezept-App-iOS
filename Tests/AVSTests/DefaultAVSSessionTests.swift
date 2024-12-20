//
//  Copyright (c) 2024 gematik GmbH
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
import Foundation
import HTTPClient
import Nimble
import OpenSSL
import XCTest

final class DefaultAVSSessionTests: XCTestCase {
    func testRedeem() {
        // given
        let message = AVSMessage.Fixtures.completeExample
        let url = URL(string: "https://beispielurlversand.de/")!
        let endpoint = AVSEndpoint(url: url)
        let mockAvsMessageConverter = MockAVSMessageConverter()
        mockAvsMessageConverter.convertRecipientsReturnValue = Data([0x00])

        let mockAvsClient = MockAVSClient()
        mockAvsClient.sendDataToClosure = { _, _ in
            Just(
                (
                    data: Data(),
                    response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    status: .ok
                )
            )
            .setFailureType(to: AVSError.self)
            .eraseToAnyPublisher()
        }

        let sut = DefaultAVSSession(
            avsMessageConverter: mockAvsMessageConverter,
            avsClient: mockAvsClient,
            logger: nil
        )

        // then
        sut.redeem(message: message, endpoint: endpoint, recipients: [])
            .test(
                expectations: { avsSessionResponse in
                    expect(avsSessionResponse.httpStatusCode) == 200
                    expect(mockAvsMessageConverter.convertRecipientsCalled) == true
                    expect(mockAvsMessageConverter.convertRecipientsCallsCount) == 1
                    expect(mockAvsClient.sendDataToCalled) == true
                    expect(mockAvsClient.sendDataToCallsCount) == 1
                }
            )
    }
}
