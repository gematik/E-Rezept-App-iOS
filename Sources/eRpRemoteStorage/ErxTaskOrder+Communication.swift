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
import Foundation
import ModelsR4
import Sharing

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    /// A key to determine whether the app should use the 1.5 workflow for sending communications. This is intended for
    /// usage on test systems that already implement workflow 1.5 whereas production systems still use 1.4. As soon as
    /// production uses workflow 1.5, this key should be removed.
    public static var useWorkflow16ForSending: Self {
        Self[.appStorage("use_workflow_1_5_for_sending_communications"), default: false]
    }
}

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
        @Shared(.useWorkflow16ForSending) var useWorkflow16: Bool

        // Use this from 01.07.2026
        // return try createFHIRCommunication(version: .v1_6_1)
        return try createFHIRCommunication(version: useWorkflow16 ? .v1_6_1 : .v1_5_2)
    }

    private func createFHIRCommunication(version: Workflow.Version) throws -> Communication {
        guard let communicationDispReq = Workflow.Key.communicationDispReq[version]?
            .asFHIRCanonicalPrimitive(for: version.majorMinor) else {
            throw ErxTaskOrder.Error.unableToConstructCommunicationRequest
        }
        let meta = Meta(profile: [communicationDispReq])
        let reference = Reference(reference: taskIdAndAccessCode.asFHIRStringPrimitive())
        let payloadString = payload?.asJsonString().asFHIRStringPrimitive()
        var payload: [CommunicationPayload]? // swiftlint:disable:this discouraged_optional_collection
        if let payloadString {
            payload = [CommunicationPayload(content: .string(payloadString))]
        }
        let telematikUri = Workflow.Key.telematikIdKeys[version]?.asFHIRURIPrimitive()
        let telematikId = Identifier(system: telematikUri,
                                     value: telematikId.asFHIRStringPrimitive())
        let orderUri = Workflow.Key.orderIdKeys[version]?.asFHIRURIPrimitive()
        let orderId = Identifier(system: orderUri,
                                 value: identifier.asFHIRStringPrimitive())
        let recipient = Reference(identifier: telematikId)

        guard let prescriptionTypeKey = Workflow.Key.prescriptionTypeKeys[version]?.asFHIRURIPrimitive() else {
            throw ErxTaskOrder.Error.unableToConstructCommunicationRequest
        }
        let flowType = Extension(
            url: prescriptionTypeKey,
            value: .coding(Coding(
                code: flowType.asFHIRStringPrimitive(),
                system: Workflow.Key.flowTypeKeys[version]?.asFHIRURIPrimitive()
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
