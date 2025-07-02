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

@testable import eRpKit
import Nimble
import XCTest

extension ScannedErxTask: ErxTaskMatrixCode {}

final class DefaultDataMatrixStringEncoderTests: XCTestCase {
    func testCreatingAJsonStringForOnePrescriptionData() {
        // given
        let data = ScannedErxTask(
            id: "4711",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )

        // when
        let worker = DefaultDataMatrixStringEncoder()
        let stringRepresentation = try? worker.stringEncode(tasks: [data])

        // then
        expect(stringRepresentation) == """
        {"urls":["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
        """
    }

    func testCreatingAJsonStringForThreePrescriptionData() {
        // given
        let data1 = ScannedErxTask(
            id: "4711",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let data2 = ScannedErxTask(
            id: "4712",
            accessCode: "0936cfa582b447144b71ac89eb7bb83a77c67c99d4054f91ee3703acf5d6a629"
        )
        let data3 = ScannedErxTask(
            id: "4713",
            accessCode: "d3e6092ae3af14b5225e2ddbe5a4f59b3939a907d6fdd5ce6a760ca71f45d8e5"
        )

        // when
        let worker = DefaultDataMatrixStringEncoder()
        let stringRepresentation = try? worker.stringEncode(tasks: [data1, data2, data3])

        // then
        // swiftlint:disable line_length
        expect(stringRepresentation) == """
        {"urls":["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea","Task/4712/$accept?ac=0936cfa582b447144b71ac89eb7bb83a77c67c99d4054f91ee3703acf5d6a629","Task/4713/$accept?ac=d3e6092ae3af14b5225e2ddbe5a4f59b3939a907d6fdd5ce6a760ca71f45d8e5"]}
        """
        // swiftlint:enable line_length
    }

    func testCreatingAJsonStringWithNoPrescriptionData() {
        // given

        // when
        let worker = DefaultDataMatrixStringEncoder()
        let stringRepresentation = try? worker.stringEncode(tasks: [])

        // then
        expect(stringRepresentation) == """
        {"urls":[]}
        """
    }

    func testCreatingAJsonStringForInvoiceData() {
        // given
        // swiftlint:disable:next force_unwrapping
        let data = ChargeItem(
            id: "5678",
            accessCode: "91838hdha9c42ceec14aec3ddlasnf021ß15f58fe4"
        )

        // when
        let worker = DefaultDataMatrixStringEncoder()
        let stringRepresentation = try? worker.stringEncode(chargeItem: data)

        // then
        expect(stringRepresentation) == """
        {"urls":["ChargeItem/5678?ac=91838hdha9c42ceec14aec3ddlasnf021ß15f58fe4"]}
        """
    }

    private struct ChargeItem: ErxChargeItemMatrixCode {
        var id: String
        var accessCode: String?
    }
}
