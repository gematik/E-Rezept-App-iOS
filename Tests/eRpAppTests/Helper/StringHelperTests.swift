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

@testable import eRpFeatures
import Nimble
import SwiftUI
import XCTest

final class StringHelperTests: XCTestCase {
    func testSuffixFromWithoutIncludingKey() {
        let input = "1234lsdkjfhlasdKEYalles danach"

        let sut = input.suffix(from: "KEY")
        expect(sut) == "alles danach"

        let sut2 = input.starting(after: "KEY")
        expect(sut2) == "alles danach"
    }

    func testSuffixFromIncludingKey() {
        let input = "1234lsdkjfhlasdKEYalles danach"

        let sut = input.suffix(from: "KEY", isKeyIncluded: true)
        expect(sut) == "KEYalles danach"
    }

    func testPrefixUpToWithoutIncludingKey() {
        let input = "alles davor KEYgrütze danach123"

        let sut = input.prefix(upTo: "KEY")
        expect(sut) == "alles davor "

        let sut2 = input.first(upTo: "KEY")
        expect(sut2) == "alles davor "
    }

    func testPrefixUpToIncludingKey() {
        let input = "alles davor KEYgrütze danach123"

        let sut = input.prefix(upTo: "KEY", isKeyIncluded: true)
        expect(sut) == "alles davor KEY"
    }
}
