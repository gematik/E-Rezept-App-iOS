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

import Combine
@testable import eRpApp
import HealthCardControl

// swiftlint:disable large_tuple

// MARK: - MockNFCResetRetryCounterController -

final class MockNFCResetRetryCounterController: NFCResetRetryCounterController {
    // MARK: - resetEgkMrPinRetryCounter

    var resetEgkMrPinRetryCounterCanPukModeCallsCount = 0
    var resetEgkMrPinRetryCounterCanPukModeCalled: Bool {
        resetEgkMrPinRetryCounterCanPukModeCallsCount > 0
    }

    var resetEgkMrPinRetryCounterCanPukModeReceivedArguments: (
        can: String,
        puk: String,
        mode: NFCResetRetryCounterControllerMode
    )?
    var resetEgkMrPinRetryCounterCanPukModeReceivedInvocations: [(can: String, puk: String,
                                                                  mode: NFCResetRetryCounterControllerMode)] = []
    var resetEgkMrPinRetryCounterCanPukModeReturnValue: AnyPublisher<
        ResetRetryCounterResponse,
        ResetRetryCounterControllerError
    >!
    var resetEgkMrPinRetryCounterCanPukModeClosure: ((String, String, NFCResetRetryCounterControllerMode)
        -> AnyPublisher<
            ResetRetryCounterResponse,
            ResetRetryCounterControllerError
        >)?

    func resetEgkMrPinRetryCounter(can: String, puk: String,
                                   mode: NFCResetRetryCounterControllerMode)
        -> AnyPublisher<ResetRetryCounterResponse, ResetRetryCounterControllerError> {
        resetEgkMrPinRetryCounterCanPukModeCallsCount += 1
        resetEgkMrPinRetryCounterCanPukModeReceivedArguments = (can: can, puk: puk, mode: mode)
        resetEgkMrPinRetryCounterCanPukModeReceivedInvocations.append((can: can, puk: puk, mode: mode))
        return resetEgkMrPinRetryCounterCanPukModeClosure
            .map { $0(can, puk, mode) } ?? resetEgkMrPinRetryCounterCanPukModeReturnValue
    }
}
