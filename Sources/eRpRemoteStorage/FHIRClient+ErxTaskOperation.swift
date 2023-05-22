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
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import ModelsR4

extension FHIRClient {
    /// Convenience function for requesting a certain task by ID
    ///
    /// - Parameters:
    ///   - id: The ID of the task to be requested
    ///   - accessCode: code to access the given `id` or nil when not required due to (previous|other) authorization
    /// - Returns: `AnyPublisher` that emits the task or nil when not found
    public func fetchTask(by id: ErxTask.ID,
                          accessCode: String?) -> AnyPublisher<ErxTask?, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> ErxTask? in
            let decoder = JSONDecoder()
            let resource: ModelsR4.Bundle
            do {
                resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch let DecodingError.dataCorrupted(context) {
                // fall back to JSON dictionary parsing
                let accessCode = fhirResponse.body.recoverAccessCode
                let pvsPruefnummer = fhirResponse.body.recoverPvsPruefnummer
                let recoverdFlowType = fhirResponse.body.recoverFlowType
                let authoredOn = fhirResponse.body.recoverAuthoredOn
                let prettyCodingPath = context.codingPath.reduce("") { partialResult, key -> String in
                    partialResult + "\(key.intValue?.description ?? key.stringValue)."
                }
                return ErxTask(
                    identifier: id,
                    status: .error(.decoding(
                        message: """
                        authoredOn: \(authoredOn ?? "")
                        pvsPruefnummer: \(pvsPruefnummer ?? "")
                        JSON codingPath: \(prettyCodingPath)
                        debug description: \(context.debugDescription)
                        """
                    )),
                    flowType: ErxTask.FlowType(rawValue: recoverdFlowType),
                    accessCode: accessCode,
                    authoredOn: authoredOn
                )
            } catch {
                return ErxTask(
                    identifier: id,
                    status: .error(.unknown(message: "\(error)")),
                    flowType: ErxTask.FlowType(rawValue: String(id.prefix(3))),
                    accessCode: accessCode
                )
            }
            return resource.parseErxTask(taskId: id)
        }

        return execute(operation: ErxTaskFHIROperation.taskBy(id: id, accessCode: accessCode, handler: handler))
    }

    /// Convenience function for requesting all task ids
    ///
    /// - Note: the simplifier (and the gematik specification) documentation is not clear as how to handle multiple
    ///         tasks in one bundle/requests
    ///
    /// - Returns: `AnyPublisher` that emits the ids for the found  tasks
    /// - Parameter referenceDate: Tasks with modification date greater or equal `referenceDate` will be fetched
    public func fetchAllTaskIDs(after referenceDate: String?) -> AnyPublisher<[String], FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> [String] in
            let decoder = JSONDecoder()

            do {
                let resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                return try resource.parseErxTaskIDs()
            } catch {
                throw Error.decoding(error)
            }
        }

        return execute(operation: ErxTaskFHIROperation.allTasks(referenceDate: referenceDate, handler: handler))
    }

    /// Convenience function for deleting a task
    ///
    /// - Parameters:
    ///   - id: The ID of the task to be requested
    ///   - accessCode: code to access the given `id` or nil when not required due to (previous|other) authorization
    /// - Returns: `AnyPublisher` that emits the task or nil when not found
    public func deleteTask(by id: ErxTask.ID,
                           accessCode: String?) -> AnyPublisher<Bool, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> Bool in
            let resource: ModelsR4.Bundle
            if fhirResponse.status.isNoContent {
                // Successful delete is supposed to produces return code 204 and an empty body.
                // So we actually do not need to parse anything
                return true
            } else {
                do {
                    resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                } catch {
                    throw Error.decoding(error)
                }
                return resource.parseErxTask(taskId: id) == nil
            }
        }

        return execute(operation: ErxTaskFHIROperation.deleteTask(id: id, accessCode: accessCode, handler: handler))
            .tryCatch { error -> AnyPublisher<Bool, FHIRClient.Error> in
                // When the server responds with 404 we handle this as a success case for
                // deletion. Obviously the server does not know the task which means we can
                // safely delete it locally as well. Hence we return true so the task is
                // subsequently also deleted locally on the device. Also see comments in ticket ERA-800.
                if case let FHIRClient.Error.operationOutcome(outcome) = error,
                   let type = outcome.issue.first?.code,
                   type == IssueType.notFound {
                    return Just(true).setFailureType(to: FHIRClient.Error.self).eraseToAnyPublisher()
                }
                throw error
            }
            .mapError { $0 as? FHIRClient.Error ?? FHIRClient.Error.unknown($0) }
            .eraseToAnyPublisher()
    }

    /// Convenience function for requesting a certain audit event by ID
    ///
    /// - Parameters:
    ///   - id: The ID of the audit event to be requested
    ///   - accessCode: code to access the given `id` or nil when not required due to (previous|other) authorization
    /// - Returns: `AnyPublisher` that emits the audit event or nil when not found
    public func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> ErxAuditEvent? in
            let resource: ModelsR4.Bundle
            do {
                resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            return try resource.parseErxAuditEvents().first
        }

        return execute(operation: ErxTaskFHIROperation.auditEventBy(id: id, handler: handler))
    }

    /// Convenience function for requesting audit events
    ///
    /// - Returns: `AnyPublisher` that emits the audit events
    /// - Parameters:
    ///   - referenceDate:Audit-Events with date greater or equal `referenceDate` will be fetched.
    ///                   Pass `nil` for fetching all audit events
    ///   - locale: Locale key for which language the audit events will be fetched.
    ///             Nil if all languages should be fetched
    public func fetchAllAuditEvents(
        after referenceDate: String? = nil,
        for locale: String? = nil
    ) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, FHIRClient.Error> {
        let handler =
            DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> PagedContent<[ErxAuditEvent]> in
                do {
                    let resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                    return try resource.parseErxAuditEventsContainer()
                } catch {
                    throw Error.decoding(error)
                }
            }

        return execute(operation: ErxTaskFHIROperation.auditEvents(referenceDate: referenceDate,
                                                                   language: locale,
                                                                   handler: handler))
    }

    /// Convenience function for requesting audit events
    ///
    /// - Returns: `AnyPublisher` that emits the audit events
    /// - Parameters:
    ///   - previousPage: The previous page of the requested one.
    public func fetchAuditEventsNextPage(of previousPage: PagedContent<[ErxAuditEvent]>, for locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, FHIRClient.Error> {
        let handler =
            DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> PagedContent<[ErxAuditEvent]> in
                do {
                    let resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                    return try resource.parseErxAuditEventsContainer()
                } catch {
                    throw Error.decoding(error)
                }
            }

        guard let url = previousPage.next else {
            return Fail(error: FHIRClient.Error.internalError("Requesting next page without link."))
                .eraseToAnyPublisher()
        }

        return execute(operation: ErxTaskFHIROperation.next(url: url, handler: handler, locale: locale))
    }

    /// Convenience function for redeeming an `ErxTask` in a pharmacy
    /// - Parameter order: The information relevant for placing the order
    /// - Returns: `true` if the server responds without error and parsing has been successful, otherwise  error
    public func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> ErxTaskOrder in
            do {
                _ = try FHIRClient.decoder.decode(ModelsR4.Communication.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }

            return order
        }

        return execute(operation: ErxTaskFHIROperation.redeem(order: order, handler: handler))
    }

    /// Requests all communication Resources for the logged in user
    /// - Returns: Array of all loaded communication resources
    /// - Parameter referenceDate: Communications with `timestamp` greater or equal `referenceDate` will be fetched
    public func communicationResources(
        after referenceDate: String?
    ) -> AnyPublisher<[ErxTask.Communication], FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> [ErxTask.Communication] in
            do {
                let resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                return try resource.parseErxTaskCommunications()
            } catch {
                throw Error.decoding(error)
            }
        }

        return execute(operation: ErxTaskFHIROperation
            .allCommunications(referenceDate: referenceDate, handler: handler))
    }

    /// Requests medication dispenses for a specific `Prescription`
    /// - Parameter id: MedicationDispense for the corresponding `ErxTask.ID` will be fetched.
    /// - Returns: `AnyPublisher` that emits `MedicationDispense`s
    public func fetchMedicationDispenses(
        for id: ErxTask.ID
    ) -> AnyPublisher<[ErxMedicationDispense], FHIRClient.Error> {
        let handler =
            DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> [ErxMedicationDispense] in
                do {
                    let resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                    return try resource.parseErxMedicationDispenses()
                } catch {
                    throw Error.decoding(error)
                }
            }

        return execute(operation: ErxTaskFHIROperation
            .medicationDispenses(id: id, handler: handler))
    }

    /// Convenience function for requesting a certain charge item by ID
    ///
    /// - Parameters:
    ///   - id: The ID of the charge item to be requested
    /// - Returns: `AnyPublisher` that emits the charge item or nil when not found
    public func fetchChargeItem(by id: ErxChargeItem.ID)
        -> AnyPublisher<ErxChargeItem?, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> ErxChargeItem? in
            let resource: ModelsR4.Bundle
            do {
                resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
            } catch {
                throw Error.decoding(error)
            }
            return try resource.parseErxChargeItem(id: id, with: fhirResponse.body)
        }

        return execute(operation: ErxTaskFHIROperation.chargeItemBy(id: id, handler: handler))
    }

    /// Convenience function for requesting all charge item ids
    ///
    /// - Returns: `AnyPublisher` that emits the ids for the found charge items
    /// - Parameter referenceDate: Charge items with entered date greater or equal `referenceDate` will be fetched
    public func fetchAllChargeItemIDs(after referenceDate: String?) -> AnyPublisher<[String], FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> [String] in
            let decoder = JSONDecoder()

            do {
                let resource = try decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                return try resource.parseErxChargeItemIDs()
            } catch {
                throw Error.decoding(error)
            }
        }

        return execute(operation: ErxTaskFHIROperation.allChargeItems(referenceDate: referenceDate, handler: handler))
    }

    /// Convenience function for deleting a charge item
    ///
    /// - Parameters:
    ///   - id: The ID of the charge item to be deleted
    ///   - accessCode: code to access the given `id` or nil when not required due to (previous/other) authorisation
    /// - Returns: `AnyPublisher` that emits true if the item was deleted
    public func deleteChargeItem(
        by id: ErxChargeItem.ID,
        accessCode: String?
    ) -> AnyPublisher<Bool, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> Bool in
            let resource: ModelsR4.Bundle
            if fhirResponse.status.isNoContent {
                // Successful delete is supposed to produces return code 204 and an empty body.
                // So we actually do not need to parse anything
                return true
            } else {
                do {
                    resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                } catch {
                    throw Error.decoding(error)
                }
                return try resource.parseErxChargeItem(id: id, with: fhirResponse.body) == nil
            }
        }

        return execute(operation: ErxTaskFHIROperation.deleteTask(id: id, accessCode: accessCode, handler: handler))
            .tryCatch { error -> AnyPublisher<Bool, FHIRClient.Error> in
                // When the server responds with 404 we handle this as a success case for
                // deletion. Obviously the server does not know the charge item which means we can
                // safely delete it locally as well. Hence we return true so the charge item is
                // subsequently also deleted locally on the device. Also see comments in ticket ERA-800.
                if case let FHIRClient.Error.operationOutcome(outcome) = error,
                   let type = outcome.issue.first?.code,
                   type == IssueType.notFound {
                    return Just(true).setFailureType(to: FHIRClient.Error.self).eraseToAnyPublisher()
                }
                throw error
            }
            .mapError { $0 as? FHIRClient.Error ?? FHIRClient.Error.unknown($0) }
            .eraseToAnyPublisher()
    }

    /// Loads All consents of a given profile
    /// Uses the request headers  ACCESS_TOKEN with the containing insurance id
    /// - Returns: Array of all loaded `ErxConsent`
    public func fetchConsents() -> AnyPublisher<[ErxConsent], FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> [ErxConsent] in
            do {
                let resource = try FHIRClient.decoder.decode(ModelsR4.Bundle.self, from: fhirResponse.body)
                return try resource.parseErxConsents()
            } catch {
                throw Error.decoding(error)
            }
        }

        return execute(operation: ErxTaskFHIROperation.consents(handler: handler))
    }

    /// Send a grant consent request of  an `ErxConsent`
    /// - Parameter consent: Consent that contains information about the type of consent
    ///                         and insurance id which the consent will be granted for
    /// - Returns: The `ErxConsent` that was granted or nil when not found
    public func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> ErxConsent? in
            do {
                let resource = try FHIRClient.decoder.decode(ModelsR4.Consent.self, from: fhirResponse.body)
                return try resource.parseErxConsent()
            } catch {
                throw Error.decoding(error)
            }
        }

        return execute(operation: ErxTaskFHIROperation.grant(consent: consent, handler: handler))
    }

    /// Delete an consent of `ErxConsent` to revoke it
    /// - Parameters:
    ///   - category: the `ErxConsent.Category`of the consent to be revoked
    /// - Returns: Publisher for the load request
    public func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, FHIRClient.Error> {
        let handler = DefaultFHIRResponseHandler { (fhirResponse: FHIRClient.Response) -> Bool in
            if fhirResponse.status.isNoContent {
                // Successful deletion is supposed to produce return code 204 and an empty body.
                // So we actually do not need to parse anything
                return true
            }

            throw FHIRClient.Error.inconsistentResponse
        }

        return execute(operation: ErxTaskFHIROperation.revokeConsent(category: category, handler: handler))
    }

    static var decoder: JSONDecoder {
        JSONDecoder()
    }
}

extension Data {
    var recoverPvsPruefnummer: String? {
        if let json = try? JSONSerialization.jsonObject(with: self),
           let jsonDict = json as? [String: Any],
           let entries = jsonDict["entry"] as? [[String: Any]],
           let kbvBundle = entries.first(
               where: { ($0["resource"] as? [String: Any])?["resourceType"] as? String == .some("Bundle") }
           ),
           let kbvResource = kbvBundle["resource"] as? [String: Any],
           let kbvEntries = kbvResource["entry"] as? [[String: Any]],
           let composition = kbvEntries.first(
               where: { ($0["resource"] as? [String: Any])?["resourceType"] as? String == .some("Composition") }
           ),
           let compositionResource = composition["resource"] as? [String: Any],
           let author = compositionResource["author"] as? [[String: Any]],
           let device = author.first(
               where: { $0["type"] as? String == .some("Device") }
           ),
           let identifier = device["identifier"] as? [String: Any],
           let value = identifier["value"] as? String {
            return value
        }
        return nil
    }

    var recoverAccessCode: String? {
        if let json = try? JSONSerialization.jsonObject(with: self),
           let jsonDict = json as? [String: Any],
           let entries = jsonDict["entry"] as? [[String: Any]],
           let task = entries.first(
               where: { ($0["resource"] as? [String: Any])?["resourceType"] as? String == .some("Task") }
           ),
           let taskResource = task["resource"] as? [String: Any],
           let identifierEntries = taskResource["identifier"] as? [[String: Any]],
           let accessCode = identifierEntries.first(where: { identifier in
               Workflow.Key.accessCodeKeys.contains { $0.value == identifier["system"] as? String }
           }),
           let value = accessCode["value"] as? String {
            return value
        }
        return nil
    }

    var recoverAuthoredOn: String? {
        if let json = try? JSONSerialization.jsonObject(with: self),
           let jsonDict = json as? [String: Any],
           let entries = jsonDict["entry"] as? [[String: Any]],
           let task = entries.first(
               where: { ($0["resource"] as? [String: Any])?["resourceType"] as? String == .some("Task") }
           ),
           let taskResource = task["resource"] as? [String: Any],
           let authoredOn = taskResource["authoredOn"] as? String {
            return authoredOn
        }
        return nil
    }

    var recoverFlowType: String? {
        if let json = try? JSONSerialization.jsonObject(with: self),
           let jsonDict = json as? [String: Any],
           let entries = jsonDict["entry"] as? [[String: Any]],
           let task = entries.first(
               where: { ($0["resource"] as? [String: Any])?["resourceType"] as? String == .some("Task") }
           ),
           let taskResource = task["resource"] as? [String: Any],
           let extensionEntities = taskResource["extension"] as? [[String: Any]],
           let flowExtension = extensionEntities.first(where: { anExtension in
               Workflow.Key.prescriptionTypeKeys.contains { $0.value == anExtension["url"] as? String }
           }),
           let valueCoding = flowExtension["valueCoding"] as? [String: String],
           Workflow.Key.flowTypeKeys.contains(where: { $0.value == valueCoding["system"] }),
           let flowType = valueCoding["code"] {
            return flowType
        }
        return nil
    }
}
