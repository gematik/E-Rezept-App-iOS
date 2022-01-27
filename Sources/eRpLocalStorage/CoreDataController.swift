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
import Foundation
import GemCommonsKit
#if os(iOS)
import UIKit
#endif

/// Holds the NSPersistentContainer for accessing core data entities of the `ErxTask` module
public class CoreDataController {
    let container: NSPersistentContainer

    /// Initialize a CoreDataController
    ///
    /// - Parameters:
    ///   - url: the database location
    ///   - excludeFromBackup: true, the database file(s) is/are excluded from backup
    ///   - level: the File protection level
    ///   - fileManager: FileManager for the file operations (Default: FileManager.default)
    /// - Throws: `CoreDataController.Error` when initialization fails
    public required init(
        url: URL,
        excludeFromBackup: Bool = true,
        fileProtection level: FileProtectionType,
        fileManager: FileManager = FileManager.default
    ) throws {
        container = try Self.provideContainer(
            fileManager,
            databaseUrl: url,
            excludeFromBackup: excludeFromBackup,
            fileProtectionType: level
        )
    }

    private static func provideContainer(
        _ fileManager: FileManager,
        databaseUrl: URL,
        excludeFromBackup: Bool,
        fileProtectionType: FileProtectionType
    ) throws -> NSPersistentContainer {
        let bundle = Bundle(for: ErxTaskCoreDataStore.self)
        guard let modelUrl = bundle.url(forResource: "ErxTask", withExtension: "momd") else {
            preconditionFailure("Unable to locate ErxTask momd file in Bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelUrl) else {
            preconditionFailure("Unable to load ErxTask model into a NSManagedObjectModel")
        }
        let container = NSPersistentContainer(name: "ErxTask", managedObjectModel: mom)

        // Add Persistent Store
        let protectedStoreDescription = NSPersistentStoreDescription(url: databaseUrl)
        protectedStoreDescription.type = NSSQLiteStoreType
        #if !os(macOS)
        protectedStoreDescription.setOption(
            fileProtectionType as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
        #endif
        container.persistentStoreDescriptions = [protectedStoreDescription]

        var error: Error?
        container.loadPersistentStores { store, err in
            if let err = err {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is
                   locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                error = .initialization(error: err)
                return
            }

            if excludeFromBackup, let storeUrl = store.url {
                do {
                    _ = try fileManager.excludeFileFromBackup(filePath: storeUrl).get()
                } catch let err {
                    error = .initialization(error: err)
                    return
                }
            }

            // Merge the changes from other contexts automatically.
            container.viewContext.automaticallyMergesChangesFromParent = true
            // A policy that merges conflicts between the persistent store's version of the object and the current
            // context's version by individual property, with the store's changes trumping the context's changes.
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }
        if let error = error {
            throw error
        }
        return container
    }

    /// Destroy a persistent store.
    ///
    /// - Parameter storeURL: A `URL` for the persistent store to be destroyed.
    /// - Throws: If the store cannot be destroyed.
    public func destroyPersistentStore(at storeURL: URL) throws {
        let psc = container.persistentStoreCoordinator
        try psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
    }
}

extension CoreDataController {
    public enum Error: Swift.Error, LocalizedError, Equatable {
        case initialization(error: Swift.Error)

        public var errorDescription: String? {
            switch self {
            case let .initialization(error: error):
                return error.localizedDescription
            }
        }

        public static func ==(lhs: CoreDataController.Error, rhs: CoreDataController.Error) -> Bool {
            switch (lhs, rhs) {
            case let (initialization(error: lhsError), initialization(error: rhsError)): return lhsError
                .localizedDescription == rhsError.localizedDescription
            }
        }
    }
}
