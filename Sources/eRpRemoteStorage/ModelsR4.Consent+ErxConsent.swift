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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Consent {
    func parseErxConsent() throws -> ErxConsent? {
        guard let identifier = id?.value?.string else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse id from self.")
        }

        guard let scopeRaw = self.scope.coding?.first(where: { coding in
            coding.system?.value?.url.absoluteString == Terminology.Key.CodeSystem.consentScope
        })?.code?.value?.string,
            let scope = ErxConsent.Scope(rawValue: scopeRaw)
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse scope from self.")
        }

        guard let categoryRaw = self.category.compactMap(\.coding)
            .flatMap({ $0 })
            .first(where: { coding in
                ErpCharge.Key.Consent.consentType.contains {
                    $0.value == coding.system?.value?.url.absoluteString
                }
            })?.code?.value?.string,
            let category = ErxConsent.Category(rawValue: categoryRaw)
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse category from self.")
        }

        guard let insuranceId = patient?.identifier?.value?.value?.string else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse insuranceId from self.")
        }

        guard let timestamp = dateTime?.value?.date.description else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse dateTime from self.")
        }

        guard let policyRuleRaw = self.policyRule?.coding?.first(where: { coding in
            coding.system?.value?.url.absoluteString == Terminology.Key.CodeSystem.actCode
        })?.code?.value?.string,
            let policyRule = ErxConsent.Act(rawValue: policyRuleRaw)
        else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse policyRule from self.")
        }

        return ErxConsent(
            identifier: identifier,
            insuranceId: insuranceId,
            timestamp: timestamp,
            scope: scope,
            category: category,
            policyRule: policyRule
        )
    }
}
