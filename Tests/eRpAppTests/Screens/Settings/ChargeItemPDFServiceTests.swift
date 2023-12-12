//
//  Copyright (c) 2023 gematik GmbH
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

import Combine
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import GemPDFKit
import Nimble
import XCTest

import BundleKit
import CustomDump
import ModelsR4
import TestUtils

final class ChargeItemPDFServiceTests: XCTestCase {
    func testGeneratePDF() throws {
        guard let outputURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("output")
        .appendingPathExtension("pdf") else {
            fatalError("Destination URL not created")
        }
        guard let outputURL2 = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("output2")
        .appendingPathExtension("pdf") else {
            fatalError("Destination URL not created")
        }

        let sut = DefaultChargeItemPDFService()

        let result = try sut.generatePDF(for: ErxChargeItem.Fixtures.chargeItemWithFHIRData)
        try result.write(to: outputURL)

        print(outputURL)

        guard let resultString = String(data: result, encoding: .ascii) else {
            fatalError("invalid result string")
        }

        let document = try PDFDocument.PDFDocumentParserPrinter().parse(resultString)

        let attachmentData = ErxChargeItem.Fixtures.chargeItemWithFHIRData.receiptSignature?.data?
            .data(using: .utf8) ?? Data()
        let attachment = PDFAttachment(filename: "Data", content: attachmentData)

        let printedAttachment = try document.append(attachment: attachment, startObj: result.count)

        var actualResult = result
        actualResult.append(printedAttachment)
        try actualResult.write(to: outputURL2)
    }

    func testMultiplePDFs() throws {
        let files: [(String, String)] = [
            ("./Freitext-Verordnung.json", "200.334.138.469.717.92"),
            ("./PZN-Verordnung_Nr_1.json", "200.424.187.927.272.20"),
            ("./PZN-Verordnung_Nr_2.json", "200.457.180.497.994.96"),
            ("./PZN-Verordnung_Nr_3.json", "200.279.187.481.423.80"),
            ("./PZN-Verordnung_Nr_5.json", "200.625.688.123.368.48"),
            ("./PZN-Verordnung_Nr_6.json", "200.280.604.133.110.12"),
            // ("./PZN-Verordnung_Nr_7.json", null),
            ("./PZN-Verordnung_Nr_8.json", "200.108.757.032.088.60"),
            ("./PZN_Mehrfachverordnung_PZN_MV_1.json", "200.918.824.824.539.12"),
            ("./PZN_Mehrfachverordnung_PZN_MV_2.json", "200.497.827.696.678.76"),
            ("./PZN_Mehrfachverordnung_PZN_MV_3.json", "200.529.639.126.950.56"),
            ("./PZN_Mehrfachverordnung_PZN_MV_4.json", "200.020.918.309.115.84"),
            ("./Rezeptur-parenterale_Zytostatika_Rezeptur-parenterale_Zytostatika_1.json", "209.100.612.180.208.16"),
            ("./Rezeptur-Verordnung_Nr_1.json", "200.858.310.624.061.76"),
            ("./Rezeptur-Verordnung_Nr_2.json", "200.800.419.351.304.52"),
            // ("./Wirkstoff-Verordnung.json", null)
        ]

        for (file, identifier) in files {
            guard let chargeItem = try chargeItemFromFile(file, identifier: identifier) else {
                XCTFail("\(file) not parseable")
                continue
            }

            guard let outputURL = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            .appendingPathComponent(file)
            .appendingPathExtension("pdf") else {
                fatalError("Destination URL not created")
            }
            print("File: \(outputURL.absoluteString)")

            let sut = DefaultChargeItemPDFService()

            let result = try sut.generatePDF(for: chargeItem)
            try result.write(to: outputURL)
        }
    }

    func testFreitextVerordnung() throws {
        guard let chargeItem = try chargeItemFromFile("Freitext-Verordnung.json", identifier: "200.334.138.469.717.92")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paolo Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464237",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Ernst Alder",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987789324"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "07.07.2023"
            ),
            dispense: .init(
                taskId: "200.334.138.469.717.92",
                medication: "Freitextverordnung: 1x Yellox 0,9 mg/ml Augentropfen",
                articles: [
                    .init(
                        name: "Einzelimport",
                        pzn: "09999117",
                        count: "1",
                        price: "27,58"
                    ),
                ],
                production: nil,
                fees: [
                    .init(name: "Beschaffungskosten", pzn: "", count: "", price: "8,57"),
                ],
                sum: "36,15",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN1() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_1.json", identifier: "200.424.187.927.272.20")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.424.187.927.272.20",
                medication: "1x Beloc-Zok® mite 47,5 mg, 30 Retardtabletten N1/ 30 Stück N1 PZN: 03879429",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "03879429",
                        count: "1",
                        price: "21,04"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "21,04",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN2() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_2.json", identifier: "200.457.180.497.994.96")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paulus Privatus",
                address: "Nauheimer Str. 188, 50969 Köln",
                insuranceId: "P123464315",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: nil,
                name: "Emilia Becker",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("582369858"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.457.180.497.994.96",
                medication: "1x Venlafaxin - 1 A Pharma® 75mg 100 Tabl. N3/ N3 PZN: 05392039",
                articles: [
                    .init(
                        name: "VENLAFAXIN Heumann 75 mg Tabletten 100 St",
                        pzn: "09494280",
                        count: "1",
                        price: "31,40"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "31,40",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN3() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_3.json", identifier: "200.279.187.481.423.80")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Teddy Privati",
                address: "Sesamstraße 1, 93047 Regensburg",
                insuranceId: "P123464532",
                dateOfBirth: "30.07.2022"
            ),
            doctor: .init(
                title: "Dr.",
                name: "Dr. Maximilian Weber",
                address: "Yorckstraße 15\n93049 Regensburg",
                code: .lanr("456456534"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.279.187.481.423.80",
                medication: "1x INFECTOCORTIKRUPP® Zäpfchen 100 mg 3 Supp. N1/ N1 PZN: 03386388",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "03386388",
                        count: "1",
                        price: "21,82"
                    ),
                ],
                production: nil,
                fees: [
                    .init(
                        name: "Notdienstgebühr",
                        pzn: "",
                        count: "",
                        price: "2,50"
                    ),
                ],
                sum: "24,32",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN5() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_5.json", identifier: "200.625.688.123.368.48")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Alexander Fischer",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("895268385"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.625.688.123.368.48",
                medication: "2x Viani 50µg/250µg 1 Diskus 60 ED N1/ 1 Diskus N1 PZN: 00427833",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "00427833",
                        count: "2",
                        price: "82,68"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "82,68",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN6() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_6.json", identifier: "200.280.604.133.110.12")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paolo Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464237",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.280.604.133.110.12",
                medication: "1x Bisoprolol plus 10/25 - 1A Pharma® 100 Filmtbl. N3/ 100 Stück N3 PZN: 01624240",
                articles: [
                    .init(
                        name: "CONCOR 10 PLUS Filmtabletten 100 St",
                        pzn: "02091840",
                        count: "1",
                        price: "42,77"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "42,77",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN8() throws {
        guard let chargeItem = try chargeItemFromFile("PZN-Verordnung_Nr_8.json", identifier: "200.108.757.032.088.60")
        else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.108.757.032.088.60",
                medication: "1x Efluelda Injek.susp. 2022/2023 1 FER o. Kanüle N1/ N1 PZN: 17543779",
                articles: [
                    .init(
                        name: "Auseinzelung",
                        pzn: "02567053",
                        count: "1",
                        price: "50,97"
                    ),
                    .init(
                        name: "",
                        pzn: "17543785",
                        count: "0,1",
                        price: ""
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "50,97",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testMVO1() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN_Mehrfachverordnung_PZN_MV_1.json",
            identifier: "200.918.824.824.539.12"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.918.824.824.539.12 gültig ab 03.07.2023 bis 30.09.2023 1 von 4 Verordnungen",
                medication: "1x L-Thyroxin Henning 75 100 Tbl. N3/ N3 PZN: 02532741",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "02532741",
                        count: "1",
                        price: "15,40"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "15,40",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testMVO2() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN_Mehrfachverordnung_PZN_MV_2.json",
            identifier: "200.497.827.696.678.76"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "11.09.2023"
            ),
            dispense: .init(
                taskId: "200.497.827.696.678.76 gültig ab 11.09.2023 bis 31.12.2023 2 von 4 Verordnungen",
                medication: "1x L-Thyroxin Henning 75 100 Tbl. N3/ N3 PZN: 02532741",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "02532741",
                        count: "1",
                        price: "15,40"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "15,40",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testMVO3() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN_Mehrfachverordnung_PZN_MV_3.json",
            identifier: "200.529.639.126.950.56"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "11.12.2023"
            ),
            dispense: .init(
                taskId: "200.529.639.126.950.56 gültig ab 11.12.2023 bis 31.03.2024 3 von 4 Verordnungen",
                medication: "1x L-Thyroxin Henning 75 100 Tbl. N3/ N3 PZN: 02532741",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "02532741",
                        count: "1",
                        price: "15,40"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "15,40",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testMVO4() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN_Mehrfachverordnung_PZN_MV_4.json",
            identifier: "200.020.918.309.115.84"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "04.03.2024"
            ),
            dispense: .init(
                taskId: "200.020.918.309.115.84 gültig ab 04.03.2024 bis 30.06.2024 4 von 4 Verordnungen",
                medication: "1x L-Thyroxin Henning 75 100 Tbl. N3/ N3 PZN: 02532741",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "02532741",
                        count: "1",
                        price: "15,40"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "15,40",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testZytostatika1() throws {
        guard let chargeItem = try chargeItemFromFile(
            "Rezeptur-parenterale_Zytostatika_Rezeptur-parenterale_Zytostatika_1.json",
            identifier: "209.100.612.180.208.16"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paulus Privatus",
                address: "Nauheimer Str. 188, 50969 Köln",
                insuranceId: "P123464315",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "06.07.2023"
            ),
            dispense: .init(
                taskId: "209.100.612.180.208.16",
                medication: "3x 500 ml Infusionslösung / Etoposid 180 mg / NaCl 0,9 % 500 ml",
                articles: [
                    .init(
                        name: "Parenterale Zubereitung",
                        pzn: "09999092",
                        count: "1",
                        price: "389,17"
                    ),
                ],
                production: "Bestandteile (Nettopreise):\nHerstellung 1 – 04.07.2023 14:00 Uhr: 1 01131365 11 0,36 17,33€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€\nHerstellung 2 – 05.07.2023 11:00 Uhr: 1 01131365 11 0,36 17,33€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€\nHerstellung 3 – 06.07.2023 12:00 Uhr: 1 01131365 11 0,36 17,33€ / 01131365 99 0,36 0,96€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€",
                // swiftlint:disable:previous line_length
                fees: [
                ],
                sum: "389,17",
                currency: "EUR"
            )
        )

        expect(content).to(nodiff(expected))
    }

    func testRezeptur1() throws {
        guard let chargeItem = try chargeItemFromFile(
            "Rezeptur-Verordnung_Nr_1.json",
            identifier: "200.858.310.624.061.76"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paula Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464113",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Hanna Schmidt",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("123412821"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.858.310.624.061.76",
                medication: "1x 100 g Creme / Triamcinolonacetonid 0.1% / Basiscreme DAC Ad 100,0 g",
                articles: [
                    .init(
                        name: "Rezeptur",
                        pzn: "09999011",
                        count: "1",
                        price: "31,70"
                    ),
                ],
                production: "Bestandteile: 03110083 0,4328 5,84€ / 01096858 0,39956 5,50€ / 00538343 1 0,95€ / 06460518 1 6,00€ / 06460518 1 8,35€ (Nettopreise)",
                // swiftlint:disable:previous line_length
                fees: [
                ],
                sum: "31,70",
                currency: "EUR"
            )
        )

        expect(content).to(nodiff(expected))
    }

    func testRezeptur2() throws {
        guard let chargeItem = try chargeItemFromFile(
            "Rezeptur-Verordnung_Nr_2.json",
            identifier: "200.800.419.351.304.52"
        ) else {
            fatalError("File not parseable")
        }

        let sut = DefaultChargeItemPDFService()

        let content = try sut.content(for: chargeItem)

        let expected = ChargeItemHTMLTemplate.Content(
            patient: .init(
                title: nil,
                name: "Paolo Privati",
                address: "Blumenweg 18, 26427 Esens",
                insuranceId: "P123464237",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Hanna Schmidt",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("123412821"),
                prescribedOn: "03.07.2023"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.07.2023"
            ),
            dispense: .init(
                taskId: "200.800.419.351.304.52",
                medication: "1x 100 ml Lösung / Salicylsäure 5 g / 2-propanol 70 % Ad 100 g",
                articles: [
                    .init(
                        name: "Rezeptur",
                        pzn: "09999011",
                        count: "1",
                        price: "18,45"
                    ),
                ],
                production: "Bestandteile: NA 0,42€ / NA 0,64€ / NA 0,05€ / NA 1,46€ / NA 0,91€ / NA 0,17€ / NA 3,50€ / NA 8,35€ (Nettopreise)",
                // swiftlint:disable:previous line_length
                fees: [
                ],
                sum: "18,45",
                currency: "EUR"
            )
        )

        expect(content).to(nodiff(expected))
    }

    private func chargeItemFromFile(_ file: String, identifier: String) throws -> ErxChargeItem? {
        try decode(resource: file)
            .parseErxChargeItem(
                id: identifier,
                with: "fhirData".data(using: .utf8)!
            )
    }

    private func decode(
        resource file: String
    ) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .decode(ModelsR4.Bundle.self, from: file)
    }
}

extension ErxChargeItem.Fixtures {
    // non realistic chargeItem as low detail
    static let lowDetailChargeItem: ErxChargeItem = .init(
        identifier: "chargeItem_id_12",
        fhirData: "Some placeholder data".data(using: .utf8)!,
        enteredDate: "2023-03-10T10:30:04+02:00",
        medication: ErxTask.Fixtures.compoundingMedication,
        medicationRequest: .init(
            authoredOn: "2023-02-02T14:07:46.964+00:00",
            dosageInstructions: "1-0-0-0",
            substitutionAllowed: true,
            hasEmergencyServiceFee: false,
            bvg: false,
            coPaymentStatus: .subjectToCharge,
            multiplePrescription: .init(mark: false)
        ),
        patient: .init(
            name: "Günther Angermänn",
            address: "Weiherstr. 74a\n67411 Büttnerdorf",
            birthDate: "1976-04-30",
            status: "1",
            insurance: "Künstler-Krankenkasse Baden-Württemberg",
            insuranceId: "X110465770"
        ),
        practitioner: ErxPractitioner(
            lanr: "443236256",
            name: "Dr. Dr. Schraßer",
            qualification: "Super-Facharzt für alles Mögliche",
            address: "Halligstr. 98 85005 Alt Mateo"
        ),
        organization: ErxOrganization(
            identifier: "734374849",
            name: "Arztpraxis Schraßer",
            phone: "(05808) 9632619",
            email: "andre.teufel@xn--schffer-7wa.name",
            address: "Halligstr. 98\n85005, Alt Mateo"
        ),
        pharmacy: .init(
            identifier: "012876",
            name: "Pharmacy Name",
            address: "Pharmacy Street 2\n13267, Berlin",
            country: "DE"
        ),
        invoice: .init(
            totalAdditionalFee: 5.0,
            totalGross: 345.34,
            currency: "EUR",
            chargeableItems: [
                DavInvoice.ChargeableItem(
                    factor: 2.0,
                    price: 5.12,
                    pzn: "pzn_123",
                    ta1: "ta1_456",
                    hmrn: "hmrn_789"
                ),
            ]
        ),
        medicationDispense: .init(
            identifier: "e00e96a2-6dae-4036-8e72-42b5c21fdbf3",
            whenHandedOver: "2023-02-17",
            taskId: ""
        ),
        prescriptionSignature: .init(
            when: "2023-02-17T14:07:47.806+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "vDAo+tog=="
        ),
        receiptSignature: .init(
            when: "2023-02-17T14:07:47.808+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "Mb3ej1h4E="
        ),
        dispenseSignature: .init(
            when: "2023-02-17T14:07:47.809+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "aOEsSfDw=="
        )
    )

    static let chargeItem1: ErxChargeItem = .init(
        identifier: "charge_id_1",
        fhirData: "fhirData1".data(using: .utf8)!,
        enteredDate: "2023-02-19T14:07:47.809+00:00",
        accessCode: "0986JSJSN1834JSFNNS1934"
    )

    static let chargeItem2: ErxChargeItem = .init(
        identifier: "charge_id_2",
        fhirData: "fhirData2".data(using: .utf8)!,
        enteredDate: "2023-02-23T14:07:47.809+00:00"
    )

    static let chargeItem3: ErxChargeItem = .init(
        identifier: "charge_id_3",
        fhirData: "fhirData3".data(using: .utf8)!,
        enteredDate: "2023-02-17T14:07:47.809+00:00"
    )

    static let chargeItemWithFHIRData: ErxChargeItem = .init(
        identifier: "chargeItem_id_12",
        fhirData: chargeItemAsFHIRData,
        enteredDate: "2023-02-17T14:07:46.964+00:00",
        accessCode: "0986JSJSN1834JSFNNS1934",
        medication: ErxMedication(
            name: "Schmerzmittel",
            profile: ErxMedication.ProfileType.pzn,
            drugCategory: .avm,
            pzn: "17091124",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(
                    value: "1",
                    unit: "Stk"
                ),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            dosageForm: "TAB",
            normSizeCode: "NB"
        ),
        medicationRequest: .init(
            authoredOn: "2023-02-02T14:07:46.964+00:00",
            dosageInstructions: "1-0-0-0",
            substitutionAllowed: true,
            hasEmergencyServiceFee: false,
            bvg: false,
            coPaymentStatus: .subjectToCharge,
            multiplePrescription: .init(mark: false)
        ),
        patient: .init(
            name: "Günther Angermänn",
            address: "Weiherstr. 74a\n67411 Büttnerdorf",
            birthDate: "1976-04-30",
            status: "1",
            insurance: "Künstler-Krankenkasse Baden-Württemberg",
            insuranceId: "X110465770"
        ),
        practitioner: ErxPractitioner(
            lanr: "443236256",
            name: "Dr. Dr. Schraßer",
            qualification: "Super-Facharzt für alles Mögliche",
            address: "Halligstr. 98 85005 Alt Mateo"
        ),
        organization: ErxOrganization(
            identifier: "734374849",
            name: "Arztpraxis Schraßer",
            phone: "(05808) 9632619",
            email: "andre.teufel@xn--schffer-7wa.name",
            address: "Halligstr. 98\n85005, Alt Mateo"
        ),
        pharmacy: .init(
            identifier: "012876",
            name: "Pharmacy Name",
            address: "Pharmacy Street 2\n13267, Berlin",
            country: "DE"
        ),
        invoice: .init(
            totalAdditionalFee: 5.0,
            totalGross: 345.34,
            currency: "EUR",
            chargeableItems: [
                DavInvoice.ChargeableItem(
                    factor: 2.0,
                    price: 5.12,
                    pzn: "pzn_123",
                    ta1: "ta1_456",
                    hmrn: "hmrn_789"
                ),
            ]
        ),
        medicationDispense: .init(
            identifier: "e00e96a2-6dae-4036-8e72-42b5c21fdbf3",
            whenHandedOver: "2023-02-17",
            taskId: "123.4567.890"
        ),
        prescriptionSignature: .init(
            when: "2023-02-17T14:07:47.806+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "vDAo+tog=="
        ),
        receiptSignature: .init(
            when: "2023-02-17T14:07:47.808+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "Mb3ej1h4E="
        ),
        dispenseSignature: .init(
            when: "2023-02-17T14:07:47.809+00:00",
            sigFormat: "application/pkcs7-mime",
            data: "aOEsSfDw=="
        )
    )

    static let chargeItemAsFHIRData: Data = // swiftlint:disable:next line_length
        "{\"resourceType\":\"Bundle\",\"id\":\"658d213d-523b-4a24-bbdb-f237611ead2d\",\"type\":\"collection\",\"timestamp\":\"2023-02-17T14:07:47.710+00:00\",\"entry\":[{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/ChargeItem/chargeItem_id_12\",\"resource\":{\"resourceType\":\"ChargeItem\",\"id\":\"chargeItem_id_12\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erpchrg/StructureDefinition/GEM_ERPCHRG_PR_ChargeItem|1.0\"]},\"identifier\":[{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode\",\"value\":\"feaf93c400be820a1981250a29d529e3de9a5a3054049d58f133ea13e00d36b0\"}],\"status\":\"billable\",\"code\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/data-absent-reason\",\"code\":\"not-applicable\"}]},\"subject\":{\"identifier\":{\"system\":\"http://fhir.de/sid/pkv/kvid-10\",\"value\":\"A123456789\"}},\"enterer\":{\"identifier\":{\"system\":\"https://gematik.de/fhir/sid/telematik-id\",\"value\":\"3-SMC-B-Testkarte-883110000116873\"}},\"enteredDate\":\"2023-02-17T14:07:46.964+00:00\",\"supportingInformation\":[{\"reference\":\"Bundle/775157da-afc8-4248-b90b-a32163895323\",\"display\":\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle\"},{\"reference\":\"Bundle/a2442313-18da-4051-b355-42a47d9f823a\",\"display\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle\"},{\"reference\":\"Bundle/c8d36312-0000-0000-0003-000000000000\",\"display\":\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle\"}]}},{\"fullUrl\":\"urn:uuid:a2442313-18da-4051-b355-42a47d9f823a\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"a2442313-18da-4051-b355-42a47d9f823a\",\"meta\":{\"lastUpdated\":\"2023-02-17T15:07:45.077+01:00\",\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle|1.1\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T15:07:45.077+01:00\",\"entry\":[{\"fullUrl\":\"urn:uuid:f67f6885-c527-4198-a44a-d5bef2fda5b9\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"f67f6885-c527-4198-a44a-d5bef2fda5b9\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenComposition|1.1\"]},\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-CompositionTypes\",\"code\":\"ERezeptAbgabedaten\"}]},\"date\":\"2023-02-17T15:07:45+01:00\",\"author\":[{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}],\"title\":\"ERezeptAbgabedaten\",\"section\":[{\"title\":\"Apotheke\",\"entry\":[{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}]},{\"title\":\"Abgabeinformationen\",\"entry\":[{\"reference\":\"urn:uuid:e00e96a2-6dae-4036-8e72-42b5c21fdbf3\"}]}]}},{\"fullUrl\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\",\"resource\":{\"resourceType\":\"Organization\",\"id\":\"623e785c-0f6d-4db9-8488-9809b8493537\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Apotheke|1.1\"]},\"identifier\":[{\"system\":\"http://fhir.de/sid/arge-ik/iknr\",\"value\":\"012876\"}],\"name\":\"Pharmacy Name\",\"address\":[{\"type\":\"physical\",\"line\":[\"Pharmacy Street 2\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"2\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Pharmacy Street\"}]}],\"city\":\"Berlin\",\"postalCode\":\"13267\",\"country\":\"DE\"}]}},{\"fullUrl\":\"urn:uuid:39618663-4b23-43de-ab1d-db25b2d85130\",\"resource\":{\"resourceType\":\"Invoice\",\"id\":\"39618663-4b23-43de-ab1d-db25b2d85130\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Abrechnungszeilen|1.1\"]},\"status\":\"issued\",\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-InvoiceTyp\",\"code\":\"Abrechnungszeilen\"}]},\"lineItem\":[{\"sequence\":1,\"chargeItemCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/ifa/pzn\",\"code\":\"pzn_123\"},{\"system\":\"http://TA1.abda.de\",\"code\":\"ta1_456\"},{\"system\":\"http://fhir.de/sid/gkv/hmnr\",\"code\":\"hmrn_789\"}]},\"priceComponent\":[{\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-KostenVersicherter\",\"extension\":[{\"url\":\"Kategorie\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-PKV-CS-ERP-KostenVersicherterKategorie\",\"code\":\"0\"}]}},{\"url\":\"Kostenbetrag\",\"valueMoney\":{\"value\":5.12,\"currency\":\"EUR\"}}]},{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-MwStSatz\",\"valueDecimal\":5}],\"type\":\"informational\",\"factor\":2,\"amount\":{\"value\":5.12,\"currency\":\"EUR\"}}]}],\"totalGross\":{\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Gesamtzuzahlung\",\"valueMoney\":{\"value\":5,\"currency\":\"EUR\"}}],\"value\":345.34,\"currency\":\"EUR\"}}},{\"fullUrl\":\"urn:uuid:e00e96a2-6dae-4036-8e72-42b5c21fdbf3\",\"resource\":{\"resourceType\":\"MedicationDispense\",\"id\":\"e00e96a2-6dae-4036-8e72-42b5c21fdbf3\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Abgabeinformationen|1.1\"]},\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-EX-ERP-AbrechnungsTyp\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-PKV-CS-ERP-AbrechnungsTyp\",\"code\":\"1\"}]}},{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Abrechnungszeilen\",\"valueReference\":{\"reference\":\"urn:uuid:39618663-4b23-43de-ab1d-db25b2d85130\"}}],\"status\":\"completed\",\"medicationCodeableConcept\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/data-absent-reason\",\"code\":\"not-applicable\"}]},\"performer\":[{\"actor\":{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}}],\"authorizingPrescription\":[{\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"}}],\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-MedicationDispenseTyp\",\"code\":\"Abgabeinformationen\"}]},\"whenHandedOver\":\"2023-02-17\"}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.809+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"aOEsSfDw==\"}}},{\"fullUrl\":\"urn:uuid:775157da-afc8-4248-b90b-a32163895323\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"775157da-afc8-4248-b90b-a32163895323\",\"meta\":{\"lastUpdated\":\"2023-02-17T15:07:40.162+01:00\",\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle|1.1.0\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T15:07:40.162+01:00\",\"entry\":[{\"fullUrl\":\"https://pvs.gematik.de/fhir/Composition/25ecd923-1d58-4e74-a0b8-dde43bb06b5e\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"25ecd923-1d58-4e74-a0b8-dde43bb06b5e\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Composition|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_PKV_Tariff\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_PKV_TARIFF\",\"code\":\"03\"}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_Legal_basis\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_STATUSKENNZEICHEN\",\"code\":\"00\"}}],\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_FORMULAR_ART\",\"code\":\"e16A\"}]},\"subject\":{\"reference\":\"Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\"},\"date\":\"2023-02-17T15:07:40+01:00\",\"author\":[{\"reference\":\"Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"type\":\"Practitioner\"},{\"type\":\"Device\",\"identifier\":{\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_FOR_Pruefnummer\",\"value\":\"GEMATIK/410/2109/36/123\"}}],\"title\":\"elektronische Arzneimittelverordnung\",\"custodian\":{\"reference\":\"Organization/4e118502-4ed8-45f5-9c79-9a64eaab88f6\"},\"section\":[{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Section_Type\",\"code\":\"Coverage\"}]},\"entry\":[{\"reference\":\"Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\"}]},{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Section_Type\",\"code\":\"Prescription\"}]},\"entry\":[{\"reference\":\"MedicationRequest/28744ee3-ff3a-4793-9036-c11d6b4b105f\"}]}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/MedicationRequest/28744ee3-ff3a-4793-9036-c11d6b4b105f\",\"resource\":{\"resourceType\":\"MedicationRequest\",\"id\":\"28744ee3-ff3a-4793-9036-c11d6b4b105f\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Prescription|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_BVG\",\"valueBoolean\":false},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee\",\"valueBoolean\":false},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Multiple_Prescription\",\"extension\":[{\"url\":\"Kennzeichen\",\"valueBoolean\":false}]},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_StatusCoPayment\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_StatusCoPayment\",\"code\":\"0\"}}],\"status\":\"active\",\"intent\":\"order\",\"medicationReference\":{\"reference\":\"Medication/368dadee-d6d9-425b-afbd-93ccbf109ad8\"},\"subject\":{\"reference\":\"Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\"},\"authoredOn\":\"2023-02-17\",\"requester\":{\"reference\":\"Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\"},\"insurance\":[{\"reference\":\"Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\"}],\"dosageInstruction\":[{\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag\",\"valueBoolean\":true}],\"text\":\"1-0-0-0\"}],\"dispenseRequest\":{\"quantity\":{\"value\":1,\"system\":\"http://unitsofmeasure.org\",\"code\":\"{Package}\"}},\"substitution\":{\"allowedBoolean\":true}}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Medication/368dadee-d6d9-425b-afbd-93ccbf109ad8\",\"resource\":{\"resourceType\":\"Medication\",\"id\":\"368dadee-d6d9-425b-afbd-93ccbf109ad8\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_PZN|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_Base_Medication_Type\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://snomed.info/sct\",\"version\":\"http://snomed.info/sct/900000000000207008/version/20220331\",\"code\":\"763158003\",\"display\":\"Medicinal product (product)\"}]}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Category\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Medication_Category\",\"code\":\"00\"}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Vaccine\",\"valueBoolean\":false},{\"url\":\"http://fhir.de/StructureDefinition/normgroesse\",\"valueCode\":\"NB\"}],\"code\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/ifa/pzn\",\"code\":\"17091124\"}],\"text\":\"Schmerzmittel\"},\"form\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM\",\"code\":\"TAB\"}]},\"amount\":{\"numerator\":{\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_PackagingSize\",\"valueString\":\"1\"}],\"unit\":\"Stk\"},\"denominator\":{\"value\":1}}}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\",\"resource\":{\"resourceType\":\"Patient\",\"id\":\"0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Patient|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/identifier-type-de-basis\",\"code\":\"PKV\"}]},\"system\":\"http://fhir.de/sid/pkv/kvid-10\",\"value\":\"X110465770\"}],\"name\":[{\"use\":\"official\",\"family\":\"Angermänn\",\"_family\":{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/humanname-own-name\",\"valueString\":\"Angermänn\"}]},\"given\":[\"Günther\"]}],\"birthDate\":\"1976-04-30\",\"address\":[{\"type\":\"both\",\"line\":[\"Weiherstr. 74a\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"74a\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Weiherstr.\"}]}],\"city\":\"Büttnerdorf\",\"postalCode\":\"67411\",\"country\":\"D\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Organization/4e118502-4ed8-45f5-9c79-9a64eaab88f6\",\"resource\":{\"resourceType\":\"Organization\",\"id\":\"4e118502-4ed8-45f5-9c79-9a64eaab88f6\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Organization|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/v2-0203\",\"code\":\"BSNR\"}]},\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR\",\"value\":\"734374849\"}],\"name\":\"Arztpraxis Schraßer\",\"telecom\":[{\"system\":\"phone\",\"value\":\"(05808) 9632619\"},{\"system\":\"email\",\"value\":\"andre.teufel@xn--schffer-7wa.name\"}],\"address\":[{\"type\":\"both\",\"line\":[\"Halligstr. 98\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"98\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Halligstr.\"}]}],\"city\":\"Alt Mateo\",\"postalCode\":\"85005\",\"country\":\"D\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\",\"resource\":{\"resourceType\":\"Coverage\",\"id\":\"06f31815-aea8-490a-8c0b-b3123b1600cf\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Coverage|1.1.0\"]},\"extension\":[{\"url\":\"http://fhir.de/StructureDefinition/gkv/besondere-personengruppe\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_PERSONENGRUPPE\",\"code\":\"00\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/dmp-kennzeichen\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DMP\",\"code\":\"00\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/wop\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_ITA_WOP\",\"code\":\"71\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/versichertenart\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_VERSICHERTENSTATUS\",\"code\":\"1\"}}],\"status\":\"active\",\"type\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/versicherungsart-de-basis\",\"code\":\"PKV\"}]},\"beneficiary\":{\"reference\":\"Patient/53d4475b-bff0-470a-89a4-1811c832ee06\"},\"payor\":[{\"identifier\":{\"system\":\"http://fhir.de/sid/arge-ik/iknr\",\"value\":\"100843242\"},\"display\":\"Künstler-Krankenkasse Baden-Württemberg\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"resource\":{\"resourceType\":\"Practitioner\",\"id\":\"d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Practitioner|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/v2-0203\",\"code\":\"LANR\"}]},\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR\",\"value\":\"443236256\"}],\"name\":[{\"use\":\"official\",\"family\":\"Schraßer\",\"_family\":{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/humanname-own-name\",\"valueString\":\"Schraßer\"}]},\"given\":[\"Dr.\"],\"prefix\":[\"Dr.\"],\"_prefix\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier\",\"valueCode\":\"AC\"}]}]}],\"qualification\":[{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_Qualification_Type\",\"code\":\"00\"}]}},{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_Berufsbezeichnung\",\"code\":\"Berufsbezeichnung\"}],\"text\":\"Super-Facharzt für alles Mögliche\"}}]}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.806+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"vDAo+tog==\"}}},{\"fullUrl\":\"urn:uuid:c8d36312-0000-0000-0003-000000000000\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"c8d36312-0000-0000-0003-000000000000\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle|1.2\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T14:07:43.665+00:00\",\"link\":[{\"relation\":\"self\",\"url\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Task/chargeItem_id_12/$close/\"}],\"entry\":[{\"fullUrl\":\"urn:uuid:0cf976ed-8a4c-4078-bc3b-e935f06b4362\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"0cf976ed-8a4c-4078-bc3b-e935f06b4362\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Composition|1.2\"]},\"extension\":[{\"url\":\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_Beneficiary\",\"valueIdentifier\":{\"system\":\"https://gematik.de/fhir/sid/telematik-id\",\"value\":\"3-SMC-B-Testkarte-883110000116873\"}}],\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType\",\"code\":\"3\",\"display\":\"Receipt\"}]},\"date\":\"2023-02-17T14:07:43.664+00:00\",\"author\":[{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"}],\"title\":\"Quittung\",\"event\":[{\"period\":{\"start\":\"2023-02-17T14:07:42.401+00:00\",\"end\":\"2023-02-17T14:07:43.664+00:00\"}}],\"section\":[{\"entry\":[{\"reference\":\"Binary/PrescriptionDigest-chargeItem_id_12\"}]}]}},{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\",\"resource\":{\"resourceType\":\"Device\",\"id\":\"1\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Device|1.2\"]},\"status\":\"active\",\"serialNumber\":\"1.9.0\",\"deviceName\":[{\"name\":\"E-Rezept Fachdienst\",\"type\":\"user-friendly-name\"}],\"version\":[{\"value\":\"1.9.0\"}],\"contact\":[{\"system\":\"email\",\"value\":\"betrieb@gematik.de\"}]}},{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Binary/PrescriptionDigest-chargeItem_id_12\",\"resource\":{\"resourceType\":\"Binary\",\"id\":\"PrescriptionDigest-chargeItem_id_12\",\"meta\":{\"versionId\":\"1\",\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Digest|1.2\"]},\"contentType\":\"application/octet-stream\",\"data\":\"ZQsm4k/OW69rLio6As1LfoTGrAEnvqNUzKBKbQRJbb4=\"}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.808+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"Mb3ej1h4E=\"}}}]}"
        .data(using: .utf8)!
}
