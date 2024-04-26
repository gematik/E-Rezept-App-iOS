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
import Nimble
import XCTest

@MainActor
final class MedicationReminderParserTests: XCTestCase {
    func testParseDosagePatternABC() async {
        let test1 = MedicationReminderParser.parseFromDosageInstructions("1-0-0")
        XCTAssertEqual(
            test1,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning)]
        )

        let test2 = MedicationReminderParser.parseFromDosageInstructions("1-0-1")
        XCTAssertEqual(
            test2,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .evening)]
        )

        let test3 = MedicationReminderParser.parseFromDosageInstructions("1 - 2- 3")
        XCTAssertEqual(
            test3,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "2", time: .noon),
             MedicationReminderParser.Instruction(amount: "3", time: .evening)]
        )

        let test5 = MedicationReminderParser.parseFromDosageInstructions("1.5-1,5-1½")
        XCTAssertEqual(
            test5,
            [MedicationReminderParser.Instruction(amount: "1.5", time: .morning),
             MedicationReminderParser.Instruction(amount: "1,5", time: .noon),
             MedicationReminderParser.Instruction(amount: "1½", time: .evening)]
        )

        let test6 = MedicationReminderParser.parseFromDosageInstructions("½ - 2 ½ - 3  ½")
        XCTAssertEqual(
            test6,
            [MedicationReminderParser.Instruction(amount: "½", time: .morning),
             MedicationReminderParser.Instruction(amount: "2 ½", time: .noon),
             MedicationReminderParser.Instruction(amount: "3  ½", time: .evening)]
        )

        let test7 = MedicationReminderParser.parseFromDosageInstructions("1--1")
        XCTAssertEqual(
            test7,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .evening)]
        )

        let test8 = MedicationReminderParser.parseFromDosageInstructions("0--1")
        XCTAssertEqual(
            test8,
            [MedicationReminderParser.Instruction(amount: "1", time: .evening)]
        )

        let test9 = MedicationReminderParser.parseFromDosageInstructions("-1-")
        XCTAssertEqual(
            test9,
            [MedicationReminderParser.Instruction(amount: "1", time: .noon)]
        )

        let test10 = MedicationReminderParser.parseFromDosageInstructions("<<1-0-0>>")
        XCTAssertEqual(
            test10,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning)]
        )

        let test11 = MedicationReminderParser.parseFromDosageInstructions(" >> << 1-0-0 <<> > ")
        XCTAssertEqual(
            test11,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning)]
        )
    }

    func testParseDosagePatternABCD() async {
        let test1 = MedicationReminderParser.parseFromDosageInstructions("1-0-0-0")
        XCTAssertEqual(
            test1,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning)]
        )

        let test2 = MedicationReminderParser.parseFromDosageInstructions("1-0-1-0")
        XCTAssertEqual(
            test2,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .evening)]
        )

        let test3 = MedicationReminderParser.parseFromDosageInstructions("0-1-0-1")
        XCTAssertEqual(
            test3,
            [MedicationReminderParser.Instruction(amount: "1", time: .noon),
             MedicationReminderParser.Instruction(amount: "1", time: .night)]
        )

        let test4 = MedicationReminderParser.parseFromDosageInstructions("1 - 2- 3-   4.0")
        XCTAssertEqual(
            test4,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "2", time: .noon),
             MedicationReminderParser.Instruction(amount: "3", time: .evening),
             MedicationReminderParser.Instruction(amount: "4.0", time: .night)]
        )

        let test5 = MedicationReminderParser.parseFromDosageInstructions("1.5  -  1,5  -  2 ½  -  ½")
        XCTAssertEqual(
            test5,
            [MedicationReminderParser.Instruction(amount: "1.5", time: .morning),
             MedicationReminderParser.Instruction(amount: "1,5", time: .noon),
             MedicationReminderParser.Instruction(amount: "2 ½", time: .evening),
             MedicationReminderParser.Instruction(amount: "½", time: .night)]
        )

        let test6 = MedicationReminderParser.parseFromDosageInstructions("1---1")
        XCTAssertEqual(
            test6,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .night)]
        )

        let test7 = MedicationReminderParser.parseFromDosageInstructions("1--0-1")
        XCTAssertEqual(
            test7,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .night)]
        )

        let test8 = MedicationReminderParser.parseFromDosageInstructions("-2--0")
        XCTAssertEqual(
            test8,
            [MedicationReminderParser.Instruction(amount: "2", time: .noon)]
        )

        let test9 = MedicationReminderParser.parseFromDosageInstructions("<<1-0-0-1>>")
        XCTAssertEqual(
            test9,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .night)]
        )

        let test10 = MedicationReminderParser.parseFromDosageInstructions("> <<> 1-0-0-1 >> <")
        XCTAssertEqual(
            test10,
            [MedicationReminderParser.Instruction(amount: "1", time: .morning),
             MedicationReminderParser.Instruction(amount: "1", time: .night)]
        )
    }

    func testParseDosageFailure() async {
        let test1 = MedicationReminderParser.parseFromDosageInstructions("E-0-0")
        expect(test1) == []

        let test2 = MedicationReminderParser.parseFromDosageInstructions("1-0-x-0")
        expect(test2) == []

        let test3 = MedicationReminderParser.parseFromDosageInstructions("O-O-O")
        expect(test3) == []

        let test4 = MedicationReminderParser.parseFromDosageInstructions("2 mal Mörgens")
        expect(test4) == []

        let test5 = MedicationReminderParser.parseFromDosageInstructions("1 x Mitags")
        expect(test5) == []

        let test6 = MedicationReminderParser.parseFromDosageInstructions("4 x Abens")
        expect(test6) == []
    }
}
