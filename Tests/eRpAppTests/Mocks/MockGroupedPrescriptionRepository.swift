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

class MockGroupedPrescriptionRepository: GroupedPrescriptionRepository {
    var prescriptions: [GroupedPrescription]
    var loadLocalPublisher: AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType>
    var loadLocalCallsCount = 0
    var loadLocalCalled: Bool {
        loadLocalCallsCount > 0
    }

    var loadRemoteAndSavePublisher: AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType>
    var loadRemoteAndSaveCallsCount = 0
    var loadRemoteAndSaveCalled: Bool {
        loadRemoteAndSaveCallsCount > 0
    }

    init(groups: [GroupedPrescription] = [GroupedPrescription.Dummies.twoPrescriptions,
                                          GroupedPrescription.Dummies.twoPrescriptions]) {
        prescriptions = groups
        loadLocalPublisher = Just(prescriptions)
            .setFailureType(to: AnyErxTaskRepository.ErrorType.self)
            .eraseToAnyPublisher()
        loadRemoteAndSavePublisher = Just(prescriptions)
            .setFailureType(to: AnyErxTaskRepository.ErrorType.self)
            .eraseToAnyPublisher()
    }

    init(loadFromDisk: AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType>,
         loadedFromCloudAndSaved: AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType>) {
        prescriptions = []
        loadLocalPublisher = loadFromDisk
        loadRemoteAndSavePublisher = loadedFromCloudAndSaved
    }

    func loadLocal() -> AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType> {
        loadLocalCallsCount += 1
        return loadLocalPublisher
    }

    func loadRemoteAndSave(for _: String?) -> AnyPublisher<[GroupedPrescription], AnyErxTaskRepository.ErrorType> {
        loadRemoteAndSaveCallsCount += 1
        return loadRemoteAndSavePublisher
    }
}
