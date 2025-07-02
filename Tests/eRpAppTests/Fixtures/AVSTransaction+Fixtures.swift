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

import eRpKit
import Foundation

extension AVSTransaction {
    enum Fixtures {
        static let transaction1 = AVSTransaction(
            transactionID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            httpStatusCode: 200,
            groupedRedeemTime: .init(timeIntervalSince1970: 1_615_823_464),
            groupedRedeemID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            telematikID: "123456789",
            taskId: "12345.6789.101112"
        )
    }
}
