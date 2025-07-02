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

import eRpKit
import FHIRClient
import Foundation
import HTTPClient

/// Operations we expect the FHIR service to possibly be able to perform
public enum ErxTaskFHIROperation<Value, Handler: FHIRResponseHandler> where Handler.Value == Value {
    /// Request the capability statement
    case capabilityStatement(handler: Handler)
    /// Request all tasks from the service in a certain format
    case allTasks(referenceDate: String?, handler: Handler)
    /// Request tasks next page from the service in a certain format
    case tasksNextPage(url: URL, handler: Handler)
    /// Request a specific task from the service in a certain format
    case taskBy(id: ErxTask.ID, accessCode: String?, handler: Handler)
    /// Delete(/Abort) a specific task by it's taskID and accessCode
    case deleteTask(id: ErxTask.ID, accessCode: String?, handler: Handler)
    /// Request a specific audit event from the service in a certain format
    case auditEventBy(id: ErxAuditEvent.ID, handler: Handler)
    /// Request all audit events for a specific language after a specific reference date from the service
    case auditEvents(referenceDate: String?, language: String?, handler: Handler)
    /// Request to redeem a `ErxTaskOrder` in a pharmacy
    case redeem(order: ErxTaskOrder, handler: Handler)
    /// Load communication resource from server
    case allCommunications(referenceDate: String?, handler: Handler)
    /// Request all medication dispenses from a specific prescription
    case medicationDispenses(id: ErxTask.ID, handler: Handler)
    /// Load all medication dispenses since reference date
    case allMedicationDispenses(referenceDate: String?, handler: Handler)
    /// Load all charge items since reference date
    case allChargeItems(referenceDate: String?, handler: Handler)
    /// Request a specific charge item from the service with the given ChargeItem id
    case chargeItemBy(id: String, handler: Handler)
    /// Delete a specific charge item by it's ID
    case deleteChargeItem(id: ErxChargeItem.ID, accessCode: String?, handler: Handler)
    /// Request all granted consents
    case consents(handler: Handler)
    /// Request to grant a `ErxConsent` of the given category
    case grant(consent: ErxConsent, handler: Handler)
    /// Delete the `ErxConsent` for the given `ErxConsent.Category`
    case revokeConsent(category: ErxConsent.Category, handler: Handler)
    /// Loads content for a given url. Used for paging.
    case auditEventsNextPage(url: URL, handler: Handler, locale: String?)
}

extension ErxTaskFHIROperation: FHIRClientOperation {
    public func handle(response: FHIRClient.Response) throws -> Value {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(referenceDate: _, handler: handler),
             let .tasksNextPage(_, handler),
             let .taskBy(_, _, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(order: _, handler),
             let .allCommunications(_, handler),
             let .medicationDispenses(_, handler),
             let .allMedicationDispenses(_, handler: handler),
             let .allChargeItems(_, handler),
             let .chargeItemBy(_, handler),
             let .deleteChargeItem(_, _, handler),
             let .consents(handler),
             let .grant(_, handler),
             let .revokeConsent(_, handler),
             let .auditEventsNextPage(url: _, handler: handler, locale: _):
            return try handler.handle(response: response)
        }
    }

    public var relativeUrlString: String? {
        switch self {
        case .capabilityStatement: return "metadata"
        case let .taskBy(taskId, _, _): return "Task/\(taskId)"
        case let .allTasks(referenceDate, _):
            var components = URLComponents(string: "Task")
            // endpoint expects format like "ge2021-01-31T10:00Z" where "ge" represents greater or equal
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate) {
                let modifiedItem = URLQueryItem(
                    name: "modified",
                    value: "ge\(fhirDate.fhirFormattedString(with: .yearMonthDayTime))"
                )
                components?.queryItems = [modifiedItem]
            }

            return components?.string
        case let .deleteTask(taskId, _, _): return "Task/\(taskId)/$abort"
        case let .auditEventBy(auditEventId, _): return "AuditEvent/\(auditEventId)"
        case let .auditEvents(referenceDate, _, _):
            var queryItems: [URLQueryItem] = [URLQueryItem(name: "_sort", value: "-date")]
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate) {
                let dateItem = URLQueryItem(
                    name: "date",
                    value: "ge\(fhirDate.fhirFormattedString(with: .yearMonthDayTime))"
                )
                queryItems.append(dateItem)
            }
            var components = URLComponents(string: "AuditEvent")
            components?.queryItems = queryItems
            return components?.string
        case .redeem: return "Communication"
        case let .allCommunications(referenceDate, handler: _):
            var components = URLComponents(string: "Communication")
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate) {
                let sentItem = URLQueryItem(
                    name: "sent",
                    value: "ge\(fhirDate.fhirFormattedString(with: .yearMonthDayTime))"
                )
                components?.queryItems = [sentItem]
            }
            return components?.string
        case let .medicationDispenses(taskId, handler: _):
            var components = URLComponents(string: "MedicationDispense")
            guard let key = Workflow.Key.prescriptionIdKeys[.v1_2_0] else {
                assertionFailure("Missing FHIR resource key")
                return components?.string
            }
            let item = URLQueryItem(
                name: "identifier",
                value: "\(key)|\(taskId)"
            )
            components?.queryItems = [item]
            return components?.string
        case let .allMedicationDispenses(referenceDate, handler: _):
            var components = URLComponents(string: "MedicationDispense")
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate) {
                let whenHandOverItem = URLQueryItem(
                    name: "whenHandedOver",
                    value: "ge\(fhirDate.fhirFormattedString(with: .yearMonthDayTime))"
                )
                components?.queryItems = [whenHandOverItem]
            }
            return components?.string
        case let .allChargeItems(referenceDate, handler: _):
            var components = URLComponents(string: "ChargeItem")
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate) {
                let enteredDate = URLQueryItem(
                    name: "enteredDate",
                    value: "ge\(fhirDate.fhirFormattedString(with: .yearMonthDayTime))"
                )
                components?.queryItems = [enteredDate]
            }
            return components?.string
        case let .chargeItemBy(chargeItemId, _): return "ChargeItem/\(chargeItemId)"
        case let .deleteChargeItem(chargeItemId, _, _): return "ChargeItem/\(chargeItemId)"
        case .consents: return "Consent"
        case .grant: return "Consent"
        case let .revokeConsent(category, handler: _):
            var components = URLComponents(string: "Consent")
            components?.queryItems = [
                URLQueryItem(
                    name: "category",
                    value: "\(category.rawValue)"
                ),
            ]
            return components?.string
        case let .auditEventsNextPage(url: url, handler: _, locale: _),
             let .tasksNextPage(url: url, handler: _):
            return url.absoluteString
        }
    }

    // Note: Only .json for now
    public var httpHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Accept"] = acceptFormat.httpHeaderValue
        switch self {
        case let .taskBy(_, accessCode, _),
             let .deleteTask(_, accessCode, _):
            headers["X-AccessCode"] = accessCode
        case let .auditEvents(_, language, _),
             let .auditEventsNextPage(url: _, _, language):
            headers["Accept-Language"] = language
        case let .redeem(order, _):
            headers["Content-Type"] = acceptFormat.httpHeaderValue
            headers["X-AccessCode"] = order.accessCode
            if let dataLength = httpBody?.count, dataLength > 0 {
                headers["Content-Length"] = String(dataLength)
            }
        case let .deleteChargeItem(_, accessCode, _):
            headers["X-AccessCode"] = accessCode
        case .grant:
            headers["Content-Type"] = acceptFormat.httpHeaderValue
            if let dataLength = httpBody?.count, dataLength > 0 {
                headers["Content-Length"] = String(dataLength)
            }
        case .revokeConsent:
            headers["Content-Type"] = acceptFormat.httpHeaderValue
        default: break
            // do nothing
        }
        return headers
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .deleteTask,
             .redeem,
             .grant:
            return .post
        case .deleteChargeItem,
             .revokeConsent:
            return .delete
        default:
            return .get
        }
    }

    public var httpBody: Data? {
        switch self {
        case .capabilityStatement,
             .allTasks,
             .tasksNextPage,
             .taskBy,
             .deleteTask,
             .auditEvents,
             .auditEventBy,
             .allCommunications,
             .medicationDispenses,
             .allMedicationDispenses,
             .allChargeItems,
             .chargeItemBy,
             .deleteChargeItem,
             .consents,
             .revokeConsent,
             .auditEventsNextPage:
            return nil
        case let .redeem(order: order, _):
            return try? order.asCommunicationResource()
        case let .grant(consent: consent, _):
            return try? consent.asConsentResource()
        }
    }

    public var acceptFormat: FHIRAcceptFormat {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(_, handler),
             let .taskBy(_, _, handler),
             let .tasksNextPage(_, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(_, handler),
             let .allCommunications(_, handler),
             let .medicationDispenses(_, handler),
             let .allMedicationDispenses(_, handler: handler),
             let .allChargeItems(_, handler: handler),
             let .chargeItemBy(_, handler),
             let .deleteChargeItem(_, _, handler),
             let .consents(handler: handler),
             let .grant(_, handler: handler),
             let .revokeConsent(_, handler: handler),
             let .auditEventsNextPage(url: _, handler: handler, locale: _):
            return handler.acceptFormat
        }
    }
}
