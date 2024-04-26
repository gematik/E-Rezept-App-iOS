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

import Combine
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import TestUtils
import XCTest

// swiftlint:disable file_length
final class MedicationScheduleStoreTest: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var coreDataFactory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory
            .appendingPathComponent("testDB_MedicationScheduleCoreDataStoreTest")
    }

    override func tearDown() {
        // important to destory the store so that each test starts with an empty database
        if let controller = try? coreDataFactory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = coreDataFactory else {
            #if os(macOS)
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: FileProtectionType(rawValue: "none")
            )

            #else
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: .completeUnlessOpen
            )
            #endif
            coreDataFactory = factory
            return factory
        }
        return factory
    }

    private func loadErxCoreDataStore() -> MedicationScheduleCoreDataStore {
        MedicationScheduleCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: .immediate,
            backgroundQueue: .main
        )
    }

    func testDeleteMedicationSchedule() throws {
        let sut = loadErxCoreDataStore()
        let expected = [
            MedicationSchedule.Fixtures.medicationScheduleWFor_taskId_1,
            MedicationSchedule.Fixtures.medicationScheduleWFor_taskId_2,
        ]

        let saveResult = try sut.save(medicationSchedules: expected)
        expect(saveResult).to(equal(expected))

        // let fetchResult = try sut.fetchAll()
        // expect(fetchResult).to(equal(expected))
    }
}
