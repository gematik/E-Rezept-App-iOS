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

import BundleKit
import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import XCTest

// FHIR GEM ERPCHRG tests for consents in Version 1.0.0
final class FHIR_GEM_ERPCHRG_v_1_0_0_ConsentTests: XCTestCase {
    func testParsingConsent_ChargCons() throws {
        guard let consent = try decode(resource: "GEM_ERPCHRG_PR_Consent.json")
        else {
            XCTFail("Failed to parse Consent to ErxConsent")
            return
        }

        expect(consent.identifier) == "CHARGCONS-X764228532"
        expect(consent.insuranceId) == "X764228532"
        expect(consent.timestamp) == "2023-02-15"
        expect(consent.scope) == .patientPrivacy
        expect(consent.category) == .chargcons
        expect(consent.policyRule) == .optIn
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_erpChrg_v1_0_0
    ) throws -> ErxConsent? {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle.rawValue)
            .decode(ModelsR4.Consent.self, from: file)
            .parseErxConsent()
    }
}
