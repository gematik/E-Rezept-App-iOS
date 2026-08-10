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

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import eRpResources
import Pharmacy
import SwiftUI

@Reducer
struct PharmacySearchFilterDomain {
    /// All filter options used with pharmacies search
    enum PharmacyFilterOption: String, CaseIterable, Hashable, Identifiable {
        case open
        case pickup
        case delivery
        case shipment
        case currentLocation
        case lastUsed
        case publicTransport
        case parking
        case barrierFree
        case pickupAutomat
        // Services (specialities)
        case allergyTest
        case organTransplantation
        case polymedication
        case oralCancerTherapy
        case hypertension
        case vaccination
        case inhalationTechnique
        case bodyMeasurements
        case travelMedicineConsultation
        case sterileCompounding

        private static let openIdentifier = UUID()
        private static let pickupIdentifier = UUID()
        private static let deliveryIdentifier = UUID()
        private static let shipmentIdentifier = UUID()
        private static let currentLocationIdentifier = UUID()
        private static let lastUsedIdentifier = UUID()
        private static let publicTransportIdentifier = UUID()
        private static let parkingIdentifier = UUID()
        private static let barrierFreeIdentifier = UUID()
        private static let pickupAutomatIdentifier = UUID()
        private static let allergyTestIdentifier = UUID()
        private static let organTransplantationIdentifier = UUID()
        private static let polymedicationIdentifier = UUID()
        private static let oralCancerTherapyIdentifier = UUID()
        private static let hypertensionIdentifier = UUID()
        private static let vaccinationIdentifier = UUID()
        private static let inhalationTechniqueIdentifier = UUID()
        private static let bodyMeasurementsIdentifier = UUID()
        private static let travelMedicineConsultationIdentifier = UUID()
        private static let sterileCompoundingIdentifier = UUID()

        var id: UUID {
            switch self {
            case .open:
                return Self.openIdentifier
            case .pickup:
                return Self.pickupIdentifier
            case .delivery:
                return Self.deliveryIdentifier
            case .shipment:
                return Self.shipmentIdentifier
            case .currentLocation:
                return Self.currentLocationIdentifier
            case .lastUsed:
                return Self.lastUsedIdentifier
            case .publicTransport:
                return Self.publicTransportIdentifier
            case .parking:
                return Self.parkingIdentifier
            case .barrierFree:
                return Self.barrierFreeIdentifier
            case .pickupAutomat:
                return Self.pickupAutomatIdentifier
            case .allergyTest:
                return Self.allergyTestIdentifier
            case .organTransplantation:
                return Self.organTransplantationIdentifier
            case .polymedication:
                return Self.polymedicationIdentifier
            case .oralCancerTherapy:
                return Self.oralCancerTherapyIdentifier
            case .hypertension:
                return Self.hypertensionIdentifier
            case .vaccination:
                return Self.vaccinationIdentifier
            case .inhalationTechnique:
                return Self.inhalationTechniqueIdentifier
            case .bodyMeasurements:
                return Self.bodyMeasurementsIdentifier
            case .travelMedicineConsultation:
                return Self.travelMedicineConsultationIdentifier
            case .sterileCompounding:
                return Self.sterileCompoundingIdentifier
            }
        }

        var localizedStringKey: LocalizedStringKey {
            switch self {
            case .open:
                return L10n.phaSearchTxtFilterOpen.key
            case .pickup:
                return L10n.psfTxtFilterPickup.key
            case .delivery:
                return L10n.phaSearchTxtFilterDelivery.key
            case .shipment:
                return L10n.phaSearchTxtFilterShipment.key
            case .currentLocation:
                return L10n.phaSearchTxtFilterCurrentLocation.key
            case .lastUsed:
                return L10n.phaSearchTxtFilterLastUsed.key
            case .publicTransport:
                return L10n.phaSearchTxtFilterPublicTransport.key
            case .parking:
                return L10n.phaSearchTxtFilterParking.key
            case .barrierFree:
                return L10n.phaSearchTxtFilterBarrierFree.key
            case .pickupAutomat:
                return L10n.phaSearchTxtFilterPickupAutomat.key
            case .allergyTest:
                return L10n.phaDetailSpecialityAllergyTest.key
            case .organTransplantation:
                return L10n.phaDetailSpecialityOrganTransplantation.key
            case .polymedication:
                return L10n.phaDetailSpecialityPolymedication.key
            case .oralCancerTherapy:
                return L10n.phaDetailSpecialityOralCancerTherapy.key
            case .hypertension:
                return L10n.phaDetailSpecialityHypertension.key
            case .vaccination:
                return L10n.phaDetailSpecialityVaccination.key
            case .inhalationTechnique:
                return L10n.phaDetailSpecialityInhalation.key
            case .bodyMeasurements:
                return L10n.phaDetailSpecialityBodyMeasurements.key
            case .travelMedicineConsultation:
                return L10n.phaDetailSpecialityTravelMedicine.key
            case .sterileCompounding:
                return L10n.phaDetailSpecialitySterileCompounding.key
            }
        }

        /// The cost footnote marker to display after the service title, if any.
        var costFootnote: String? {
            switch self {
            case .organTransplantation, .polymedication, .oralCancerTherapy,
                 .vaccination, .inhalationTechnique, .bodyMeasurements, .sterileCompounding:
                return "*"
            case .hypertension, .travelMedicineConsultation:
                return "**"
            default:
                return nil
            }
        }

        /// The localized description shown when "Erklären" is active. `nil` for non-service filters.
        var localizedDescriptionKey: LocalizedStringKey? {
            switch self {
            case .allergyTest:
                return L10n.psfTxtServiceDescAllergyTest.key
            case .organTransplantation:
                return L10n.psfTxtServiceDescOrganTransplantation.key
            case .polymedication:
                return L10n.psfTxtServiceDescPolymedication.key
            case .oralCancerTherapy:
                return L10n.psfTxtServiceDescOralCancerTherapy.key
            case .hypertension:
                return L10n.psfTxtServiceDescHypertension.key
            case .vaccination:
                return L10n.psfTxtServiceDescVaccination.key
            case .inhalationTechnique:
                return L10n.psfTxtServiceDescInhalation.key
            case .bodyMeasurements:
                return L10n.psfTxtServiceDescBodyMeasurements.key
            case .travelMedicineConsultation:
                return L10n.psfTxtServiceDescTravelMedicine.key
            case .sterileCompounding:
                return L10n.psfTxtServiceDescSterileCompounding.key
            default:
                return nil
            }
        }
    }

    @ObservableState
    struct State: Equatable {
        /// Store for the active filter options the user has chosen
        @Shared(.pharmacyFilterOptions) var pharmacyFilterOptions
        var pharmacyFilterShow: [PharmacyFilterOption] = [
            .currentLocation, .open, .pickup, .delivery, .shipment, .lastUsed,
            .publicTransport, .parking, .barrierFree, .pickupAutomat,
            .allergyTest, .organTransplantation, .polymedication, .oralCancerTherapy,
            .hypertension, .vaccination, .inhalationTechnique, .bodyMeasurements,
            .travelMedicineConsultation, .sterileCompounding,
        ]

        /// Whether the service description texts are expanded
        var showServiceDescriptions = false

        /// Filters belonging to the "Präferenzen" section
        var preferenceFilters: [PharmacyFilterOption] {
            [.open, .currentLocation, .lastUsed]
        }

        /// Filters belonging to the "Einlöseweg" section
        var redeemMethodFilters: [PharmacyFilterOption] {
            [.pickup, .delivery, .shipment]
        }

        /// Filters belonging to the "Vor Ort" section
        var physicalFeatureFilters: [PharmacyFilterOption] {
            [.publicTransport, .parking, .barrierFree, .pickupAutomat]
        }

        /// Filters belonging to the "Services" section
        var serviceFilters: [PharmacyFilterOption] {
            [
                .allergyTest, .organTransplantation, .polymedication, .oralCancerTherapy,
                .hypertension, .vaccination, .inhalationTechnique, .bodyMeasurements,
                .travelMedicineConsultation, .sterileCompounding,
            ]
        }
    }

    enum Action: Equatable {
        case delegate(Delegate)
        case toggleFilter(PharmacyFilterOption)
        case toggleServiceDescriptions
        case resetFilters

        enum Delegate: Equatable {
            case close
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate(.close):
                return .none
            case let .toggleFilter(filterOption):
                if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                    state.$pharmacyFilterOptions.withLock { _ = $0.remove(at: index) }
                } else {
                    state.$pharmacyFilterOptions.withLock { $0.append(filterOption) }
                }
                return .none
            case .toggleServiceDescriptions:
                state.showServiceDescriptions.toggle()
                return .none
            case .resetFilters:
                state.$pharmacyFilterOptions.withLock { $0.removeAll() }
                return .none
            }
        }
    }
}

extension Collection<PharmacySearchFilterDomain.PharmacyFilterOption> {
    var asPharmacyRepositoryFilters: [PharmacyRepositoryFilter] {
        compactMap { option in
            switch option {
            case .pickup:
                return .pickup
            case .shipment:
                return .shipment
            case .delivery:
                return .delivery
            case .publicTransport:
                return .characteristic(.publicTransport)
            case .parking:
                return .characteristic(.parking)
            case .barrierFree:
                return .characteristic(.barrierFree)
            case .pickupAutomat:
                return .characteristic(.pickupAutomat)
            case .allergyTest:
                return .specialty(.allergyTest)
            case .organTransplantation:
                return .specialty(.organTransplantation)
            case .polymedication:
                return .specialty(.polymedication)
            case .oralCancerTherapy:
                return .specialty(.oralCancerTherapy)
            case .hypertension:
                return .specialty(.hypertension)
            case .vaccination:
                return .specialty(.vaccination)
            case .inhalationTechnique:
                return .specialty(.inhalationTechnique)
            case .bodyMeasurements:
                return .specialty(.bodyMeasurements)
            case .travelMedicineConsultation:
                return .specialty(.travelMedicineConsultation)
            case .sterileCompounding:
                return .specialty(.sterileCompounding)
            case .open,
                 .currentLocation,
                 .lastUsed:
                return nil
            }
        }
    }
}

extension PharmacySearchFilterDomain {
    enum Dummies {
        static let state = State(
            pharmacyFilterOptions: Shared(value: [.open, .delivery, .parking])
        )

        static let store = Store(
            initialState: state
        ) {
            PharmacySearchFilterDomain()
        }
    }
}

// MARK: - Client-side filtering helpers

extension [PharmacyLocationViewModel] {
    func filter(
        by filterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption],
        lastUsedIDs: Set<String> = []
    ) -> [PharmacyLocationViewModel] {
        var result = self
        // Filter pharmacies that are closed
        if filterOptions.contains(.open) {
            result = result.filter(\.todayOpeningState.isOpen)
        }
        // Filter down to pharmacies that have been used before (client-side only)
        if filterOptions.contains(.lastUsed), !lastUsedIDs.isEmpty {
            result = result.filter { lastUsedIDs.contains($0.pharmacyLocation.telematikID) }
        }
        return result
    }
}
