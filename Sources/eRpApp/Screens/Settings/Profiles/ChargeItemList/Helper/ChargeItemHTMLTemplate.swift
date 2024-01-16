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

import Foundation

struct ChargeItemHTMLTemplate {
    let content: Content

    var body: String { """
        <!DOCTYPE html>
        <html lang="de">
        \(head)
        <body>
        <h1>Digitaler Beleg zur Abrechnung Ihres E-Rezeptes</h1>
        <sub>Bitte leiten Sie diesen Beleg über die App an Ihre Versicherung weiter.</sub>
        \(patient)
        <div class="frame_row">
            \(doctor)
            \(pharmacy)
        </div>
        \(dispense)
        </body>
        </html>
    """
    }
}

extension ChargeItemHTMLTemplate {
    var patient: String {
        let patient = content.patient
        return """
                    <div class="frame">
                        <h5>Patient</h5>
                        <div class="content">
                            <div>
                                \(patient.title.map { "\($0) " } ?? "")\(patient.name)<br />
                                \(patient.address.escapingHTMLEntities())<br />
                                KVNr.: \(patient.insuranceId)<br />
                            </div>
                            <div class="top_right">
                                Geb. \(patient.dateOfBirth)
                            </div>
                        </div>
                    </div>
        """
    }

    var doctor: String {
        let doctor = content.doctor

        let code: String
        switch doctor.code {
        case let .lanr(lanr):
            code = "LANR: \(lanr)"
        case let .zanr(zanr):
            code = "ZANR: \(zanr)"
        default:
            code = ""
        }
        return """
                <div class="frame">
                    <h5>Aussteller</h5>
                    <div class="content">
                        <div style="grid-area: 1/span 2;">
                            \(doctor.title.map { "\($0) " } ?? "")\(doctor.name)<br />
                            \(doctor.address.escapingHTMLEntities())<br />
                            \(code)
                        </div>
                        <div style="padding-top: 1em;">
                            ausgestellt am:
                        </div>
                        <div class="bottom_end">
                            \(doctor.prescribedOn)
                        </div>
                    </div>
                </div>
        """
    }

    var pharmacy: String {
        let pharmacy = content.pharmacy
        return """
                <div class="frame">
                    <h5>Eingelöst</h5>
                    <div class="content">
                        <div style="grid-area: 1/span 2;">
                            \(pharmacy.name)<br />
                            \(pharmacy.address.escapingHTMLEntities())<br />
                            IKNr: \(pharmacy.iknr)
                        </div>
                        <div style="padding-top: 1em;">
                            abgegeben am:
                        </div>
                        <div class="bottom_end">
                            \(pharmacy.dispensedOn)
                        </div>
                    </div>
                </div>
        """
    }

    var feesSection: String {
        guard !content.dispense.fees.isEmpty else {
            return ""
        }

        return """
        <div class="header" style="padding-top: 0.5em;">Zusätzliche Gebühren</div>
        <div></div>
        <div></div>
        <div></div>
        \(fees)
        """
    }

    var ingredientsSection: String {
        guard let ingredients = content.dispense.production else {
            return ""
        }

        return """
        <div class="ingredients" style="grid-column-start: span 4; margin-top: 16px;">\(ingredients)</div>
        """
    }

    var dispense: String {
        let dispense = content.dispense

        return """
            <div class="frame">
                <h5>Kosten</h5>
                <div class="content costs">
                    <div class= header>Arzneimittel ID: \(dispense.taskId)</div>
                    <div></div>
                    <div></div>
                    <div></div>
                    <div>\(dispense.medication)</div>
                    <div></div>
                    <div></div>
                    <div></div>
                    <div class="header">Abgabe</div>
                    <div class="header">PZN</div>
                    <div class="header">Anz.</div>
                    <div class="header">Bruttopreis [€]</div>
                    \(articles)
                    \(ingredientsSection)
                    \(feesSection)
                    <div class="header">Gesamtsumme</div>
                    <div></div>
                    <div></div>
                    <div class="header fixedwidth" style="text-align: end;">\(dispense.sum)</div>
                </div>
            </div>
        </div>
        """
    }

    var articles: String {
        content.dispense.articles.map(entry(_:)).joined(separator: "")
    }

    var fees: String {
        content.dispense.fees.map(entry(_:)).joined(separator: "")
    }

    func entry(_ entry: Entry) -> String {
        """
            <div>\(entry.name)</div>
            <div>\(entry.pzn)</div>
            <div>\(entry.count)</div>
            <div>\(entry.price)</div>
        """
    }

    var style: String {
        """
                <style>
                    * {
                        padding: 0;
                        margin: 0;
                    }

                    body {
                        font-family: Courier, sans-serif;
                        font-size: 10px;
                        padding: 2cm 1cm;
                    }

                    h1, h2, h3, h4, h5, h6, h1 + sub, .header {
                        font-family: Arial;
                    }

                    .fixedwidth {
                        font-family: Courier, sans-serif;
                    }

                    h1 {
                        margin: 0 16px 0px;
                        font-size: 14px;
                    }

                    h1 + sub {
                        margin: 0 16px 16px;
                        font-weight: bold;
                    }

                    .frame_row {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                    }

                    .frame {
                        padding-top: 16pt;
                    }

                    .frame > h5 {
                        padding: 8px;
                        margin-left: 8px;
                    }

                    .frame > .content {
                        border: 1px solid black;
                        border-radius: 8px;
                        padding: 8px;
                        margin: 0 8px 8px;

                        display: grid;
                        grid-template-columns: 1fr 1fr;
                    }

                    .content > .top_right {
                        justify-self: end;
                    }

                    .content > .bottom_end {
                        justify-self: end;
                        align-self: end;
                    }

                    .content > .bottom_start {
                        justify-self: start;
                        align-self: end;
                    }

                    .frame > .costs {
                        line-height: 1.5em;

                        display: grid;
                        grid-template-columns: 4fr 1fr 1fr 1fr;
                    }

                    .costs > div:nth-last-child(-n+4),
                    .costs > .header {
                        font-weight: bold;
                        line-height: 2em;
                    }

                    .costs > div:nth-child(4n+4) {
                        text-align: end;
                    }
                </style>
        """
    }

    var head: String {
        """
                <head>
                    <meta charset="UTF-8">
                    <title>Abrechnung zur Vorlage bei Kostenträger</title>
                    \(style)
                </head>
        """
    }
}

extension ChargeItemHTMLTemplate {
    struct Content: Equatable {
        let patient: Patient
        let doctor: Doctor
        let pharmacy: Pharamcy
        let dispense: Dispense
    }

    struct Patient: Equatable {
        let title: String?
        let name: String
        let address: String
        let insuranceId: String

        let dateOfBirth: String
    }

    struct Doctor: Equatable {
        let title: String?
        let name: String
        let address: String
        let code: Code

        let prescribedOn: String

        enum Code: Equatable {
            case lanr(String)
            case zanr(String)
            case none
        }
    }

    struct Pharamcy: Equatable {
        let name: String
        let address: String
        let iknr: String

        let dispensedOn: String
    }

    struct Dispense: Equatable {
        let taskId: String
        let medication: String

        let articles: [Entry]
        let production: String?
        let fees: [Entry]

        let sum: String
        let currency: String
    }

    struct Entry: Equatable {
        let name: String
        let pzn: String
        let count: String
        let price: String
    }
}
