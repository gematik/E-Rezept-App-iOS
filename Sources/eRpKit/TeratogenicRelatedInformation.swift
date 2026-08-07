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

import Foundation

/// Information related to teratogenic medication (medication that can cause birth defects).
/// Corresponds to the FHIR extension `KBV_EX_ERP_Teratogenic`.
public struct TeratogenicRelatedInformation: Hashable, Codable, Sendable {
    public init(
        offLabelUse: Bool = false,
        womanOfChildbearingAge: Bool = false,
        safetyMeasuresCompliance: Bool = false,
        informationMaterialProvided: Bool = false,
        expertKnowledgeDeclaration: Bool = false
    ) {
        self.offLabelUse = offLabelUse
        self.womanOfChildbearingAge = womanOfChildbearingAge
        self.safetyMeasuresCompliance = safetyMeasuresCompliance
        self.informationMaterialProvided = informationMaterialProvided
        self.expertKnowledgeDeclaration = expertKnowledgeDeclaration
    }

    /// Whether the medication is prescribed for off-label use (Off-Label)
    public let offLabelUse: Bool
    /// Whether the patient is a woman of childbearing age (Gebärfähige Frau)
    public let womanOfChildbearingAge: Bool
    /// Whether safety measures are being complied with (Einhaltung Sicherheitsmaßnahmen)
    public let safetyMeasuresCompliance: Bool
    /// Whether information materials have been provided to the patient (Aushändigung Informationsmaterialien)
    public let informationMaterialProvided: Bool
    /// Whether the prescriber has declared expert knowledge about the teratogenic risk (Erklärung Sachkenntnis)
    public let expertKnowledgeDeclaration: Bool
}
