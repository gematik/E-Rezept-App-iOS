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
import CombineSchedulers
import eRpKit
import eRpLocalStorage
import FeatureHelpers
import FHIRVZD
import Foundation
import IdentifiedCollections
import OpenSSL
import Pharmacy

extension PharmacyRepository {
    // swiftlint:disable:next function_body_length
    static func dummyPharmacyRepository(
        cloud: HealthcareServiceFHIRDataSource,
    ) -> PharmacyRepository {
        let store = PharmacyStore()
        return PharmacyRepository(
            updateFromRemote: { telematikId in
                let remotePharmacy = try await cloud.fetchPharmacy(by: telematikId).async()
                guard let pharmacy = remotePharmacy else {
                    throw PharmacyRepositoryError.remote(.notFound)
                }
                let storedPharmacy = await store.first { $0.telematikID == telematikId }
                guard var storedPharmacy = storedPharmacy else {
                    throw PharmacyRepositoryError
                        .local(.read(error: PharmacyCoreDataStore.Error.noMatchingEntity))
                }
                storedPharmacy.telecom = pharmacy.telecom
                storedPharmacy.address = pharmacy.address
                storedPharmacy.types = pharmacy.types
                storedPharmacy.position = pharmacy.position
                storedPharmacy.hoursOfOperation = pharmacy.hoursOfOperation
                await store.updateOrAppend(storedPharmacy)
                return storedPharmacy
            },
            loadCached: { telematikId in
                if let result = await store.first(where: { $0.telematikID == telematikId }) {
                    return result
                } else {
                    return nil
                }
            },
            searchRemote: { searchTerm, position, filter in
                let pharmacies = try await cloud.searchPharmacies(
                    by: searchTerm,
                    position: position,
                    filter: cloud.apiFilters(for: filter)
                )
                .async()
                if filter.contains(.delivery) {
                    return pharmacies.filter(\.hasDeliveryService)
                }
                return pharmacies
            },
            loadLocalById: { telematikId in
                if let result = await store.first(where: { $0.telematikID == telematikId }) {
                    return result
                } else {
                    return nil
                }
            },
            loadLocalCount: { _ in
                await store.allSorted()
            },
            saveMultiple: { pharmacies in
                for pharmacy in pharmacies {
                    await store.updateOrAppend(pharmacy)
                }
                return true
            },
            deleteMultiple: { pharmacies in
                for pharmacy in pharmacies {
                    await store.remove(id: pharmacy.id)
                }
                return true
            },
            fetchInsurance: { _ in nil },
            fetchAllInsurances: { [] },
            fetchEuCountries: { [] }
        )
    }

    actor PharmacyStore {
        private var store = IdentifiedArrayOf<PharmacyLocation>()

        func first(where predicate: (PharmacyLocation) -> Bool) -> PharmacyLocation? {
            store.first(where: predicate)
        }

        func updateOrAppend(_ pharmacy: PharmacyLocation) {
            store.updateOrAppend(pharmacy)
        }

        func remove(id: PharmacyLocation.ID) {
            store.remove(id: id)
        }

        func allSorted() -> [PharmacyLocation] {
            store.sorted {
                $0.isFavorite && !$1.isFavorite && ($0.name ?? "") > ($1.name ?? "")
            }
        }
    }
}
