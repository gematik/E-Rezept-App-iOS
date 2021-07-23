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
import CoreData
import eRpKit
import Foundation
import GemCommonsKit
#if os(iOS)
import UIKit
#endif

/// Local store for ErxTasks
public class ErxTaskCoreDataStore {
    private var removeNotificationObserver: (() -> Void)?
    let foregroundQueue: DispatchQueue
    let backgroundQueue: DispatchQueue
    let container: NSPersistentContainer

    /// Initialize an ErxTask Core Data Store
    ///
    /// - Parameters:
    ///   - url: the database location
    ///   - excludeFromBackup: true, the database file(s) is/are excluded from backup
    ///   - level: the File protection level
    ///   - notificationCenter: NC to use for `UIApplication.willResignActiveNotification` to allow for saving on exit
    ///                         (Default: NotificationCenter.default)
    ///   - fileManager: FileManager for the file operations (Default: FileManager.default)
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///                 other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "erx-task-data-source-queue", qos: .userInitiated))
    /// - Throws: `ErxTaskCoreDataStore.Error` when initialization fails
    public required init(
        url: URL,
        excludeFromBackup: Bool = true,
        fileProtection level: FileProtectionType,
        notificationCenter: NotificationCenter = NotificationCenter.default,
        fileManager: FileManager = FileManager.default,
        foregroundQueue: DispatchQueue = DispatchQueue.main,
        backgroundQueue: DispatchQueue = DispatchQueue(label: "erx-task-data-source-queue", qos: .userInitiated)
    ) throws {
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
        container = try Self.provideContainer(
            fileManager,
            databaseUrl: url,
            excludeFromBackup: excludeFromBackup,
            fileProtectionType: level
        )

        // Register for enter background notification so we can still save our context(s) if needed
        #if os(iOS)
        let notificationObserver = notificationCenter.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            do {
                try self?.saveContext()
            } catch {
                DLog("Error while trying to save context: \(error)")
            }
        }
        removeNotificationObserver = {
            notificationCenter.removeObserver(notificationObserver)
        }
        // else
        // other platforms are unsupported atm
        #endif
    }

    /// Remove notifications
    deinit {
        removeNotificationObserver?()
    }

    // MARK: - Core Data Saving support

    private func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
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
}
