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

import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

extension AppStoreSnapshotTests {
    func main() -> some View {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2019-12-20",
            prescriptions: ErxTask.Dummies.erxTasks.map { GroupedPrescription.Prescription(erxTask: $0) },
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: Array(
                repeating: groupedPrescription,
                count: 6
            )
        )

        return MainView(
            store: MainDomain.Dummies.storeFor(MainDomain.State(prescriptionListState: state,
                                                                debug: DebugDomain.State(trackingOptOut: true)))
        )
    }
}
