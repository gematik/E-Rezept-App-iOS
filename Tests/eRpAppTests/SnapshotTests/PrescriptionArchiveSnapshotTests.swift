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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PrescriptionArchiveSnapshotTests: ERPSnapshotTestCase {
    let testScheduler = DispatchQueue.immediate
    let initialState = Fixtures.state

    func testPrescriptionArchiveView_Show() {
        let store: StoreOf<PrescriptionArchiveDomain> = Store(initialState: initialState) {
            EmptyReducer()
        }

        let sut = PrescriptionArchiveView(store: store)
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }
}

extension PrescriptionArchiveSnapshotTests {
    enum Fixtures {
        static let state = PrescriptionArchiveDomain.State(
            prescriptions: prescriptions
        )

        static let prescriptions: [Prescription] = [
            expiredErxTask(with: .ready),
            expiredErxTask(with: .inProgress),
            expiredErxTask(with: .computed(status: .dispensed)),
            expiredErxTask(with: .completed),
            ErxTask(
                identifier: "7360f983-1e67-11b2-8555-63bf44e44fb8",
                status: .completed,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
                expiresOn: DemoDate.createDemoDate(.yesterday),
                acceptedUntil: DemoDate.createDemoDate(.yesterday),
                redeemedOn: DemoDate.createDemoDate(.yesterday),
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxMedication(
                    name: "Saflorblüten-Extrakt Pulver Peroral",
                    profile: .pzn,
                    pzn: "06876512",
                    amount: .init(numerator: .init(value: "10")),
                    dosageForm: "PUL",
                    normSizeCode: "N1",
                    batch: .init(
                        lotNumber: "TOTO-5236-VL",
                        expiresOn: "2323-01-26T15:23:21+00:00"
                    )
                ),
                medicationRequest: .init(
                    accidentInfo: AccidentInfo(
                        type: .workAccident,
                        workPlaceIdentifier: "1234567890",
                        date: "9.4.2021"
                    ),
                    quantity: .init(value: "2", unit: "Packungen")
                ),
                patient: ErxPatient(
                    name: "Ludger Königsstein",
                    address: "Musterstr. 1 \n10623 Berlin",
                    birthDate: "22.6.1935",
                    phone: "555 1234567",
                    status: "Mitglied",
                    insurance: "AOK Rheinland/Hamburg",
                    insuranceId: "A123456789",
                    coverageType: .GKV
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. Dr. med. Carsten van Storchhausen",
                    qualification: "Allgemeinarzt/Hausarzt",
                    email: "noreply@google.de",
                    address: "Hinter der Bahn 2\n12345 Berlin"
                ),
                organization: ErxOrganization(
                    identifier: "987654321",
                    name: "Praxis van Storchhausen",
                    phone: "555 76543321",
                    email: "noreply@praxisvonstorchhausen.de",
                    address: "Vor der Bahn 6\n54321 Berlin"
                )
            ),

        ].map {
            Prescription(erxTask: $0, dateFormatter: UIDateFormatter.previewValue)
        }

        static func expiredErxTask(with status: ErxTask.Status) -> ErxTask {
            let referenceDate = Date(timeIntervalSince1970: 1_734_437_459)
            let ninetyTwoDaysBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(from: referenceDate.addingTimeInterval(-60 * 60 * 24 * 92))
            let weekBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(from: referenceDate.addingTimeInterval(-60 * 60 * (24 * 7 + 2)))
            let thirtyDaysBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(from: referenceDate.addingTimeInterval(-60 * 60 * 24 * 30))
            return ErxTask(
                identifier: "34235f983-1e67-22c5-8955-63bf44e44fb8",
                status: status,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: ninetyTwoDaysBefore,
                expiresOn: weekBefore,
                acceptedUntil: thirtyDaysBefore,
                redeemedOn: nil,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxMedication(
                    name: "Vita-Tee",
                    pzn: "06876518",
                    amount: .init(numerator: .init(value: "8")),
                    dosageForm: "INS",
                    normSizeCode: "NB"
                ),
                medicationRequest: .init(
                    accidentInfo: AccidentInfo(
                        type: .workAccident,
                        workPlaceIdentifier: "1234567890",
                        date: "9.4.2021"
                    ),
                    quantity: .init(value: "2", unit: "Packungen")
                ),
                patient: ErxPatient(
                    name: "Ludger Königsstein",
                    address: "Musterstr. 1 \n10623 Berlin",
                    birthDate: "22.6.1935",
                    phone: "555 1234567",
                    status: "Mitglied",
                    insurance: "AOK Rheinland/Hamburg",
                    insuranceId: "A123456789",
                    coverageType: .GKV
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. Dr. med. Carsten van Storchhausen",
                    qualification: "Allgemeinarzt/Hausarzt",
                    email: "noreply@google.de",
                    address: "Hinter der Bahn 2\n12345 Berlin"
                ),
                organization: ErxOrganization(
                    identifier: "987654321",
                    name: "Praxis van Storchhausen",
                    phone: "555 76543321",
                    email: "noreply@praxisvonstorchhausen.de",
                    address: "Vor der Bahn 6\n54321 Berlin"
                )
            )
        }

        static let oldState: PrescriptionArchiveDomain.State = PrescriptionArchiveDomain.Dummies.state
    }
}
