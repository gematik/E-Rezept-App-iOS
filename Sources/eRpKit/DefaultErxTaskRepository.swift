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
import Foundation

/// Repository for the app to the ErxTask data layer handling the syncing between its data stores.
public class DefaultErxTaskRepository<D: ErxTaskDataStore, C: ErxTaskDataStore>: ErxTaskRepository {
    /// ErxTaskRepository ErrorType
    public typealias ErrorType = ErxRepositoryError<D.ErrorType, C.ErrorType>

    private let disk: D
    private let cloud: C

    /// Initialize a new ErxTaskRepository as the gateway between Presentation layer and underlying data layer(s)
    ///
    /// - Parameters:
    ///   - disk: The data source that represents the disk/local storage
    ///   - cloud: The data source that represents the cloud/remote storage
    public required init(disk: D, cloud: C) {
        self.disk = disk
        self.cloud = cloud
    }

    /// Get ErxTask by id from cloud (if possible)
    ///
    /// - Parameters:
    ///   - id: String that identifies the requested `ErxTask`
    ///   - accessCode: When nil only load from local store(s)
    /// - Returns: AnyPublisher that emits the requested `ErxTask` or `DefaultErxTaskRepository.Error`
    public func loadRemote(
        by id: ErxTask.ID, // swiftlint:disable:this identifier_name
        accessCode: String?
    ) -> AnyPublisher<ErxTask?, ErrorType> {
        if let accessCode = accessCode {
            return cloud.fetchTask(by: id, accessCode: accessCode)
                .mapError {
                    .remote($0)
                }
                .compactMap { $0 }
                .flatMap { task in
                    self.disk.save(tasks: [task])
                        .map { _ in task }
                        .mapError {
                            .local($0)
                        }
                }
                .eraseToAnyPublisher()
        } else {
            return loadLocal(by: id, accessCode: nil)
        }
    }

    /// Load ErxTask by id from local store
    /// - Parameters:
    ///   - id: String that identifies the requested `ErxTask`
    ///   - accessCode: String representing the accessCode. Can be nil
    /// - Returns: AnyPublisher that emits the requested `ErxTask` or `DefaultErxTaskRepository.Error`
    public func loadLocal(
        by id: ErxTask.ID, // swiftlint:disable:this identifier_name
        accessCode: String?
    ) -> AnyPublisher<ErxTask?, ErrorType> {
        disk.fetchTask(by: id, accessCode: accessCode)
            .mapError {
                .local($0)
            }
            .eraseToAnyPublisher()
    }

    /// Load all local tasks
    ///
    /// - Returns: AnyPublisher that emits an array of all `ErxTask`s or `DefaultErxTaskRepository.Error`
    public func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType> {
        disk.listAllTasks()
            .mapError {
                .local($0)
            }
            .eraseToAnyPublisher()
    }

    /// Load all ErxTasks from a remote (server).
    /// - Parameters:
    ///   - locale: The locale to fetch the audit events by
    /// - Returns: AnyPublisher that emits an array of all `ErxTask`s or `DefaultErxTaskRepository.Error`
    public func loadRemoteAll(for locale: String?) -> AnyPublisher<[ErxTask], ErrorType> {
        cloud.listAllTasks()
            .mapError {
                .remote($0)
            }
            .flatMap {
                self.disk.save(tasks: $0)
                    .mapError {
                        .local($0)
                    }
            }
            .flatMap { _ in
                self.disk.listAllAuditEvents(after: nil,
                                             for: locale)
                    .first() // only read once, we are interested in latest event to fetch all younger events.
                    .mapError {
                        .local($0)
                    }
            }
            .flatMap {
                self.cloud.listAllAuditEvents(after: $0.first?.timestamp,
                                              for: locale)
                    .mapError {
                        .remote($0)
                    }
            }
            .flatMap {
                self.disk.save(auditEvents: $0)
                    .mapError {
                        .local($0)
                    }
            }
            .flatMap { _ in
                self.cloud.listAllCommunications(for: .all)
                    .mapError {
                        .remote($0)
                    }
            }
            .flatMap {
                self.disk.save(communications: $0)
                    .mapError {
                        .local($0)
                    }
            }
            .flatMap { _ -> AnyPublisher<[ErxTask], ErrorType> in
                self.disk.listAllTasks()
                    .first()
                    .mapError {
                        .local($0)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Save an array of `ErxTask`s
    ///
    /// - Parameter erxTasks: The tasks that should be saved
    /// - Returns: AnyPublisher that emits `true` if saving was successful or returns an`ErrorType`
    public func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        disk.save(tasks: erxTasks)
            .mapError {
                .local($0)
            }
            .eraseToAnyPublisher()
    }

    /// Delete an array of `ErxTask`s
    ///
    /// - Parameter erxTasks: The tasks that should be deleted
    /// - Returns: AnyPublisher that emits `true` if deletion was successful or returns an`ErrorType`
    public func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        // Delete only locally when all tasks are scanned tasks
        if erxTasks.allSatisfy({ $0.source == ErxTask.Source.scanner }) {
            return disk.delete(tasks: erxTasks)
                .mapError {
                    .local($0)
                }
                .eraseToAnyPublisher()
        // Delete remote & locally when at least one is not a scanned task
        } else {
            // 1. Delete on cloud/server
            return cloud.delete(tasks: erxTasks)
            .mapError {
                .remote($0)
            }

            // 2. Delete on disk/locally
            .flatMap { _ in
                self.disk.delete(tasks: erxTasks)
                    .mapError {
                        .local($0)
                    }
            }
            .eraseToAnyPublisher()
        }
    }

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter orders: Array of an order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: `true` if the server has received the order
    public func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType> {
        cloud.redeem(orders: orders)
            .mapError { .remote($0) }
            .eraseToAnyPublisher()
    }

    public func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType> {
        disk.listAllCommunications(for: profile)
            .mapError { .local($0) }
            .eraseToAnyPublisher()
    }

    /// Save communications `isRead` property to local data store.
    /// - Parameter communications: communications where the `isRead` state should be changed.
    public func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType> {
        disk.save(communications: communications)
            .mapError { .local($0) }
            .eraseToAnyPublisher()
    }

    /// Returns a count for all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    public func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType> {
        disk.countAllUnreadCommunications(for: profile)
            .mapError { .local($0) }
            .eraseToAnyPublisher()
    }
}
