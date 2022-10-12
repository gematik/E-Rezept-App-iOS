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

@testable import AVS
import Combine
import DataKit
@testable import eRpApp
import Foundation
import HTTPClient
import Nimble
import OpenSSL
import TestUtils
import XCTest

final class AVSIntegrationTests: XCTestCase {}

struct AVSIntegrationTestConfiguration {
    let url: String
    let additionalHeaders: [String: String]
}

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
