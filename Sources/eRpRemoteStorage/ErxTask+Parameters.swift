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

extension ErxTask {
    static func fhirParameterEURedeem(
        byPatientAuthorization: Bool,
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }()
    ) throws -> Data {
        let parameters = try createFHIRParameterEURedeem(byPatientAuthorization: byPatientAuthorization)
        return try encoder.encode(parameters)
    }

    private static func createFHIRParameterEURedeem(byPatientAuthorization: Bool) throws -> ModelsR4.Parameters {
        guard let taskInputPatch = EURedeem.Key.Task.taskInputPatch[.v1_1_1]?
            .asFHIRCanonicalPrimitive(for: "1.1") else {
            throw ErxTask.Error.unableToConstructInputPatch
        }
        let id = FHIRPrimitive(FHIRString("erp-eprescription-10-PATCH-Task-Request"))
        let meta = Meta(profile: [taskInputPatch])
        let parameter = ParametersParameter(
            name: "eu-isRedeemableByPatientAuthorization",
            value: ParametersParameter.ValueX.boolean(FHIRPrimitive(FHIRBool(byPatientAuthorization)))
        )

        return Parameters(id: id, meta: meta, parameter: [parameter])
    }
}
