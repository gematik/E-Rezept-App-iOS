//
//  Copyright (c) 2022 gematik GmbH
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
    /// Load all medication dispenses since reference date
    case allMedicationDispenses(referenceDate: String?, handler: Handler)
    /// Loads content for a given url. Used for paging.
    case next(url: URL, handler: Handler)
}

extension ErxTaskFHIROperation: FHIRClientOperation {
    public func handle(response: FHIRClient.Response) throws -> Value {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(_, handler),
             let .taskBy(_, _, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(order: _, handler),
             let .allCommunications(_, handler),
             let .allMedicationDispenses(_, handler: handler),
             let .next(url: _, handler: handler):
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
            var queryItems: [URLQueryItem] = [URLQueryItem(name: "_sort", value: "date")]
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
        case .redeem(order: _, handler: _): return "Communication"
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
        case let .next(url: url, handler: _):
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
        case let .auditEvents(_, language, _):
            headers["Accept-Language"] = language
        case .redeem:
            headers["Content-Type"] = acceptFormat.httpHeaderValue
            if let dataLength = httpBody?.count, dataLength > 0 {
                headers["Content-Length"] = String(dataLength)
            }
        default: break
            // do nothing
        }
        return headers
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .deleteTask, .redeem:
            return .post
        default:
            return .get
        }
    }

    public var httpBody: Data? {
        switch self {
        case .capabilityStatement,
             .allTasks,
             .taskBy,
             .deleteTask,
             .auditEvents,
             .auditEventBy,
             .allCommunications,
             .allMedicationDispenses,
             .next:
            return nil
        case let .redeem(order: order, _):
            return try? order.asCommunicationResource()
        }
    }

    public var acceptFormat: FHIRAcceptFormat {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(_, handler),
             let .taskBy(_, _, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(_, handler),
             let .allCommunications(_, handler),
             let .allMedicationDispenses(_, handler: handler),
             let .next(url: _, handler: handler):
            return handler.acceptFormat
        }
    }
}
