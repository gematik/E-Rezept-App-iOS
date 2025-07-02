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

import Combine
import CoreData
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

class FetchRequestPublisherTest: XCTestCase {
    private var moc: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // swiftlint:disable force_unwrapping
        let modelUrl = Bundle.module.url(forResource: "ErxTask", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelUrl)!
        // swiftlint:enable force_unwrapping
        let container = NSPersistentContainer(name: "ErxTask", managedObjectModel: mom)

        // Add Persistent Store
        let protectedStoreDescription = NSPersistentStoreDescription()
        protectedStoreDescription.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [protectedStoreDescription]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        moc = container.viewContext
    }

    func testPublisher() {
        var receivedValues = [[ErxTaskEntity]]()
        var receivedCompletions = [Subscribers.Completion<Error>]()

        // Register fetch request
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: true)]
        let cancellable = moc.publisher(for: request)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })
        // Expect empty list as there are no entities saved thus far
        expect(cancellable).toNot(beNil())
        expect(receivedCompletions.count) == 0
        expect(receivedValues.count) == 1
        XCTAssertTrue(receivedValues[0].isEmpty)

        // Insert entity in MOC and observe receivedValues
        let task = ErxTaskEntity(context: moc)
        task.identifier = "id-1"
        task.accessCode = "access-code-1"
        expect(try self.moc.save()).toNot(throwError())

        expect(receivedValues.count) == 2
        expect(receivedValues.last?.first?.identifier) == "id-1"
        expect(receivedValues.last?.first?.accessCode) == "access-code-1"
        expect(receivedCompletions.count) == 0

        // Test update/modify
        task.author = "Jane Doe"
        expect(try self.moc.save()).toNot(throwError())

        expect(receivedValues.count) == 3
        expect(receivedCompletions.count) == 0

        // Test delete
        moc.delete(task)
        expect(try self.moc.save()).toNot(throwError())

        expect(receivedValues.count) == 4
        expect(receivedCompletions.count) == 0

        // Deregister and insert a second entity and observe the receivedValues not being updated anymore
        cancellable.cancel()

        let task2 = ErxTaskEntity(context: moc)
        task2.identifier = "id-2"
        task2.accessCode = "access-code-2"
        expect(try self.moc.save()).toNot(throwError())

        expect(receivedValues.count) == 4
        expect(receivedCompletions.count) == 0
    }
}
