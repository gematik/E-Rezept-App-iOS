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
import Foundation
import HTTPClient

// swiftlint:disable all
final class MockAVSClient: AVSClient {
    // MARK: - send

    var sendDataToTransactionIdCallsCount = 0
    var sendDataToTransactionIdCalled: Bool {
        sendDataToTransactionIdCallsCount > 0
    }

    var sendDataToTransactionIdReceivedArguments: (data: Data, endpoint: AVSEndpoint)?
    var sendDataToTransactionIdReceivedInvocations: [(data: Data, endpoint: AVSEndpoint)] = []
    var sendDataToTransactionIdReturnValue: AnyPublisher<HTTPResponse, AVSError>!
    var sendDataToTransactionIdClosure: ((Data, AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError>)?

    func send(data: Data, to endpoint: AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError> {
        sendDataToTransactionIdCallsCount += 1
        sendDataToTransactionIdReceivedArguments = (data: data, endpoint: endpoint)
        sendDataToTransactionIdReceivedInvocations
            .append((data: data, endpoint: endpoint))
        return sendDataToTransactionIdClosure
            .map { $0(data, endpoint) } ?? sendDataToTransactionIdReturnValue
    }
}
