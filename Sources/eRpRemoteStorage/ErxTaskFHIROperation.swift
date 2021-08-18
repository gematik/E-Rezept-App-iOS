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

import eRpKit
import FHIRClient
import Foundation
import HTTPClient

/// Operations we expect the FHIR service to possibly be able to perform
public enum ErxTaskFHIROperation<Value, Handler: FHIRResponseHandler> where Handler.Value == Value {
    /// Request the capability statement
    case capabilityStatement(handler: Handler)
    /// Request all tasks from the service in a certain format
    case allTasks(handler: Handler)
    /// Request a specific task from the service in a certain format
    case taskBy(id: ErxTask.ID, accessCode: String?, handler: Handler)
    // swiftlint:disable:previous identifier_name
    /// Delete(/Abort) a specific task by it's taskID and accessCode
    case deleteTask(id: ErxTask.ID, accessCode: String?, handler: Handler)
    // swiftlint:disable:previous identifier_name
    /// Request a specific audit event from the service in a certain format
    case auditEventBy(id: ErxAuditEvent.ID, handler: Handler)
    // swiftlint:disable:previous identifier_name
    /// Request all audit events for a specific language after a specific reference date from the service
    case auditEvents(referenceDate: String?, language: String?, handler: Handler)
    /// Request to redeem a `ErxTaskOrder` in a pharmacy
    case redeem(order: ErxTaskOrder, handler: Handler)
    /// Load communication resource from server
    case communicationResource(handler: Handler)
}

extension ErxTaskFHIROperation: FHIRClientOperation {
    public func handle(response: FHIRClient.Response) throws -> Value {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(handler),
             let .taskBy(_, _, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(order: _, handler),
             let .communicationResource(handler):
            return try handler.handle(response: response)
        }
    }

    public var path: String {
        switch self {
        case .capabilityStatement: return "metadata"
        case let .taskBy(taskId, _, _): return "Task/\(taskId)"
        case .allTasks: return "Task"
        case let .deleteTask(taskId, _, _): return "Task/\(taskId)/$abort"
        case let .auditEventBy(auditEventId, _): return "AuditEvent/\(auditEventId)"
        case let .auditEvents(referenceDate, _, _):
            if let referenceDate = referenceDate,
               let fhirDate = FHIRDateFormatter.shared.date(from: referenceDate),
               let encodedDateString = fhirDate.fhirFormattedString(with: .yearMonthDayTime).urlPercentEscapedString() {
                return "AuditEvent?date=ge\(encodedDateString)&_sort=-date"
            } else {
                return "AuditEvent?_sort=-date"
            }
        case .redeem(order: _, handler: _), .communicationResource(handler: _): return "Communication"
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
             .communicationResource:
            return nil
        case let .redeem(order: order, _):
            return try? order.asCommunicationResource()
        }
    }

    public var acceptFormat: FHIRAcceptFormat {
        switch self {
        case let .capabilityStatement(handler),
             let .allTasks(handler),
             let .taskBy(_, _, handler),
             let .deleteTask(_, _, handler),
             let .auditEventBy(_, handler),
             let .auditEvents(_, _, handler),
             let .redeem(_, handler),
             let .communicationResource(handler):
            return handler.acceptFormat
        }
    }
}
