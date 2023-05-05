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

extension ErxConsent {
    func asConsentResource(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        let consent = try createFHIRConsent()
        return try encoder.encode(consent)
    }

    private func createFHIRConsent() throws -> Consent {
        guard let chargeConsent = ErpCharge.Key.Consent.consent[.v1_0_0]?.asFHIRCanonicalPrimitive() else {
            throw ErxConsent.Error.unableToConstructConsentRequest
        }
        let meta = Meta(profile: [chargeConsent])

        guard let dateTime = try? DateTime(timestamp).asPrimitive() else {
            throw ErxConsent.Error.unableToConstructConsentRequest
        }

        let categoryUri = ErpCharge.Key.Consent.consentType[.v1_0_0]?.asFHIRURIPrimitive()
        let category = CodeableConcept(coding: [
            Coding(
                code: category.rawValue.asFHIRStringPrimitive(),
                system: categoryUri
            ),
        ])

        let patientUri = Workflow.Key.kvIDKeys[.v1_1_1]?.asFHIRURIPrimitive()
        let patient = Identifier(
            system: patientUri,
            value: insuranceId.asFHIRStringPrimitive()
        )
        let patientRef = Reference(identifier: patient)

        let policyRule = CodeableConcept(coding: [
            Coding(
                code: policyRule.rawValue.asFHIRStringPrimitive(),
                system: Terminology.Key.CodeSystem.actCode.asFHIRURIPrimitive()
            ),
        ])

        let scope = CodeableConcept(coding: [
            Coding(
                code: scope.rawValue.asFHIRStringPrimitive(),
                system: Terminology.Key.CodeSystem.consentScope.asFHIRURIPrimitive()
            ),
        ])

        return Consent(
            category: [category],
            dateTime: dateTime,
            id: identifier.asFHIRStringPrimitive(),
            meta: meta,
            patient: patientRef,
            policyRule: policyRule,
            scope: scope,
            status: ConsentState.active.asPrimitive()
        )
    }
}
