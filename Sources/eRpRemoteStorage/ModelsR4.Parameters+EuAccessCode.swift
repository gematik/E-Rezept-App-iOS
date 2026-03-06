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

extension ModelsR4.Parameters {
    /// Parse and extract a EuAccessCode from `Self`
    ///
    /// - Returns: A EuAccessCode
    /// - Throws: `ModelsR4.Bundle.Error`
    func parse() throws -> EuAccessCode? {
        guard let parameters = parameter else {
            throw RemoteStorageBundleParsingError
                .parseError("Could not parse the ParametersParameter from Parameters resource")
        }

        func value(for name: String) -> ParametersParameter? {
            parameters.first { $0.name == name.asFHIRStringPrimitive() }
        }

        let countryCode: String? = {
            if case let .coding(codeX) = value(for: "countryCode")?.value,
               let countryCode = codeX.code?.value?.string {
                return countryCode
            }
            return nil
        }()

        let euAccessCode: String? = {
            if case let .identifier(identX) = value(for: "accessCode")?.value,
               let euAccessCode = identX.value?.value?.string {
                return euAccessCode
            }
            return nil
        }()

        let validUntil: Date? = try {
            if case let .instant(instantX) = value(for: "validUntil")?.value,
               let validUntil = try instantX.value?.asNSDate() {
                return validUntil
            }
            return nil
        }()

        let createdAt: Date? = try {
            if case let .instant(instantX) = value(for: "createdAt")?.value,
               let createdAt = try instantX.value?.asNSDate() {
                return createdAt
            }
            return nil
        }()

        return .init(
            accessCode: euAccessCode,
            countryCode: countryCode,
            validUntil: validUntil,
            createdAt: createdAt
        )
    }
}
