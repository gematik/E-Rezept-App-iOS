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
import eRpKit
import XCTest

class MockErxTaskRepositoryAccess: ErxTaskRepositoryAccess {
    var loadLocalPublisher: AnyPublisher<[ErxTask], ErxTaskRepositoryError>
    var loadLocalCallsCount = 0
    var loadLocalCalled: Bool {
        loadLocalCallsCount > 0
    }

    var loadRemoteAndSavedPublisher: AnyPublisher<[ErxTask], ErxTaskRepositoryError>
    var loadRemoteAndSavedCallsCount = 0
    var loadRemoteAndSavedCalled: Bool {
        loadRemoteAndSavedCallsCount > 0
    }

    var savePublisher: AnyPublisher<Bool, ErxTaskRepositoryError>
    var saveCallsCount = 0
    var saveCalled: Bool {
        saveCallsCount > 0
    }

    var deletePublisher: AnyPublisher<Bool, ErxTaskRepositoryError>
    var deleteCallsCount = 0
    var deleteCalled: Bool {
        deleteCallsCount > 0
    }

    var findPublisher: AnyPublisher<ErxTask?, ErxTaskRepositoryError>
    var findCallsCount = 0
    var findCalled: Bool {
        findCallsCount > 0
    }

    var redeemPublisher: AnyPublisher<Bool, ErxTaskRepositoryError>
    var redeemCallsCount = 0
    var redeemCalled: Bool {
        redeemCallsCount > 0
    }

    var listCommunicationsPublisher: AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError>
    var listCommunicationsCallsCount = 0
    var listCommunicationsCalled: Bool {
        listCommunicationsCallsCount > 0
    }

    var countUnreadCommunicationsPublisher: AnyPublisher<Int, ErxTaskRepositoryError>
    var countUnreadCommunicationsCallsCount = 0
    var countUnreadCommunicationsCalled: Bool {
        countUnreadCommunicationsCallsCount > 0
    }

    var saveCommunicationsPublisher: AnyPublisher<Bool, ErxTaskRepositoryError>
    var saveCommunicationsCallsCount = 0
    var saveCommunicationsCalled: Bool {
        saveCommunicationsCallsCount > 0
    }

    init(stored erxTasks: [ErxTask] = [],
         saveErxTasks: AnyPublisher<Bool, ErxTaskRepositoryError> = failing(),
         deleteErxTasks: AnyPublisher<Bool, ErxTaskRepositoryError> = failing(),
         find: AnyPublisher<ErxTask?, ErxTaskRepositoryError> = failing(),
         redeemOrder: AnyPublisher<Bool, ErxTaskRepositoryError> = failing(),
         listCommunications: AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError> = failing(),
         countCommunications: AnyPublisher<Int, ErxTaskRepositoryError> = failing(),
         saveCommunications: AnyPublisher<Bool, ErxTaskRepositoryError> = failing()) {
        loadLocalPublisher = Just(erxTasks)
            .setFailureType(to: ErxTaskRepositoryError.self)
            .eraseToAnyPublisher()
        loadRemoteAndSavedPublisher = Just(erxTasks)
            .setFailureType(to: ErxTaskRepositoryError.self)
            .eraseToAnyPublisher()
        savePublisher = saveErxTasks
        deletePublisher = deleteErxTasks
        findPublisher = find
        redeemPublisher = redeemOrder
        listCommunicationsPublisher = listCommunications
        countUnreadCommunicationsPublisher = countCommunications
        saveCommunicationsPublisher = saveCommunications
    }

    func loadLocal() -> AnyPublisher<[ErxTask], ErxTaskRepositoryError> {
        loadLocalCallsCount += 1
        return loadLocalPublisher
    }

    func loadRemoteAndSave(for _: String?) -> AnyPublisher<[ErxTask], ErxTaskRepositoryError> {
        loadRemoteAndSavedCallsCount += 1
        return loadRemoteAndSavedPublisher
    }

    func save(_: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        saveCallsCount += 1
        return savePublisher
    }

    func delete(_: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        deleteCallsCount += 1
        return deletePublisher
    }

    func find(by _: ErxTask.ID, accessCode _: String?) -> AnyPublisher<ErxTask?, ErxTaskRepositoryError> {
        findCallsCount += 1
        return findPublisher
    }

    func redeem(orders _: [ErxTaskOrder]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        redeemCallsCount += 1
        return redeemPublisher
    }

    func loadLocalCommunications(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError> {
        listCommunicationsCallsCount += 1
        return listCommunicationsPublisher
    }

    func saveLocal(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        saveCommunicationsCallsCount += 1
        return saveCommunicationsPublisher
    }

    func countAllUnreadCommunications(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErxTaskRepositoryError> {
        countUnreadCommunicationsCallsCount += 1
        return countUnreadCommunicationsPublisher
    }

    static func failing() -> AnyPublisher<ErxTask?, ErxTaskRepositoryError> {
        Deferred { () -> AnyPublisher<ErxTask?, ErxTaskRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(nil).setFailureType(to: ErxTaskRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        Deferred { () -> AnyPublisher<Bool, ErxTaskRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(false).setFailureType(to: ErxTaskRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError> {
        Deferred { () -> AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just([]).setFailureType(to: ErxTaskRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<Int, ErxTaskRepositoryError> {
        Deferred { () -> AnyPublisher<Int, ErxTaskRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(0).setFailureType(to: ErxTaskRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
