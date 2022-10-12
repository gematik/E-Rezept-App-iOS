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
