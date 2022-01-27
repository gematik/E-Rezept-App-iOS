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
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Nimble
import XCTest

final class GroupedPrescriptionRepositoryTests: XCTestCase {
    func testLoadingErxTasksFromDiskAndConvertingInGroupedPrescriptions() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadLocal().test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 6 groups
            expect(groupedPrescriptions.count) == 6
            expect(groupedPrescriptions[0].prescriptions.count) == 4
            expect(groupedPrescriptions[0].id) ==
                "490f983-1e67-11b2-8555-63bf44e44fb8-7390f983-1e67-11b2-8555-63bf44e44fb8-6390f983-1e67-11b2-8555-63bf44e44fb8-5390f983-1e67-11b2-8555-63bf44e44fb8" // swiftlint:disable:this line_length
            expect(groupedPrescriptions[0].isArchived).to(beFalse())

            expect(groupedPrescriptions[1].prescriptions.count) == 3
            expect(groupedPrescriptions[1].id) ==
                "7390f983-1e67-11b2-8555-63bf44e44f3c-7390f983-1e67-11b2-8555-63bf44e44f4c-7390f983-1e67-11b2-8555-63bf44e44f5c" // swiftlint:disable:this line_length
            expect(groupedPrescriptions[1].isArchived).to(beFalse())

            expect(groupedPrescriptions[2].prescriptions.count) == 2
            expect(groupedPrescriptions[2].id) ==
                "7390f983-1e67-11b2-8555-63bf44e44f1c-7390f983-1e67-11b2-8555-63bf44e44f2c"
            expect(groupedPrescriptions[2].isArchived).to(beTrue())

            expect(groupedPrescriptions[3].prescriptions.count) == 1
            expect(groupedPrescriptions[3].id) == "3390f983-1e67-11b2-8555-63bf44e44fb8"
            expect(groupedPrescriptions[3].isArchived).to(beTrue())

            expect(groupedPrescriptions[4].prescriptions.count) == 3
            expect(groupedPrescriptions[4].id) ==
                "1390f983-1e67-11b2-8555-63bf44e44fb8-0390f983-1e67-11b2-8555-63bf44e44fb8-2390f983-1e67-11b2-8555-63bf44e44fb8" // swiftlint:disable:this line_length
            expect(groupedPrescriptions[4].isArchived).to(beFalse())

            expect(groupedPrescriptions[5].prescriptions.count) == 2
            expect(groupedPrescriptions[5].id) ==
                "7390f983-1e67-11b2-8555-63bf44e44f7c-7390f983-1e67-11b2-8555-63bf44e44f6c"
            expect(groupedPrescriptions[5].isArchived).to(beTrue())

            let notArchivedPrescriptions = groupedPrescriptions.flatMap(\.prescriptions).filter { !$0.isArchived }
            expect(notArchivedPrescriptions.count) == 10

            let archivedPrescriptions = groupedPrescriptions.flatMap(\.prescriptions).filter(\.isArchived)
            expect(archivedPrescriptions.count) == 5

            let archivedGroups: [GroupedPrescription] = groupedPrescriptions.filter(\.isArchived)
            expect(archivedGroups.count) == 3
        })
    }

    func testLoadingErxTasksFromCloudAndConvertingInGroupedPrescriptions() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadRemoteAndSave(for: nil).test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 6 groups
            expect(groupedPrescriptions.count) == 6
            expect(groupedPrescriptions[0].prescriptions.count) == 4
            expect(groupedPrescriptions[0].title) == "Dr. A"
            expect(groupedPrescriptions[0].isArchived).to(beFalse())

            expect(groupedPrescriptions[1].prescriptions.count) == 3
            expect(groupedPrescriptions[1].title) == "Dr. B"
            expect(groupedPrescriptions[1].isArchived).to(beFalse())

            expect(groupedPrescriptions[2].prescriptions.count) == 2
            expect(groupedPrescriptions[2].title) == ""
            expect(groupedPrescriptions[2].isArchived).to(beTrue())

            expect(groupedPrescriptions[3].prescriptions.count) == 1
            expect(groupedPrescriptions[3].title) == "Dr. Abgelaufen"
            expect(groupedPrescriptions[3].isArchived).to(beTrue())

            expect(groupedPrescriptions[4].prescriptions.count) == 3
            expect(groupedPrescriptions[4].title) == "Dr. A"
            expect(groupedPrescriptions[4].isArchived).to(beFalse())

            expect(groupedPrescriptions[5].prescriptions.count) == 2
            expect(groupedPrescriptions[5].title) == "Dr. B"
            expect(groupedPrescriptions[5].isArchived).to(beTrue())

            let notArchivedPrescriptions = groupedPrescriptions.flatMap(\.prescriptions).filter { !$0.isArchived }
            expect(notArchivedPrescriptions.count) == 10

            let archivedPrescriptions = groupedPrescriptions.flatMap(\.prescriptions).filter(\.isArchived)
            expect(archivedPrescriptions.count) == 5

            let archivedGroups: [GroupedPrescription] = groupedPrescriptions.filter(\.isArchived)
            expect(archivedGroups.count) == 3
        })
    }
}
