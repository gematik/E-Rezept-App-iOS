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

@testable import eRpFeatures
import eRpKit
import Nimble
import Testing

struct PharmacyLocationViewModelLastUsedFilterTests {
    typealias FilterOption = PharmacySearchFilterDomain.PharmacyFilterOption

    let pharmacies = PharmacyLocationViewModel.Fixtures.pharmacies
    // telematikIDs: A="12345.1", B="12345.2", C="12345.3", D="12345.4", E="12345.5"

    @Test
    func filterByLastUsed_withMatchingIDs_keepsOnlyMatches() {
        let lastUsedIDs: Set = ["12345.1", "12345.3"] // A and C
        let result = pharmacies.filter(by: [.lastUsed], lastUsedIDs: lastUsedIDs)

        expect(result.map(\.pharmacyLocation.telematikID)) == ["12345.1", "12345.3"]
    }

    @Test
    func filterByLastUsed_withNoMatchingIDs_returnsEmpty() {
        let lastUsedIDs: Set = ["99999.0"]
        let result = pharmacies.filter(by: [.lastUsed], lastUsedIDs: lastUsedIDs)

        expect(result).to(beEmpty())
    }

    @Test
    func filterByLastUsed_withEmptyIDs_returnsAll() {
        // Empty lastUsedIDs means IDs haven't been loaded yet — no filtering applied
        let result = pharmacies.filter(by: [.lastUsed], lastUsedIDs: [])

        expect(result) == pharmacies
    }

    @Test
    func filterByLastUsed_withoutOptionActive_ignoresLastUsedIDs() {
        // .lastUsed not in options → lastUsedIDs has no effect
        let lastUsedIDs: Set = ["12345.1"]
        let result = pharmacies.filter(by: [], lastUsedIDs: lastUsedIDs)

        expect(result) == pharmacies
    }
}
