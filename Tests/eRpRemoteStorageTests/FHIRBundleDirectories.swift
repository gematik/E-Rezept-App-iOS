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

enum FHIRBundleDirectories: String, Equatable {
    case gem_erpChrg_v1_0_0 = "FHIR_GEM_ERPCHRG_v_1_0_0"
    case kbv_v1_0_2 = "FHIR_KBV_v1_0_2"
    case kbv_v1_1_0 = "FHIR_KBV_v1_1_0"
    case gem_wf_v1_1_with_kbv_v1_0_2 = "FHIR_GEM_Workflow_v1_1_with_KBV_v1_0_2"
    case gem_wf_v1_2_with_kbv_v1_1_0 = "FHIR_GEM_Workflow_v1_2_with_KBV_v1_1_0"
    case gem_wf_v1_3 = "FHIR_GEM_Workflow_v1_3"
    case gem_wf_v1_4 = "FHIR_GEM_Workflow_v1_4"
}
