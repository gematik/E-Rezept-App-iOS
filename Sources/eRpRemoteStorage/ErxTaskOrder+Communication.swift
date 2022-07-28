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
import Foundation
import ModelsR4

extension ErxTaskOrder {
    func asCommunicationResource(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        let communication = try createFHIRCommunication()
        return try encoder.encode(communication)
    }

    private var taskIdAndAccessCode: String {
        "Task/\(erxTaskId)/$accept?ac=\(accessCode)"
    }

    private func createFHIRCommunication() throws -> Communication {
        #warning(
            "Version should be updated after 1.1.23 to v1_2_0. More informations: https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc#versionsübergang-31122022--01012023" // swiftlint:disable:this line_length
        )
        guard let communicationDispReq = Workflow.Key.communicationDispReq[.v1_1_1]?.asFHIRCanonicalPrimitive() else {
            throw ErxTaskOrder.Error.unableToConstructCommunicationRequest
        }
        let meta = Meta(profile: [communicationDispReq])
        let reference = Reference(reference: taskIdAndAccessCode.asFHIRStringPrimitive())
        let payloadString = payload.asJsonString().asFHIRStringPrimitive()
        let payload = CommunicationPayload(content: .string(payloadString))
        #warning(
            "Version should be updated after 1.1.23 to v1_2_0. More informations: https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc#versionsübergang-31122022--01012023" // swiftlint:disable:this line_length
        )
        let telematikUri = Workflow.Key.telematikIdKeys[.v1_1_1]?.asFHIRURIPrimitive()
        let identifier = Identifier(system: telematikUri,
                                    value: pharmacyTelematikId.asFHIRStringPrimitive())
        let recipient = Reference(identifier: identifier)
        return Communication(
            basedOn: [reference],
            meta: meta,
            payload: [payload],
            recipient: [recipient],
            status: EventStatus.unknown.asPrimitive()
        )
    }
}

extension ErxTaskOrder.Payload {
    func asJsonString(encoder: JSONEncoder = JSONEncoder()) -> String {
        guard let data = try? encoder.encode(self) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
