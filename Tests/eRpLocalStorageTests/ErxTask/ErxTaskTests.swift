//
//  Copyright (c) 2023 gematik GmbH
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

import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class ErxTaskTests: XCTestCase {
    private var moc: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: ErxTaskCoreDataStore.self)
        // swiftlint:disable force_unwrapping
        let modelUrl = bundle.url(forResource: "ErxTask", withExtension: "momd")!
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

    lazy var task1: ErxTask = {
        ErxTask(identifier: "id_1",
                status: .ready,
                flowType: ErxTask.FlowType.pharmacyOnly,
                lastModified: "2021-07-10T10:55:04+02:00")
    }()

    func testInitFromErxTaskEntitySettingCorrectStatus() throws {
        let redemption = Date()
        let stillRedeeming = redemption.addingTimeInterval(10 * 60 - 1)
        let noLongerRedeeming = redemption.addingTimeInterval(10 * 60 + 1)

        lazy var communication = ErxTask.Communication(
            identifier: "abc",
            profile: .dispReq,
            taskId: "id_1",
            userId: "12345",
            telematikId: "123456",
            timestamp: FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: redemption),
            payloadJSON: ""
        )

        let entity = ErxTaskEntity(task: task1, in: moc)

        var sut = try XCTUnwrap(ErxTask(entity: entity) {
            stillRedeeming
        })
        expect(sut.status).to(equal(.ready))

        let communicationEntity = ErxTaskCommunicationEntity(communication: communication, in: moc)
        entity.addToCommunications(communicationEntity)
        try moc.save()

        sut = try XCTUnwrap(ErxTask(entity: entity) {
            stillRedeeming
        })
        expect(sut.status).to(equal(.inProgress))

        sut = try XCTUnwrap(ErxTask(entity: entity) {
            noLongerRedeeming
        })
        expect(sut.status).to(equal(.ready))
    }
}
