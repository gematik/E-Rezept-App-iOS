//
//  Copyright (c) 2024 gematik GmbH
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

import Foundation

/// Instance of conforming type know how to instantiate a `CoreDataController`.
public protocol CoreDataControllerFactory {
    /// The database location on device
    var databaseUrl: URL { get }
    /// Provides an instance of  `CoreDataController`
    func loadCoreDataController() throws -> CoreDataController
}

/// Factory for all public `eRpLocalStorage` instances.
/// Guarantees to always return the same instance of `CoreDataController` during it's lifetime
public class LocalStoreFactory: CoreDataControllerFactory {
    private let fileProtection: FileProtectionType
    public let databaseUrl: URL
    private var coreDataController: CoreDataController?

    /// Initialize a CoreDataControllerFactory
    /// - Parameters:
    ///   - databaseUrl: The database location on device
    ///   - fileProtection:The file protection level
    public init(
        url databaseUrl: URL = defaultDatabaseUrl,
        fileProtection: FileProtectionType = .completeUnlessOpen
    ) {
        self.databaseUrl = databaseUrl
        // [REQ:BSI-eRp-ePA:O.Purp_8#2] CoreData databases are protected
        self.fileProtection = fileProtection
    }

    /// Lazy initializer for the CoreDataController
    /// - Throws: When store can not be initialized
    /// - Returns: The same instance of `CoreDataController` during the lifetime of `CoreDataControllerFactory`
    public func loadCoreDataController() throws -> CoreDataController {
        if let coreDataController = coreDataController {
            return coreDataController
        }

        guard Thread.isMainThread else {
            return try DispatchQueue.main.sync {
                try loadCoreDataController()
            }
        }

        let controller = try CoreDataController(url: databaseUrl, fileProtection: fileProtection)
        coreDataController = controller
        return controller
    }

    /// Default Local FHIR data store url
    public static var defaultDatabaseUrl: URL = {
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
}

extension LocalStoreFactory {
    public struct Failing: CoreDataControllerFactory {
        public var databaseUrl = URL(fileURLWithPath: "")
        private var coreDataController: CoreDataController!

        public func loadCoreDataController() throws -> CoreDataController {
            assertionFailure("should not have been called")
            return coreDataController
        }
    }

    /// Returns a factory which fails returning a CoreDataController
    public static let failing = Failing()
}
