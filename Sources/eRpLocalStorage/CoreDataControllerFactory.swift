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

import CoreData
import Dependencies
import DependenciesMacros
import Foundation
import Sharing

/// Instance of conforming type know how to instantiate a `CoreDataController`.
@DependencyClient
public struct CoreDataControllerFactory {
    /// The database location on device
    public var databaseUrl: @Sendable () -> URL = { defaultDatabaseUrl }
    /// Provides an instance of  `CoreDataController`
    public var loadCoreDataController: @Sendable () throws -> CoreDataController
}

/// Factory for all public `eRpLocalStorage` instances.
/// Guarantees to always return the same instance of `CoreDataController` during it's lifetime
extension CoreDataControllerFactory: DependencyKey {
    public static let liveValue: CoreDataControllerFactory = Self(
        databaseUrl: {
            NSPersistentContainer.defaultDirectoryURL()
        },
        loadCoreDataController: {
            @Shared(.coreDataController) var coreDataController

            if let controller = coreDataController {
                return controller
            }

            guard Thread.isMainThread else {
                return try DispatchQueue.main.sync {
                    try loadCoreDataController()
                }
            }

            func loadCoreDataController() throws -> CoreDataController {
                let controller = try CoreDataController(
                    url: defaultDatabaseUrl,
                    fileProtection: .completeUnlessOpen
                )
                $coreDataController.withLock { $0 = controller }
                return controller
            }
            return try loadCoreDataController()
        }
    )

    public static let testValue: CoreDataControllerFactory = Self()
}

extension SharedReaderKey
    where Self == InMemoryKey<CoreDataController?>.Default {
    /// cached CoreDataController stored in memory
    public static var coreDataController: Self {
        Self[.inMemory("cached_coredata_dontroller"), default: nil]
    }
}

extension DependencyValues {
    /// Access to the coreDataControllerFactory dependency.
    public var coreDataControllerFactory: CoreDataControllerFactory {
        get { self[CoreDataControllerFactory.self] }
        set { self[CoreDataControllerFactory.self] = newValue }
    }
}

extension CoreDataControllerFactory {
    /// The database location on device
    public static let defaultDatabaseUrl: URL = {
        guard let filePath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("ErxTask.db") else {
            preconditionFailure("Could not create a filePath for the local storage data store.")
        }
        return filePath
    }()

    /// Failing version of `CoreDataController`
    public static let failing = CoreDataControllerFactory(
        databaseUrl: { URL(fileURLWithPath: "") },
        loadCoreDataController: {
            struct LoadError: Error {}
            assertionFailure("should not have been called")
            throw LoadError()
        }
    )
}
