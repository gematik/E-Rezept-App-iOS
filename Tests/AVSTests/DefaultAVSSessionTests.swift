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

@testable import AVS
import Combine
import Foundation
import HTTPClient
import Nimble
import OpenSSL
import XCTest

final class DefaultAVSSessionTests: XCTestCase {
    func testRedeem() async throws {
        // given
        let message = AVSMessage.Fixtures.completeExample
        let url = URL(string: "https://beispielurlversand.de/")!
        let endpoint = AVSEndpoint(url: url)
        let mockAvsMessageConverter = AVSMessageConverterMock()
        mockAvsMessageConverter.convertMessageAVSMessageRecipientsX509DataReturnValue = Data([0x00])

        let mockAvsClient = AVSClientMock()
        mockAvsClient.sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReturnValue = (
            data: Data(),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            status: .ok
        )

        let sut = DefaultAVSSession(
            avsMessageConverter: mockAvsMessageConverter,
            avsClient: mockAvsClient,
            logger: nil
        )

        // then
        let avsSessionResponse = try await sut.redeem(message: message, endpoint: endpoint, recipients: [])
        expect(avsSessionResponse.httpStatusCode) == 200
        expect(mockAvsMessageConverter.convertMessageAVSMessageRecipientsX509DataCalled) == true
        expect(mockAvsMessageConverter.convertMessageAVSMessageRecipientsX509DataCallsCount) == 1
        expect(mockAvsClient.sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCalled) == true
        expect(mockAvsClient.sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCallsCount) == 1
    }
}
