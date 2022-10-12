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

// MARK: - MockNFCHealthCardPasswordController -

final class MockNFCHealthCardPasswordController: NFCHealthCardPasswordController {
    // MARK: - resetEgkMrPinRetryCounter

    var resetEgkMrPinRetryCounterCanPukModeCallsCount = 0
    var resetEgkMrPinRetryCounterCanPukModeCalled: Bool {
        resetEgkMrPinRetryCounterCanPukModeCallsCount > 0
    }

    var resetEgkMrPinRetryCounterCanPukModeReceivedArguments: (
        can: String,
        puk: String,
        mode: NFCResetRetryCounterMode
    )?
    var resetEgkMrPinRetryCounterCanPukModeReceivedInvocations: [(can: String, puk: String,
                                                                  mode: NFCResetRetryCounterMode)] = []
    var resetEgkMrPinRetryCounterCanPukModeReturnValue: AnyPublisher<
        NFCHealthCardPasswordControllerResponse,
        NFCHealthCardPasswordControllerError
    >!
    var resetEgkMrPinRetryCounterCanPukModeClosure: ((String, String, NFCResetRetryCounterMode) -> AnyPublisher<
        NFCHealthCardPasswordControllerResponse,
        NFCHealthCardPasswordControllerError
    >)?

    func resetEgkMrPinRetryCounter(can: String, puk: String,
                                   mode: NFCResetRetryCounterMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        resetEgkMrPinRetryCounterCanPukModeCallsCount += 1
        resetEgkMrPinRetryCounterCanPukModeReceivedArguments = (can: can, puk: puk, mode: mode)
        resetEgkMrPinRetryCounterCanPukModeReceivedInvocations.append((can: can, puk: puk, mode: mode))
        return resetEgkMrPinRetryCounterCanPukModeClosure
            .map { $0(can, puk, mode) } ?? resetEgkMrPinRetryCounterCanPukModeReturnValue
    }

    // MARK: - changeReferenceData

    var changeReferenceDataCanOldNewModeCallsCount = 0
    var changeReferenceDataCanOldNewModeCalled: Bool {
        changeReferenceDataCanOldNewModeCallsCount > 0
    }

    var changeReferenceDataCanOldNewModeReceivedArguments: (
        can: String,
        old: String,
        new: String,
        mode: NFCChangeReferenceDataMode
    )?
    var changeReferenceDataCanOldNewModeReceivedInvocations: [(can: String, old: String, new: String,
                                                               mode: NFCChangeReferenceDataMode)] = []
    var changeReferenceDataCanOldNewModeReturnValue: AnyPublisher<
        NFCHealthCardPasswordControllerResponse,
        NFCHealthCardPasswordControllerError
    >!
    var changeReferenceDataCanOldNewModeClosure: ((String, String, String, NFCChangeReferenceDataMode) -> AnyPublisher<
        NFCHealthCardPasswordControllerResponse,
        NFCHealthCardPasswordControllerError
    >)?

    func changeReferenceData(can: String, old: String, new: String,
                             mode: NFCChangeReferenceDataMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        changeReferenceDataCanOldNewModeCallsCount += 1
        changeReferenceDataCanOldNewModeReceivedArguments = (can: can, old: old, new: new, mode: mode)
        changeReferenceDataCanOldNewModeReceivedInvocations.append((can: can, old: old, new: new, mode: mode))
        return changeReferenceDataCanOldNewModeClosure
            .map { $0(can, old, new, mode) } ?? changeReferenceDataCanOldNewModeReturnValue
    }
}
