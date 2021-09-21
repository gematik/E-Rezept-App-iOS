//
//  Copyright (c) 2021 gematik GmbH
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

import Foundation
import Nimble
@testable import TrustStore
import XCTest

final class OCSPListTests: XCTestCase {
    func testDecodeValidListJson() throws {
        // given
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }

        // when
        let ocspList = try OCSPList.from(data: data)
        let ocspListBase64 = try OCSPList.Base64.from(data: data)

        // then
        expect(ocspList.responses.count) == 2
        expect(ocspListBase64.responses.count) == 2
        expect(ocspListBase64.responses.first) ==
            "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"
        // swiftlint:disable:previous line_length
    }
}
