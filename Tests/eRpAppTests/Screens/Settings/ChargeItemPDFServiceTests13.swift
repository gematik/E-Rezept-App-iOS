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

import Combine
import ComposableArchitecture
import CustomDump
@testable import eRpFeatures
import eRpKit
@testable import eRpRemoteStorage
import GemPDFKit
import ModelsR4
import Nimble
import TestUtils
import XCTest

final class ChargeItemPDFServiceTests13: XCTestCase {
    override func setUp() {
        super.setUp()
        guard let folderURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("1.3")
        else {
            fatalError("Destination URL not created")
        }

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            } catch {
                fatalError("Could not create directory at \(folderURL): \(error)")
            }
        }
    }

    func testMultiplePDFs() throws {
        let files: [(String, String)] = [
            ("Freitext-Verordnung.json", "200.334.138.469.717.92"),
            ("PZN-Verordnung_Nr_1.json", "200.424.187.927.272.20"),
            ("PZN-Verordnung_Nr_2.json", "200.457.180.497.994.96"),
            ("PZN-Verordnung_Nr_3.json", "200.279.187.481.423.80"),
            ("PZN-Verordnung_Nr_5.json", "200.625.688.123.368.48"),
            ("PZN-Verordnung_Nr_6.json", "200.280.604.133.110.12"),
            ("PZN-Verordnung_Nr_7.json", "200.339.908.107.779.64"),
            ("PZN-Verordnung_Nr_8.json", "200.108.757.032.088.60"),
            ("PZN-Verordnung_Nr_14.json", "200.085.048.660.160.92"),
            ("PZN-Verordnung_Nr_15.json", "200.385.450.404.964.44"),
            ("PZN-Verordnung_Nr_16.json", "200.226.167.794.658.56"),
            ("PZN-Verordnung_Nr_17.json", "200.082.658.364.487.24"),
            ("PZN-Verordnung_Nr_18.json", "200.357.872.211.630.88"),
            ("PZN_Mehrfachverordnung_PZN_MV_1.json", "200.918.824.824.539.12"),
            ("PZN_Mehrfachverordnung_PZN_MV_2.json", "200.497.827.696.678.76"),
            ("PZN_Mehrfachverordnung_PZN_MV_3.json", "200.529.639.126.950.56"),
            ("PZN_Mehrfachverordnung_PZN_MV_4.json", "200.020.918.309.115.84"),
            (
                "Rezeptur-parenterale_Zytostatika_Rezeptur-parenterale_Zytostatika_1.json",
                "209.100.612.180.208.16"
            ),
            ("Rezeptur-Verordnung_Nr_1.json", "200.858.310.624.061.76"),
            ("Rezeptur-Verordnung_Nr_2.json", "200.800.419.351.304.52"),
            ("Wirkstoff-Verordnung.json", "200.643.100.572.979.08"),
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
            .appendingPathComponent("./1.3/\(file)")
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
        guard let chargeItem = try chargeItemFromFile(
            "Freitext-Verordnung.json",
            identifier: "200.334.138.469.717.92"
        )
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
                insuranceId: "P123464233",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Ernst Alder",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987789324"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "07.11.2024"
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
                    .init(name: "Beschaffungskosten", pzn: "09999637", count: "", price: "8,57"),
                ],
                sum: "36,15",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN1() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_1.json",
            identifier: "200.424.187.927.272.20"
        )
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_2.json",
            identifier: "200.457.180.497.994.96"
        )
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
                insuranceId: "P123464319",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: nil,
                name: "Emilia Becker",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("582369858"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_3.json",
            identifier: "200.279.187.481.423.80"
        )
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
                insuranceId: "P123464535",
                dateOfBirth: "30.07.2022"
            ),
            doctor: .init(
                title: "Dr.",
                name: "Dr. Maximilian Weber",
                address: "Yorckstraße 15\n93049 Regensburg",
                code: .lanr("456456534"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
                        pzn: "02567018",
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
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_5.json",
            identifier: "200.625.688.123.368.48"
        )
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Alexander Fischer",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("895268385"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_6.json",
            identifier: "200.280.604.133.110.12"
        )
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
                insuranceId: "P123464233",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_8.json",
            identifier: "200.108.757.032.088.60"
        )
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.108.757.032.088.60",
                medication: "1x Efluelda Injek.susp. 2024/2025 1 FER o. Kanüle N1/ N1 PZN: 18831500",
                articles: [
                    .init(
                        name: "wie verordnet",
                        pzn: "18831500",
                        count: "1",
                        price: "54,81"
                    ),
                    .init(
                        name: "Teilmenge aus",
                        pzn: "18831517",
                        count: "",
                        price: ""
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "54,81",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN14() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_14.json",
            identifier: "200.085.048.660.160.92"
        )
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
                insuranceId: "P123464319",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: "Dr.",
                name: "Dr. Hanna Schmidt",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("123412821"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.085.048.660.160.92",
                medication: "1x Azithromycin Heumann 500 mg 6 Filmtabletten N2/ 6 Stück N2 PZN: 16598620",
                articles: [
                    .init(
                        name: "Azithromycin Heumann 500 mg Filmtabletten N1",
                        pzn: "16598608",
                        count: "2",
                        price: "31,96"
                    ),
                ],
                production: nil,
                fees: [
                    .init(name: "Lieferengpass-Pauschale", pzn: "17717446", count: "", price: "0,60"),
                ],
                sum: "32,56",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN15() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_15.json",
            identifier: "200.385.450.404.964.44"
        )
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
                insuranceId: "P123464319",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.385.450.404.964.44",
                medication: "1x Benazepril AL 20mg 98 Filmtabletten N3/ 98 Stück N3 PZN: 04351736",
                articles: [
                    .init(
                        name: "Benazepril AL 10mg 98 Filmtabletten N3",
                        pzn: "04351707",
                        count: "2",
                        price: "30,74"
                    ),
                ],
                production: nil,
                fees: [
                    .init(name: "Lieferengpass-Pauschale", pzn: "17717446", count: "", price: "0,60"),
                ],
                sum: "31,34",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN16() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_16.json",
            identifier: "200.226.167.794.658.56"
        )
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.226.167.794.658.56",
                medication: "1x Tamoxifen Aristo 20 mg 30 Tabletten N1/ 30 Stück N1 PZN: 10410472",
                articles: [
                    .init(
                        name: "Tamoxifen AL 20 Tabletten N1",
                        pzn: "03852301",
                        count: "1",
                        price: "16,45"
                    ),
                    .init(
                        name: "Teilmenge aus",
                        pzn: "03852318",
                        count: "",
                        price: ""
                    ),
                ],
                production: nil,
                fees: [
                    .init(name: "Lieferengpass-Pauschale", pzn: "17717446", count: "", price: "0,60"),
                ],
                sum: "17,05",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN17() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_17.json",
            identifier: "200.082.658.364.487.24"
        )
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
                insuranceId: "P123464233",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.082.658.364.487.24",
                medication: "1x Doxycyclin 100 - 1 A Pharma® 50 Tbl. N3/ 50 Stück N3 PZN: 06437034",
                articles: [
                    .init(
                        name: "Doxycyclin 100-1A Pharma Tabletten N2",
                        pzn: "06437028",
                        count: "2",
                        price: "25,60"
                    ),
                    .init(
                        name: "Doxycyclin 100-1A Pharma Tabletten N1",
                        pzn: "06437011",
                        count: "1",
                        price: "11,84"
                    ),
                    .init(
                        name: "Teilmenge aus",
                        pzn: "06437028",
                        count: "",
                        price: ""
                    ),
                ],
                production: nil,
                fees: [
                    .init(name: "Lieferengpass-Pauschale", pzn: "17717446", count: "", price: "0,60"),
                ],
                sum: "38,04",
                currency: "EUR"
            )
        )
        expect(content).to(nodiff(expected))
    }

    func testPZN18() throws {
        guard let chargeItem = try chargeItemFromFile(
            "PZN-Verordnung_Nr_18.json",
            identifier: "200.357.872.211.630.88"
        )
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
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.357.872.211.630.88",
                medication: "1x COTRIM K-ratiopharm 200mg/5ml + 40mg/5ml Susp.z.E./ N1 PZN: 17550609",
                articles: [
                    .init(
                        name: "COTRIM-ratiopharm 400 mg/80 mg Tabletten N2",
                        pzn: "17550650",
                        count: "1",
                        price: "12,60"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "12,60",
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.918.824.824.539.12 gültig ab 03.11.2024 bis 31.01.2025 1 von 4 Verordnungen",
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "11.02.2025"
            ),
            dispense: .init(
                taskId: "200.497.827.696.678.76 gültig ab 15.01.2025 bis 31.03.2025 2 von 4 Verordnungen",
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "11.04.2025"
            ),
            dispense: .init(
                taskId: "200.529.639.126.950.56 gültig ab 15.03.2025 bis 30.06.2025 3 von 4 Verordnungen",
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "04.06.2025"
            ),
            dispense: .init(
                taskId: "200.020.918.309.115.84 gültig ab 01.06.2025 bis 30.09.2025 4 von 4 Verordnungen",
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
                insuranceId: "P123464319",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "06.11.2024"
            ),
            dispense: .init(
                taskId: "209.100.612.180.208.16",
                medication: "3x 500 ml Infusionslösung / Etoposid 180 mg / NaCl 0,9 % ad 500 ml",
                articles: [
                    .init(
                        name: "Parenterale Zubereitung",
                        pzn: "09999092",
                        count: "1",
                        price: "389,17"
                    ),
                ],
                production: "Bestandteile (Nettopreise):\nHerstellung 1 – 04.11.2024 13:00 Uhr: 1 01131365 11 0,36 17,33€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€\nHerstellung 2 – 05.11.2024 10:00 Uhr: 1 01131365 11 0,36 17,33€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€\nHerstellung 3 – 06.11.2024 11:00 Uhr: 1 01131365 11 0,36 17,33€ / 01131365 99 0,36 0,96€ / 09477471 11 0,05 1,36€ / 06460518 11 1 90,00€",
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
                insuranceId: "P123464117",
                dateOfBirth: "22.06.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Hanna Schmidt",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("123412821"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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
                insuranceId: "P123464233",
                dateOfBirth: "06.01.1935"
            ),
            doctor: .init(
                title: nil,
                name: "Hanna Schmidt",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("123412821"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
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

    func testWirkstoff() throws {
        guard let chargeItem = try chargeItemFromFile(
            "Wirkstoff-Verordnung.json",
            identifier: "200.643.100.572.979.08"
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
                insuranceId: "P123464319",
                dateOfBirth: "07.11.1969"
            ),
            doctor: .init(
                title: "Dr. med.",
                name: "Dr. med. Emma Schneider",
                address: "Herbert-Lewin-Platz 2\n10623 Berlin",
                code: .lanr("987654423"),
                prescribedOn: "03.11.2024"
            ),
            pharmacy: .init(
                name: "Adler-Apotheke",
                address: "Taunusstraße 89\n63225 Langen",
                iknr: "308412345",
                dispensedOn: "03.11.2024"
            ),
            dispense: .init(
                taskId: "200.643.100.572.979.08",
                medication: "1x 30 Stück Tabletten / Ramipril 22686 200 mg",
                articles: [
                    .init(
                        name: "Doxycyclin 200-1a Pharma Tabletten - 20 St",
                        pzn: "06437063",
                        count: "1",
                        price: "12,78"
                    ),
                    .init(
                        name: "Doxycyclin 200-1a Pharma Tabletten - 10 St",
                        pzn: "06437057",
                        count: "1",
                        price: "12,14"
                    ),
                ],
                production: nil,
                fees: [
                ],
                sum: "24,92",
                currency: "EUR"
            )
        )

        expect(content).to(nodiff(expected))
    }

    private func chargeItemFromFile(_ file: String, identifier: String) throws -> ErxChargeItem? {
        let data = try Bundle.module
            .testResourceFilePath(in: "PDF", for: "./1.3/\(file)")
            .readFileContents()
        return try JSONDecoder()
            .decode(ModelsR4.Bundle.self, from: data)
            .parseErxChargeItem(
                id: identifier,
                with: "fhirData".data(using: .utf8)!
            )
    }
}
