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

@testable import eRpApp
import eRpKit
import Foundation

extension ErxChargeItem {
    // swiftlint:disable:next type_body_length
    enum Fixtures {
        static let chargeItem = ErxChargeItem(
            identifier: ErxTask.Fixtures.erxTask1.identifier,
            fhirData: "testData".data(using: .utf8)!,
            enteredDate: "2021-06-29T10:59:37.098245933+00:00",
            medication: ErxTask.Fixtures.erxTask1.medication
        )

        static let chargeItemWithTaskId1 = ErxChargeItem(
            identifier: "task_id_1",
            fhirData: "testData".data(using: .utf8)!
        )
    }
}
