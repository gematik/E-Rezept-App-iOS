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

import eRpKit
import Foundation
import ModelsR4

extension ErxTaskOrder {
    func asCommunicationResource(
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }()
    ) throws -> Data {
        let communication = try createFHIRCommunication()
        return try encoder.encode(communication)
    }

    private var taskIdAndAccessCode: String {
        "Task/\(erxTaskId)/$accept?ac=\(accessCode)"
    }

    private func createFHIRCommunication() throws -> Communication {
        guard let communicationDispReq = Workflow.Key.communicationDispReq[.v1_4_3]?
            .asFHIRCanonicalPrimitive(for: "1.4") else {
            throw ErxTaskOrder.Error.unableToConstructCommunicationRequest
        }
        let meta = Meta(profile: [communicationDispReq])
        let reference = Reference(reference: taskIdAndAccessCode.asFHIRStringPrimitive())
        let payloadString = payload?.asJsonString().asFHIRStringPrimitive()
        var payload: [CommunicationPayload]? // swiftlint:disable:this discouraged_optional_collection
        if let payloadString = payloadString {
            payload = [CommunicationPayload(content: .string(payloadString))]
        }
        let telematikUri = Workflow.Key.telematikIdKeys[.v1_4_3]?.asFHIRURIPrimitive()
        let telematikId = Identifier(system: telematikUri,
                                     value: telematikId.asFHIRStringPrimitive())
        let orderUri = Workflow.Key.orderIdKeys[.v1_4_3]?.asFHIRURIPrimitive()
        let orderId = Identifier(system: orderUri,
                                 value: identifier.asFHIRStringPrimitive())
        let recipient = Reference(identifier: telematikId)

        guard let prescriptionTypeKey = Workflow.Key.prescriptionTypeKeys[.v1_4_3]?.asFHIRURIPrimitive() else {
            throw ErxTaskOrder.Error.unableToConstructCommunicationRequest
        }
        let flowType = Extension(
            url: prescriptionTypeKey,
            value: .coding(Coding(
                code: flowType.asFHIRStringPrimitive(),
                system: Workflow.Key.flowTypeKeys[.v1_4_3]?.asFHIRURIPrimitive()
            ))
        )
        return Communication(
            basedOn: [reference],
            extension: [flowType],
            identifier: [orderId],
            meta: meta,
            payload: payload,
            recipient: [recipient],
            status: EventStatus.unknown.asPrimitive()
        )
    }
}

extension ErxTaskOrder.Payload {
    func asJsonString(
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }()
    ) -> String {
        guard let data = try? encoder.encode(self) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension String {
    func asFHIRCanonicalPrimitive(for version: String) -> FHIRPrimitive<Canonical>? {
        let result = "\(self)|\(version)"
        guard let uri = result.asFHIRCanonical() else {
            return nil
        }
        return FHIRPrimitive(uri)
    }
}
