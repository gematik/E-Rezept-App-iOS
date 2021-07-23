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
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Nimble
import XCTest

final class GroupedPrescriptionRepositoryTests: XCTestCase {
    func testLoadingErxTasksFromDiscAndConvertingInGroupedPrescriptions() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadLocal().test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 7 groups
            expect(groupedPrescriptions.count) == 7
            // test oldest group to be last
            let groupedPrescription = groupedPrescriptions.last!
            expect(groupedPrescription.prescriptions.count) == 5
            expect(groupedPrescription.title) == "Dr. Dr. med. Carsten van Storchhausen"
            expect(groupedPrescription.authoredOn) == "2020-09-20T14:34:29+00:00"
            // test parsing
            let firstErxTask = groupedPrescription.prescriptions.first
            expect(firstErxTask?.accessCode) == "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
            expect(firstErxTask?.medication?.amount) == 12
            expect(firstErxTask?.medication?.dosageForm) == "TAB"
            expect(firstErxTask?.expiresOn) == "2021-02-20T14:34:29+00:00"
            expect(firstErxTask?.medication?.name) == "Saflorblüten-Extrakt"
            // test sorting by medication text within a group
            expect(firstErxTask?.medication?.name) < (groupedPrescription.prescriptions[1].medication?.name!)!
            expect(groupedPrescription.prescriptions[1].medication?.name!) < groupedPrescription.prescriptions[2]
                .medication!.name!
        })
    }

    func testLoadingErxTasksFromCloudAndConvertingInGroupedPrescriptions() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadRemoteAndSave(for: nil).test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 7 groups
            expect(groupedPrescriptions.count) == 7
            // test oldest group to be last
            let groupedPrescription = groupedPrescriptions.last!
            expect(groupedPrescription.prescriptions.count) == 5
            expect(groupedPrescription.title) == "Dr. Dr. med. Carsten van Storchhausen"
            expect(groupedPrescription.authoredOn) == "2020-09-20T14:34:29+00:00"
            // test parsing
            let firstErxTask = groupedPrescription.prescriptions.first
            expect(firstErxTask?.accessCode) == "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
            expect(firstErxTask?.medication?.amount) == 12
            expect(firstErxTask?.medication?.dosageForm) == "TAB"
            expect(firstErxTask?.expiresOn) == "2021-02-20T14:34:29+00:00"
            expect(firstErxTask?.medication?.name) == "Saflorblüten-Extrakt"
            // test sorting by medication text within a group
            expect(firstErxTask?.medication?.name) < (groupedPrescription.prescriptions[1].medication?.name!)!
            expect(groupedPrescription.prescriptions[1].medication?.name!) < groupedPrescription.prescriptions[2]
                .medication!.name!
        })
    }

    func testLoadingErxTasksFromDiscAndConvertingInRedeemedGroupedPrescriptions() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadLocal().test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 7 groups
            expect(groupedPrescriptions.count) == 7

            // test 13 out of 15 are not redeemed
            let notRedeemed = groupedPrescriptions.flatMap(\.prescriptions).filter { $0.redeemedOn == nil }
            expect(notRedeemed.count) == 13

            let redeemedGroup: [GroupedPrescription] = groupedPrescriptions.filter(\.isRedeemed)
            // test one grouped is redeemed
            expect(redeemedGroup.count) > 0
            // test redeemed group has two redeemed prescriptions
            expect(redeemedGroup.first?.prescriptions.count) == 2
        })
    }

    func testLoadingFromCloudAndGroupedPrescriptionsHasGroupedByPractitionerName() {
        let sut = GroupedPrescriptionInteractor(
            erxTaskInteractor: AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
        )

        sut.loadRemoteAndSave(for: nil).test(expectations: { groupedPrescriptions in
            // swiftlint:disable:previous trailing_closure
            expect(groupedPrescriptions.totalPrescriptionCount) == 15
            // test sorting of prescriptions into 7 groups
            expect(groupedPrescriptions.count) == 7
            // test grouping by practitioner happens when organization name is nil
            expect(groupedPrescriptions.contains(where: { $0.title == "Dr. Black" })).to(beTrue())
            // Dr. White should have 3 prescriptions
            let drWhiteGroup = groupedPrescriptions.filter { $0.title == "Dr. White" }
            expect(drWhiteGroup.first?.prescriptions.count).to(equal(3))
        })
    }
}
