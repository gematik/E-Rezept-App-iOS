//
//  Copyright (c) 2024 gematik GmbH
//
//  Licensed under the Apache License, Version 2.0 (the License);
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an 'AS IS' BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import Dependencies
@testable import eRpFeatures
import Nimble
import SwiftUI
import XCTest

final class DataDetectorTests: XCTestCase {
    @Dependency(\.dataDetector) var sut: DataDetector

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        //
        try await super.tearDown()
    }

    func testPhoneNumberDetection() async throws {
        let string = """
            Please call one of the following contact numbers:
            Ärztl. Bereitschaftsdienst: +49 116 117
            Giftnotruf: +49 30 19 240
            Notapotheken-Auskunft: +49 0800 00 22833
            Zahnärztl. Notfall: +49 30 89 00 43 33
            Sucht & Drogenhotline: +49 180 6 31 30 31*
        """
        let expected = ["+49 116 117",
                        "+49 30 19 240",
                        "+49 0800 00 22833",
                        "+49 30 89 00 43 33",
                        "+49 180 6 31 30 31"]

        XCTAssertEqual(try sut.phoneNumbers(string), expected)
    }

    func testDifferentFormattedPhoneNumbers() async throws {
        let string = """
            1. Some inline text with a 03381 890 29 89 phone numer
            2. No spaces: 03089004332
            3. Undetected: 03019240
            4. Regional: 030 89 00 43 31
            5. International: 0049 30 89 00 43 33
            6. Other formatting: 030 8900 4333
            7. Other formatting: 030/89004333
            8. Other formatting: 030-8900-4333
        """

        let expected = ["03381 890 29 89",
                        "03089004332",
                        "030 89 00 43 31",
                        "0049 30 89 00 43 33",
                        "030 8900 4333",
                        "030/89004333",
                        "030-8900-4333"]

        XCTAssertEqual(try sut.phoneNumbers(string), expected)
    }
}