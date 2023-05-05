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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class RedeemMethodsDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        RedeemMethodsDomain.State,
        RedeemMethodsDomain.Action,
        RedeemMethodsDomain.State,
        RedeemMethodsDomain.Action,
        Void
    >

    var erxTask: ErxTask!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let patient = ErxPatient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789"
        )
        let medication = ErxMedication(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: .init(numerator: .init(value: "10")),
            dosageForm: "PUL",
            dose: "N1"
        )
        let practitioner = ErxPractitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )
        let organization = ErxOrganization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )
        let accidentInfo = AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "1234567890",
            date: "9.4.2021"
        )
        erxTask = ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.tomorrow),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication,
            medicationRequest: .init(
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                accidentInfo: accidentInfo
            ),
            patient: patient,
            practitioner: practitioner,
            organization: organization
        )
    }

    lazy var scannedTask: ErxTask = {
        .init(
            identifier: "34235f983-1e67-331g-8955-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            redeemedOn: nil,
            source: .scanner
        )
    }()

    func testStore() -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        return TestStore(
            initialState: RedeemMethodsDomain.State(
                erxTasks: [erxTask, scannedTask]
            ),
            reducer: RedeemMethodsDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
        }
    }

    /// Tests to open the redeem matrix code view
    func testOpenDataMatrixCodeRedeemScreen() {
        let store = testStore()

        let expectedState = RedeemMatrixCodeDomain.State(
            erxTasks: [erxTask, scannedTask]
        )

        // when
        store.send(.setNavigation(tag: .matrixCode)) { sut in
            // then
            sut.destination = .matrixCode(expectedState)
        }
    }

    func testOpenPharmacySearchScreen() {
        let store = testStore()

        let expectedState = PharmacySearchDomain.State(
            erxTasks: [erxTask, scannedTask]
        )

        // when
        store.send(.setNavigation(tag: .pharmacySearch)) { sut in
            // then
            sut.destination = .pharmacySearch(expectedState)
        }
    }
}
