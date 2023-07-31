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

import Dependencies
import eRpKit
import Foundation
import GemPDFKit
import UIKit

// sourcery: CodedError = "035"
enum ChargeItemPDFServiceError: Error {
    // sourcery: errorCode = "01"
    case couldNotCreateDestinationURL
    // sourcery: errorCode = "02"
    case couldNotCreatePDFStringForParsing
    // sourcery: errorCode = "03"
    case parsingError(Error)
    // sourcery: errorCode = "04"
    case failedToCreateAttachment(Error)

    // sourcery: errorCode = "05"
    case dataMissingPatient
    // sourcery: errorCode = "06"
    case dataMissingDoctor
    // sourcery: errorCode = "07"
    case dataMissingPharmacy
    // sourcery: errorCode = "08"
    case dataMissingInvoice
}

protocol ChargeItemPDFService {
    func generatePDF(for chargeItem: ErxChargeItem) throws -> Data
    func loadPDFOrGenerate(for chargeItem: ErxChargeItem) throws -> URL
}

struct ChargeItemPDFServiceDependency: DependencyKey {
    static let liveValue: ChargeItemPDFService = DefaultChargeItemPDFService()

    static let previewValue: ChargeItemPDFService = liveValue

    static let testValue: ChargeItemPDFService = UnimplementedChargeItemPDFService()
}

extension DependencyValues {
    var chargeItemPDFService: ChargeItemPDFService {
        get { self[ChargeItemPDFServiceDependency.self] }
        set { self[ChargeItemPDFServiceDependency.self] = newValue }
    }
}

struct DefaultChargeItemPDFService: ChargeItemPDFService {
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: .shared)

    func loadPDFOrGenerate(for chargeItem: ErxChargeItem) throws -> URL {
        guard let outputURL = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("output")
        .appendingPathExtension("pdf") else {
            throw ChargeItemPDFServiceError.couldNotCreateDestinationURL
        }

        var result = try generatePDF(for: chargeItem)

        guard let resultString = String(data: result, encoding: .ascii) else {
            throw ChargeItemPDFServiceError.couldNotCreatePDFStringForParsing
        }

        let document: PDFDocument

        do {
            document = try PDFDocument.PDFDocumentParserPrinter().parse(resultString)
        } catch {
            throw ChargeItemPDFServiceError.parsingError(error)
        }

        let attachmentData = chargeItem.receiptSignature?.data?.data(using: .utf8) ?? Data()
        let attachment = PDFAttachment(filename: "Data", content: attachmentData)

        let printedAttachment: Data
        do {
            printedAttachment = try document.append(attachment: attachment, startObj: result.count)
        } catch {
            throw ChargeItemPDFServiceError.failedToCreateAttachment(error)
        }
        result.append(printedAttachment)

        try result.write(to: outputURL)

        return outputURL
    }

    // swiftlint:disable:next function_body_length
    func content(for chargeItem: ErxChargeItem) throws -> ChargeItemHTMLTemplate.Content {
        guard let patient = chargeItem.patient else {
            throw ChargeItemPDFServiceError.dataMissingPatient
        }
        let patientTData = ChargeItemHTMLTemplate.Patient(
            title: patient.title,
            name: patient.name ?? "",
            address: patient.address ?? "",
            insuranceId: patient.insuranceId ?? "",
            dateOfBirth: patient.birthDate.map { uiDateFormatter.date($0) ?? "" } ?? ""
        )

        guard let doctor = chargeItem.practitioner,
              let organization = chargeItem.organization else {
            throw ChargeItemPDFServiceError.dataMissingDoctor
        }

        let doctorsTData = ChargeItemHTMLTemplate.Doctor(
            title: doctor.title,
            name: doctor.name ?? "",
            address: organization.address ?? "",
            code: {
                if let lanr = doctor.lanr {
                    return .lanr(lanr)
                } else if let zanr = doctor.zanr {
                    return .zanr(zanr)
                }
                return .none
            }(),
            prescribedOn: chargeItem.medicationRequest.authoredOn.map { uiDateFormatter.date($0) ?? "" } ?? ""
        )

        guard let pharmacy = chargeItem.pharmacy else {
            throw ChargeItemPDFServiceError.dataMissingPharmacy
        }
        let pharamcyTData = ChargeItemHTMLTemplate.Pharamcy(
            name: pharmacy.name,
            address: pharmacy.address,
            iknr: pharmacy.identifier,
            dispensedOn: chargeItem.medicationDispense?.whenHandedOver.map { uiDateFormatter.date($0) ?? "" } ?? ""
        )

        guard let invoice = chargeItem.invoice else {
            throw ChargeItemPDFServiceError.dataMissingInvoice
        }

        let specials = [
            "02567018",
            "02567001",
            "06460688",
            "09999637",
            "06461110",
        ]

        let feesAndArticles = invoice.chargeableItems
        let fees = feesAndArticles
            .filter { item in
                guard let ta1 = item.ta1 else { return false }
                return specials.contains(ta1)
            }
            .map { article in
                article.toFeesEntry()
            }

        let articles: [ChargeItemHTMLTemplate.Entry] = feesAndArticles
            .filter { item in
                guard let ta1 = item.ta1 else { return true }
                return !specials.contains(ta1)
            }
            .map { article in
                article.toEntry(for: chargeItem.medication)
            }

        let compounding = feesAndArticles
            .contains { item in
                guard let pzn = item.pzn ?? item.ta1 else { return false }
                return ["09999011", "06460702"].contains(pzn)
            }

        let production = productionSteps(for: invoice, compounding: compounding)

        let dispenseTData = ChargeItemHTMLTemplate.Dispense(
            taskId: taskId(for: chargeItem),
            medication: medicationText(for: chargeItem.medication, request: chargeItem.medicationRequest),
            articles: articles,
            production: production,
            fees: fees,
            sum: invoice.totalGross.formatted(.number.precision(.fractionLength(2 ... 2))),
            currency: invoice.currency
        )

        return ChargeItemHTMLTemplate.Content(
            patient: patientTData,
            doctor: doctorsTData,
            pharmacy: pharamcyTData,
            dispense: dispenseTData
        )
    }

    func productionSteps(for invoice: DavInvoice, compounding: Bool) -> String? {
        guard !invoice.productionSteps.isEmpty else {
            return nil
        }
        var result = ""

        if compounding {
            result += "Bestandteile: "
        } else {
            result += "Bestandteile (Nettopreise):\n"
        }

        result += invoice.productionSteps
            .map { step in
                var result = ""
                if !compounding {
                    result += "\(step.title) – \(uiDateFormatter.dateTime(step.createdOn) ?? "") Uhr: "
                    result += "\(step.sequence) "
                }
                result += step.ingredients
                    .map { ingredient in
                        var result = "\(ingredient.pzn) "
                        if let mark = ingredient.factorMark {
                            result += "\(mark) "
                        }
                        if let factor = ingredient.factor {
                            result += "\(factor.formatted()) "
                        }
                        result += "\(ingredient.price.formatted(.number.precision(.fractionLength(2 ... 2))))€"
                        return result
                    }
                    .joined(separator: " / ")
                return result
            }
            .joined(separator: "\n")

        if compounding {
            result += " (Nettopreise)"
        }

        return result
    }

    func taskId(for chargeItem: ErxChargeItem) -> String {
        if let multiplePrescription = chargeItem.medicationRequest.multiplePrescription {
            let period: String
            if let fromDate = uiDateFormatter.date(multiplePrescription.startPeriod),
               let toDate = uiDateFormatter.date(multiplePrescription.endPeriod) {
                period = " gültig ab \(fromDate) bis \(toDate)"
            } else {
                period = ""
            }
            let counter: String
            if let counterFrom = multiplePrescription.numbering?.formatted(),
               let counterOf = multiplePrescription.totalNumber?.formatted() {
                counter = " \(counterFrom) von \(counterOf) Verordnungen"
            } else {
                counter = ""
            }
            return "\(chargeItem.taskId ?? "")\(period)\(counter)"
        }
        return chargeItem.taskId ?? ""
    }

    func medicationText(for medication: ErxMedication?, request: ErxMedicationRequest) -> String {
        guard let medication = medication,
              let profile = medication.profile else {
            return ""
        }
        switch profile {
        case .freeText:
            return
                "Freitextverordnung: \(request.quantity.map { "\($0.formatted())x" } ?? "") \(medication.displayName)"
        case .pzn:
            let v26 = request.quantity.map { "\($0.formatted())x " } ?? ""
            let v25 = "\(medication.displayName)/ "
            let v27 = medication.amount?.numerator.value.appending(" ") ?? ""
            let v28 = medication.amount?.numerator.unit?.appending(" ") ?? ""
            let v29 = medication.normSizeCode?.appending(" ") ?? ""
            let v24 = (medication.pzn as String?).map { "PZN: \($0)" } ?? ""
            return [v26, v25, v27, v28, v29, v24].compactMap { $0 }.joined()
        case .ingredient, .compounding:
            let v26 = request.quantity.map { "\($0.formatted())x " } ?? ""
            let v34 = ""
            let v35 = medication.amount?.numerator.value.appending(" ") ?? ""
            let v36 = medication.amount?.numerator.unit?.appending(" ") ?? ""
            let v37 = medication.dosageForm?.description ?? ""
            let v44 = ""

            let ingredients = medication.ingredients
                .map { ingredient in
                    let v40 = ingredient.text
                    let v45 = ingredient.number
                    let v41 = ingredient.strength?.numerator.value
                    let v42 = ingredient.strength?.numerator.unit
                    let v43 = ingredient.strengthFreeText

                    return [v40, v45, v41, v42, v43].compactMap { $0 }.joined(separator: " ")
                }

            let medication = [v26, v34, v35, v36, v37, v44].compactMap { $0 }.joined()

            return ([medication] + ingredients).compactMap { $0 }.joined(separator: " / ")
        case .unknown:
            return ""
        }
    }

    func generatePDF(for chargeItem: ErxChargeItem) throws -> Data {
        let content = try content(for: chargeItem)

        let html = ChargeItemHTMLTemplate(content: content).body
        let fmt = UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 21.0 * 0.393701 * 72, 29.7 * 0.393701 * 72
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 21.0 * 0.393700 * 72, height: 29.7 * 0.393700 * 72) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        let metadata = [
            kCGPDFContextAuthor: "E-Rezept-App (\(AppVersion.current.productVersion), "
                + "\(AppVersion.current.buildNumber) #\(AppVersion.current.buildHash))",
        ]

        UIGraphicsBeginPDFContextToData(pdfData, page, metadata)

        for pageNumber in 0 ..< render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: pageNumber, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        return pdfData as Data
    }
}

extension DavInvoice.ChargeableItem {
    func toFeesEntry() -> ChargeItemHTMLTemplate.Entry {
        let specials = [
            "02567018": "Notdienstgebühr",
            "02567001": "BTM-Gebühr",
            "06460688": "T-Rezept Gebühr",
            "09999637": "Beschaffungskosten",
            "06461110": "Botendienst",
        ]

        let name: String
        if let specialsName = specials[ta1 ?? ""] {
            name = specialsName
        } else {
            name = hmrn ?? pzn ?? ta1 ?? ""
        }

        return ChargeItemHTMLTemplate.Entry(
            name: name,
            pzn: "",
            count: "",
            price: price?.formatted(.number.precision(.fractionLength(2 ... 2))) ?? ""
        )
    }

    func toEntry(for medication: ErxMedication?) -> ChargeItemHTMLTemplate.Entry {
        let text: String
        let col2 = pzn ?? hmrn ?? ta1 ?? ""

        if let pzn = self.pzn,
           pzn == medication?.pzn {
            text = "wie verordnet"
        } else {
            text = description ?? ""
        }

        return .init(
            name: text,
            pzn: col2,
            count: factor.formatted(),
            price: price?.formatted(.number.precision(.fractionLength(2 ... 2))) ?? ""
        )
    }
}

extension String {
    func linebreakToComma() -> String {
        replacingOccurrences(of: "\n", with: ", ")
    }

    func escapingHTMLEntities() -> String {
        replacingOccurrences(of: "\n", with: "<br />\n")
    }
}
