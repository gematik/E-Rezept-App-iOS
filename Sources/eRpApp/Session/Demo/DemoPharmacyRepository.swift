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

import Combine
import CombineSchedulers
import eRpKit
import eRpLocalStorage
import Foundation
import IdentifiedCollections
import Pharmacy

class DemoPharmacyRepository: PharmacyRepository {
    private let delay: Double
    private let cloud: PharmacyFHIRDataSource
    private let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    private var store = IdentifiedArrayOf<PharmacyLocation>()

    init(cloud: PharmacyFHIRDataSource,
         requestDelayInSeconds: Double = 0.1,
         schedulers: Schedulers = Schedulers()) {
        self.cloud = cloud
        delay = requestDelayInSeconds
        self.schedulers = schedulers
    }

    func updateFromRemote(by telematikId: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        cloud.fetchPharmacy(by: telematikId)
            .mapError(PharmacyRepositoryError.remote)
            .flatMap { pharmacy -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> in
                guard let pharmacy = pharmacy else {
                    return Fail(error: PharmacyRepositoryError.remote(.notFound)).eraseToAnyPublisher()
                }
                let storedPharmacy = self.store.first { $0.telematikID == telematikId }
                guard var storedPharmacy = storedPharmacy else {
                    return Fail(error: PharmacyRepositoryError
                        .local(.read(error: PharmacyCoreDataStore.Error.noMatchingEntity))).eraseToAnyPublisher()
                }
                storedPharmacy.telecom = pharmacy.telecom
                storedPharmacy.address = pharmacy.address
                storedPharmacy.types = pharmacy.types
                storedPharmacy.position = pharmacy.position
                storedPharmacy.hoursOfOperation = pharmacy.hoursOfOperation
                self.store.updateOrAppend(storedPharmacy)
                return Just(storedPharmacy)
                    .setFailureType(to: PharmacyRepositoryError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func loadCached(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        loadLocal(by: telematikId)
    }

    func searchRemote(searchTerm: String, position: Position?,
                      filter: [PharmacyRepositoryFilter]) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        cloud.searchPharmacies(by: searchTerm, position: position, filter: filter.asAPIFilter())
            .map { pharmacies in
                if filter.contains(.delivery) {
                    return pharmacies.filter(\.hasDeliveryService)
                }
                return pharmacies
            }
            .mapError(PharmacyRepositoryError.remote)
            .eraseToAnyPublisher()
    }

    func loadLocal(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        if let result = store.first(where: { $0.telematikID == telematikId }) {
            return Just(result).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        } else {
            return Empty().setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        }
    }

    func loadLocal(count _: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        Just(
            store.sorted {
                $0.isFavorite && !$1.isFavorite
                    && ($0.name ?? "") > ($1.name ?? "")
            }
        )
        .setFailureType(to: PharmacyRepositoryError.self)
        .first()
        .eraseToAnyPublisher()
    }

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        pharmacies.forEach { pharmacy in
            store[id: pharmacy.id] = pharmacy
        }
        return Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        pharmacies.forEach { pharmacy in
            store.remove(id: pharmacy.id)
        }
        return Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }
}

struct DummyPharmacyRepository: PharmacyRepository {
    func updateFromRemote(by _: String) -> AnyPublisher<PharmacyLocation, Pharmacy.PharmacyRepositoryError> {
        Just(
            PharmacyLocation(
                id: "",
                status: .active,
                telematikID: "dummy_id",
                name: "Test-Apo",
                types: [.outpharm],
                hoursOfOperation: []
            )
        )
        .setFailureType(to: PharmacyRepositoryError.self)
        .eraseToAnyPublisher()
    }

    func save(pharmacies _: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func loadCached(by _: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        Just(nil).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func searchRemote(
        searchTerm _: String,
        position _: Position?,
        filter _: [PharmacyRepositoryFilter]
    ) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        Just([]).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocal(by _: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        Just(nil).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocal(count _: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        Just([]).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func updateLocal(
        for _: String,
        mutating _: @escaping (inout PharmacyLocation) -> Void
    ) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        Just(
            PharmacyLocation(
                id: "",
                status: .active,
                telematikID: "dummy_id",
                name: "Test-Apo",
                types: [.outpharm],
                hoursOfOperation: []
            )
        )
        .setFailureType(to: PharmacyRepositoryError.self)
        .eraseToAnyPublisher()
    }

    func delete(pharmacies _: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }
}
