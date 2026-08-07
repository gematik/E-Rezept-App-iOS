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

import CoreData
import eRpKit

extension ErxTaskTeratogenicInfoEntity {
    convenience init?(teratogenicInfo: TeratogenicRelatedInformation?,
                      in context: NSManagedObjectContext) {
        guard let teratogenicInfo else { return nil }

        self.init(context: context)

        offLabelUse = teratogenicInfo.offLabelUse
        womanOfChildbearingAge = teratogenicInfo.womanOfChildbearingAge
        safetyMeasuresCompliance = teratogenicInfo.safetyMeasuresCompliance
        informationMaterialProvided = teratogenicInfo.informationMaterialProvided
        expertKnowledgeDeclaration = teratogenicInfo.expertKnowledgeDeclaration
    }
}

extension TeratogenicRelatedInformation {
    init?(entity: ErxTaskTeratogenicInfoEntity?) {
        guard let entity else { return nil }

        self.init(
            offLabelUse: entity.offLabelUse,
            womanOfChildbearingAge: entity.womanOfChildbearingAge,
            safetyMeasuresCompliance: entity.safetyMeasuresCompliance,
            informationMaterialProvided: entity.informationMaterialProvided,
            expertKnowledgeDeclaration: entity.expertKnowledgeDeclaration
        )
    }
}
