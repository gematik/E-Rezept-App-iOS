//
//  Copyright (c) 2024 gematik GmbH
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

import Foundation

enum FHIRBundleDirectories: String, Equatable {
    case gem_erpChrg_v1_0_0 = "FHIR_GEM_ERPCHRG_v_1_0_0.bundle"
    case kbv_v1_0_2 = "FHIR_KBV_v1_0_2.bundle"
    case kbv_v1_1_0 = "FHIR_KBV_v1_1_0.bundle"
    case gem_wf_v1_1_with_kbv_v1_0_2 = "FHIR_GEM_Workflow_v1_1_with_KBV_v1_0_2.bundle"
    case gem_wf_v1_2_with_kbv_v1_1_0 = "FHIR_GEM_Workflow_v1_2_with_KBV_v1_1_0.bundle"
}
