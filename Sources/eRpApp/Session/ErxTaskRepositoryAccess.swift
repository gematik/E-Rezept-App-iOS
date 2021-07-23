//
//  Copyright (c) 2021 gematik GmbH
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
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage

typealias ErxTaskRepositoryError = ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType>

/// sourcery: StreamWrapped
protocol ErxTaskRepositoryAccess {
    /// Loads data locally (from disk).
    func loadLocal() -> AnyPublisher<[ErxTask], ErxTaskRepositoryError>

    /// Loads data from remote (server) and saves them to the local store.
    func loadRemoteAndSave(for locale: String?) -> AnyPublisher<[ErxTask], ErxTaskRepositoryError>

    /// Saves ErxTasks locally (to disk).
    func save(_ erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError>

    /// Deletes ErxTasks locally (from disk).
    func delete(_ erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError>

    /// Finds ErxTasks locally by ID and accessCode.
    func find(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
              accessCode: String?) -> AnyPublisher<ErxTask?, ErxTaskRepositoryError>

    /// Sends an order request per order. The pharmacy has to approve the order before the ErxTask is redeemed
    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErxTaskRepositoryError>

    /// Loads all local communications for the given profile
    /// - Parameter profile communication profile used as filter
    func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErxTaskRepositoryError>

    func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxTaskRepositoryError>

    /// Returns the number of all unread communications that are stored locally
    /// - Parameter profile: communication profile used as filter
    func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErxTaskRepositoryError>
}

extension AnyErxTaskRepository: ErxTaskRepositoryAccess {
    func loadLocal() -> AnyPublisher<[ErxTask], ErxTaskRepositoryError> {
        loadLocalAll()
    }

    func find(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
              accessCode: String?) -> AnyPublisher<ErxTask?, ErxTaskRepositoryError> {
        loadLocal(by: id, accessCode: accessCode)
    }

    func loadRemoteAndSave(for locale: String?) -> AnyPublisher<[ErxTask], ErxTaskRepositoryError> {
        loadRemoteAll(for: locale)
    }

    func save(_ erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        save(erxTasks: erxTasks)
    }

    func delete(_ erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxTaskRepositoryError> {
        delete(erxTasks: erxTasks)
    }
}
