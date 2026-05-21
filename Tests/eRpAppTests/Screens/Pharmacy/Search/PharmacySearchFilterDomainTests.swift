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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import Pharmacy
import Testing

// MARK: - asPharmacyRepositoryFilters

struct PharmacyFilterOptionRepositoryFilterMappingTests {
    typealias FilterOption = PharmacySearchFilterDomain.PharmacyFilterOption

    @Test
    func emptyOptionsProduceNoFilters() {
        let options: [FilterOption] = []
        expect(options.asPharmacyRepositoryFilters).to(beEmpty())
    }

    @Test
    func openAndCurrentLocationAreDropped() {
        let options: [FilterOption] = [.open, .currentLocation]
        expect(options.asPharmacyRepositoryFilters).to(beEmpty())
    }

    @Test
    func pickupMapsToPickup() {
        let options: [FilterOption] = [.pickup]
        expect(options.asPharmacyRepositoryFilters) == [.pickup]
    }

    @Test
    func lastUsedIsDropped() {
        let options: [FilterOption] = [.lastUsed]
        expect(options.asPharmacyRepositoryFilters).to(beEmpty())
    }

    @Test
    func lastUsedIsDroppedFromMixedOptions() {
        let options: [FilterOption] = [.lastUsed, .delivery, .shipment]
        expect(options.asPharmacyRepositoryFilters) == [.delivery, .shipment]
    }

    @Test
    func shipmentMapsToShipment() {
        let options: [FilterOption] = [.shipment]
        expect(options.asPharmacyRepositoryFilters) == [.shipment]
    }

    @Test
    func deliveryMapsToDelivery() {
        let options: [FilterOption] = [.delivery]
        expect(options.asPharmacyRepositoryFilters) == [.delivery]
    }

    @Test
    func physicalFeaturesMapsToCharacteristic() {
        let options: [FilterOption] = [.publicTransport, .parking, .barrierFree, .pickupAutomat]
        let result = options.asPharmacyRepositoryFilters
        expect(result) == [
            .characteristic(.publicTransport),
            .characteristic(.parking),
            .characteristic(.barrierFree),
            .characteristic(.pickupAutomat),
        ]
    }

    @Test
    func mixedOptionsPreservesOrder() {
        let options: [FilterOption] = [.open, .delivery, .parking, .currentLocation, .shipment, .barrierFree]
        let result = options.asPharmacyRepositoryFilters
        expect(result) == [
            .delivery,
            .characteristic(.parking),
            .shipment,
            .characteristic(.barrierFree),
        ]
    }

    @Test
    func serviceFiltersMapsToSpecialty() {
        let options: [FilterOption] = [
            .allergyTest, .organTransplantation, .polymedication, .oralCancerTherapy,
            .hypertension, .vaccination, .inhalationTechnique, .bodyMeasurements,
            .travelMedicineConsultation, .sterileCompounding,
        ]
        let result = options.asPharmacyRepositoryFilters
        expect(result) == [
            .specialty(.allergyTest),
            .specialty(.organTransplantation),
            .specialty(.polymedication),
            .specialty(.oralCancerTherapy),
            .specialty(.hypertension),
            .specialty(.vaccination),
            .specialty(.inhalationTechnique),
            .specialty(.bodyMeasurements),
            .specialty(.travelMedicineConsultation),
            .specialty(.sterileCompounding),
        ]
    }

    @Test
    func mixedOptionsIncludingServicesPreservesOrder() {
        let options: [FilterOption] = [.open, .delivery, .vaccination, .parking, .allergyTest, .currentLocation]
        let result = options.asPharmacyRepositoryFilters
        expect(result) == [
            .delivery,
            .specialty(.vaccination),
            .characteristic(.parking),
            .specialty(.allergyTest),
        ]
    }
}

// MARK: - costFootnote

struct PharmacyFilterOptionCostFootnoteTests {
    typealias FilterOption = PharmacySearchFilterDomain.PharmacyFilterOption

    @Test
    func singleAsteriskForStatutoryInsuranceCoveredServices() {
        let singleAsterisk: [FilterOption] = [
            .organTransplantation, .polymedication, .oralCancerTherapy,
            .vaccination, .inhalationTechnique, .bodyMeasurements, .sterileCompounding,
        ]
        for option in singleAsterisk {
            expect(option.costFootnote) == "*"
        }
    }

    @Test
    func doubleAsteriskForAllInsuranceCoveredServices() {
        let doubleAsterisk: [FilterOption] = [.hypertension, .travelMedicineConsultation]
        for option in doubleAsterisk {
            expect(option.costFootnote) == "**"
        }
    }

    @Test
    func noCostFootnoteForAllergyTest() {
        expect(FilterOption.allergyTest.costFootnote).to(beNil())
    }

    @Test
    func noCostFootnoteForNonServiceFilters() {
        let nonService: [FilterOption] = [.open, .pickup, .delivery, .shipment, .currentLocation,
                                          .publicTransport, .parking, .barrierFree, .pickupAutomat]
        for option in nonService {
            expect(option.costFootnote).to(beNil())
        }
    }
}

// MARK: - localizedDescriptionKey

struct PharmacyFilterOptionDescriptionKeyTests {
    typealias FilterOption = PharmacySearchFilterDomain.PharmacyFilterOption

    @Test
    func allServiceFiltersHaveDescriptionKeys() {
        let services: [FilterOption] = [
            .allergyTest, .organTransplantation, .polymedication, .oralCancerTherapy,
            .hypertension, .vaccination, .inhalationTechnique, .bodyMeasurements,
            .travelMedicineConsultation, .sterileCompounding,
        ]
        for option in services {
            expect(option.localizedDescriptionKey).toNot(beNil())
        }
    }

    @Test
    func nonServiceFiltersHaveNoDescriptionKey() {
        let nonService: [FilterOption] = [.open, .pickup, .delivery, .shipment, .currentLocation,
                                          .publicTransport, .parking, .barrierFree, .pickupAutomat]
        for option in nonService {
            expect(option.localizedDescriptionKey).to(beNil())
        }
    }
}

// MARK: - State computed filter groups

struct PharmacySearchFilterDomainStateGroupTests {
    @Test
    func serviceFiltersContainsAllTenServices() {
        let state = PharmacySearchFilterDomain.State(
            pharmacyFilterOptions: Shared(value: [])
        )
        expect(state.serviceFilters) == [
            .allergyTest, .organTransplantation, .polymedication, .oralCancerTherapy,
            .hypertension, .vaccination, .inhalationTechnique, .bodyMeasurements,
            .travelMedicineConsultation, .sterileCompounding,
        ]
    }

    @Test
    func redeemMethodFiltersContainsPickupDeliveryShipment() {
        let state = PharmacySearchFilterDomain.State(
            pharmacyFilterOptions: Shared(value: [])
        )
        expect(state.redeemMethodFilters) == [.pickup, .delivery, .shipment]
    }

    @Test
    func physicalFeatureFiltersContainsFourOptions() {
        let state = PharmacySearchFilterDomain.State(
            pharmacyFilterOptions: Shared(value: [])
        )
        expect(state.physicalFeatureFilters) == [.publicTransport, .parking, .barrierFree, .pickupAutomat]
    }
}

// MARK: - PharmacySearchFilterDomain Reducer

struct PharmacySearchFilterDomainTests {
    typealias FilterOption = PharmacySearchFilterDomain.PharmacyFilterOption

    @Test
    @MainActor
    func toggleFilterAddsOption() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [])
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.toggleFilter(.parking)) {
            $0.$pharmacyFilterOptions.withLock { $0 = [.parking] }
        }
    }

    @Test
    @MainActor
    func toggleFilterRemovesExistingOption() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [.delivery, .parking])
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.toggleFilter(.parking)) {
            $0.$pharmacyFilterOptions.withLock { $0 = [.delivery] }
        }
    }

    @Test
    @MainActor
    func resetFiltersClearsAll() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [.open, .delivery, .parking, .barrierFree])
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.resetFilters) {
            $0.$pharmacyFilterOptions.withLock { $0 = [] }
        }
    }

    @Test
    @MainActor
    func toggleServiceFilterAddsAndRemoves() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [])
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.toggleFilter(.vaccination)) {
            $0.$pharmacyFilterOptions.withLock { $0 = [.vaccination] }
        }

        await store.send(.toggleFilter(.allergyTest)) {
            $0.$pharmacyFilterOptions.withLock { $0 = [.vaccination, .allergyTest] }
        }

        await store.send(.toggleFilter(.vaccination)) {
            $0.$pharmacyFilterOptions.withLock { $0 = [.allergyTest] }
        }
    }

    @Test
    @MainActor
    func toggleServiceDescriptionsTogglesState() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [])
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.toggleServiceDescriptions) {
            $0.showServiceDescriptions = true
        }

        await store.send(.toggleServiceDescriptions) {
            $0.showServiceDescriptions = false
        }
    }

    @Test
    @MainActor
    func resetFiltersClearsServiceSelectionsAndDescriptions() async {
        let store = TestStore(
            initialState: PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: Shared(value: [.vaccination, .allergyTest, .delivery]),
                showServiceDescriptions: true
            )
        ) {
            PharmacySearchFilterDomain()
        }

        await store.send(.resetFilters) {
            $0.$pharmacyFilterOptions.withLock { $0 = [] }
        }
        // Note: showServiceDescriptions is NOT reset by resetFilters — it's a UI toggle, not a filter
    }
}

// MARK: - filter(by:) local filtering

struct PharmacyFilterByTests {
    let pharmacies = PharmacyLocationViewModel.Fixtures.pharmacies

    @Test
    func filterByOpen_keepsOnlyOpenPharmacies() {
        let result = pharmacies.filter(by: [.open])
        for pharmacy in result {
            expect(pharmacy.todayOpeningState.isOpen).to(beTrue())
        }
    }

    @Test
    func filterByLastUsed_keepsOnlyMatchingIDs() {
        // filter(by:) matches on telematikID, not on PharmacyLocation.id
        let ids: Set = ["12345.1"]
        let result = pharmacies.filter(by: [.lastUsed], lastUsedIDs: ids)
        expect(result.map(\.pharmacyLocation.telematikID)) == ["12345.1"]
    }

    @Test
    func filterByCharacteristic_doesNotFilterLocally() {
        // Characteristics are handled server-side - local filter(by:) ignores them
        let result = pharmacies.filter(by: [.parking])
        expect(result) == pharmacies
    }

    @Test
    func filterBySpecialty_doesNotFilterLocally() {
        // Specialties are handled server-side - local filter(by:) ignores them
        let result = pharmacies.filter(by: [.vaccination])
        expect(result) == pharmacies
    }

    @Test
    func filterByNonFilterableOptions_returnsAll() {
        let result = pharmacies.filter(by: [.delivery, .shipment, .pickup])
        expect(result) == pharmacies
    }
}
