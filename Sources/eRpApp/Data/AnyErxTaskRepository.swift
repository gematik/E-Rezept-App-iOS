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
import CoreData
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage

struct AnyErxTaskRepository: ErxTaskRepository {
    typealias ErrorType = ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType>

    private let loadRemoteById: (ErxTask.ID, String?) -> AnyPublisher<ErxTask?, ErrorType>
    private let loadLocalById: (ErxTask.ID, String?) -> AnyPublisher<ErxTask?, ErrorType>
    private let loaderLocal: AnyPublisher<[ErxTask], ErrorType>
    private let loaderRemote: AnyPublisher<[ErxTask], ErrorType>
    private let saver: ([ErxTask]) -> AnyPublisher<Bool, ErrorType>
    private let deleter: ([ErxTask]) -> AnyPublisher<Bool, ErrorType>
    private let redeemer: ([ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType>
    private let communicationLoader: (ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], ErrorType>
    private let communicationSaver: ([ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType>
    private let countUnreadCommunications: (ErxTask.Communication.Profile) -> AnyPublisher<Int, ErrorType>

    init<Repository: ErxTaskRepository>(_ repository: AnyPublisher<Repository, Never>)
        where Repository.ErrorType == ErrorType {
        loadRemoteById = { id, accessCode in // swiftlint:disable:this identifier_name
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.loadRemote(by: id, accessCode: accessCode) }
                .eraseToAnyPublisher()
        }
        loadLocalById = { id, accessCode in // swiftlint:disable:this identifier_name
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.loadLocal(by: id, accessCode: accessCode) }
                .eraseToAnyPublisher()
        }

        loaderLocal = repository.setFailureType(to: ErrorType.self)
            .flatMap { $0.loadLocalAll() }
            .eraseToAnyPublisher()
        loaderRemote = repository.setFailureType(to: ErrorType.self)
            .flatMap { $0.loadRemoteAll(for: Locale.current.languageCode) }
            .eraseToAnyPublisher()
        saver = { erxTasks in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.save(erxTasks: erxTasks) }
                .eraseToAnyPublisher()
        }
        deleter = { erxTasks in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.delete(erxTasks: erxTasks) }
                .eraseToAnyPublisher()
        }
        redeemer = { erxTaskOrders in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.redeem(orders: erxTaskOrders) }
                .eraseToAnyPublisher()
        }

        communicationLoader = { profile in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.loadLocalCommunications(for: profile) }
                .eraseToAnyPublisher()
        }
        communicationSaver = { communications in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.saveLocal(communications: communications) }
                .eraseToAnyPublisher()
        }
        countUnreadCommunications = { profile in
            repository.setFailureType(to: ErrorType.self)
                .flatMap { $0.countAllUnreadCommunications(for: profile) }
                .eraseToAnyPublisher()
        }
    }

    func loadRemote(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
                    accessCode: String?) -> AnyPublisher<ErxTask?, ErrorType> {
        loadRemoteById(id, accessCode)
    }

    func loadLocal(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
                   accessCode: String?) -> AnyPublisher<ErxTask?, ErrorType> {
        loadLocalById(id, accessCode)
    }

    func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType> {
        loaderLocal
    }

    func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErrorType> {
        loaderRemote
    }

    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        saver(erxTasks)
    }

    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        deleter(erxTasks)
    }

    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType> {
        redeemer(orders)
    }

    func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType> {
        communicationLoader(profile)
    }

    func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType> {
        communicationSaver(communications)
    }

    func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType> {
        countUnreadCommunications(profile)
    }
}
