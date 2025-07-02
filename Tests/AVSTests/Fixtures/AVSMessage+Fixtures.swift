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

import AVS
import Foundation
import OpenSSL

extension AVSMessage {
    enum Fixtures {
        static let completeExample = AVSMessage(
            version: 2,
            supplyOptionsType: .delivery,
            name: "Dr. Maximilian von Muster",
            address: ["Bundesallee", "312", "12345", "Berlin"],
            hint: "Bitte im Morsecode klingeln: -.-.",
            text: "123456",
            phone: "004916094858168",
            mail: "max@musterfrau.de",
            transactionID: UUID(uuidString: "ee63e415-9a99-4051-ab07-257632faf985")!,
            taskID: "160.123.456.789.123.58",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
    }
}
