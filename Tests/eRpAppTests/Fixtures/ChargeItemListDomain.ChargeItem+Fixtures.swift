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

@testable import eRpFeatures
import eRpKit
import Foundation

extension ChargeItemListDomain.ChargeItemGroup {
    enum Fixtures {
        static let chargeItemGroup1 = ChargeItemListDomain.ChargeItemGroup(
            id: UUID().uuidString,
            title: "2023",
            chargeSum: "289,80 €",
            chargeItems: [
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem1,
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem2,
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem3,
            ]
        )
        static let chargeItemGroup2 = ChargeItemListDomain.ChargeItemGroup(
            id: UUID().uuidString,
            title: "2022",
            chargeSum: "150 €",
            chargeItems: [
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem4,
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem5,
                ChargeItemListDomain.ChargeItem.Fixtures.chargeItem6,
            ]
        )
    }
}

extension ChargeItemListDomain.ChargeItem {
    enum Fixtures {
        static let chargeItem1 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Ibuprofen",
            localizedDate: "16.12.2024",
            date: Date(timeIntervalSinceNow: 0),
            flags: [
                "Eingereicht",
            ],
            original: ErxSparseChargeItem(
                identifier: "Ibuprofen",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
        static let chargeItem2 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Acnatac",
            localizedDate: "16.12.2024",
            date: Date(timeIntervalSinceNow: 5),
            flags: [
            ],
            original: ErxSparseChargeItem(
                identifier: "Acnatac",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
        static let chargeItem3 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Candesartan",
            localizedDate: "16.12.2024",
            date: Date(timeIntervalSinceNow: 10),
            flags: [
            ],
            original: ErxSparseChargeItem(
                identifier: "Candesartan",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
        static let chargeItem4 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Ramipril, Acanatc, 0,5 M-Calciumchlorid-Lösung DELTAMEDICA, "
                + "Konzentrat zur Herstellung einer Infusionslösung, 100ml",
            localizedDate: "16.12.2023",
            date: Date(timeIntervalSinceNow: 15),
            flags: [
            ],
            original: ErxSparseChargeItem(
                identifier: "Ramipril, Acanatc, 0,5 M-Calciumchlorid-Lösung DELTAMEDICA,"
                    + " Konzentrat zur Herstellung einer Infusionslösung, 100ml",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
        static let chargeItem5 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Acnatac",
            localizedDate: "16.12.2023",
            date: Date(timeIntervalSinceNow: 20),
            flags: [
            ],
            original: ErxSparseChargeItem(
                identifier: "Acnatac",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
        static let chargeItem6 = ChargeItemListDomain.ChargeItem(
            id: UUID().uuidString,
            description: "Candesartan",
            localizedDate: "16.12.2023",
            date: Date(timeIntervalSinceNow: 25),
            flags: [
            ],
            original: ErxSparseChargeItem(
                identifier: "Candesartan",
                taskId: "task id",
                fhirData: Data(),
                enteredDate: "123"
            )
        )
    }
}
