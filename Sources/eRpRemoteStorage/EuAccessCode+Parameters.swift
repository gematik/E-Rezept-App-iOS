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

extension EuAccessCode {
    func asParametersResource(
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }()
    ) throws -> Data {
        let parameters = try createFHIRParameters()
        return try encoder.encode(parameters)
    }

    private func createFHIRParameters() throws -> Parameters {
        guard let profile = EURedeem.Key.authorizationRequest[.v1_1_1]?
            .asFHIRCanonicalPrimitive(for: "1.1") else {
            throw EuAccessCode.Error.unableToConstructEuAccessCodeRequest
        }

        var parameterItems: [ParametersParameter] = []

        if let countryCode {
            let coding = Coding(
                code: countryCode.uppercased().asFHIRStringPrimitive(),
                system: EURedeem.Key.EuAccessCodeRequest.countryCodeSchemeKey.asFHIRURIPrimitive()
            )
            parameterItems.append(
                ParametersParameter(
                    name: EURedeem.Key.EuAccessCodeRequest.countryCodeKey.asFHIRStringPrimitive(),
                    value: .coding(coding)
                )
            )
        }

        if let accessCode {
            let identifier = Identifier(
                system: EURedeem.Key.EuAccessCodeRequest.euAccessCodeKeys[.v1_1_1]?.asFHIRURIPrimitive(),
                value: accessCode.asFHIRStringPrimitive()
            )
            parameterItems.append(
                ParametersParameter(
                    name: EURedeem.Key.EuAccessCodeRequest.accessCodeKey.asFHIRStringPrimitive(),
                    value: .identifier(identifier)
                )
            )
        }

        return Parameters(id: EURedeem.Key.euAccessCodeRequest[.v1_1_1]?.asFHIRStringPrimitive(),
                          meta: Meta(profile: [profile]),
                          parameter: parameterItems)
    }
}
