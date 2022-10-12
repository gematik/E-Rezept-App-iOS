//
//  Copyright (c) 2022 gematik GmbH
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
import Foundation
import Pharmacy

class DemoPharmacyRepository: PharmacyRepository {
    private let delay: Double
    private let currentValue: CurrentValueSubject<[PharmacyLocation], PharmacyRepositoryError> = CurrentValueSubject([])
    private let cloud: PharmacyFHIRDataSource
    private let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    private lazy var store: Set<PharmacyLocation> = {
        Set(PharmacyLocation.Dummies.pharmacies)
    }()

    init(cloud: PharmacyFHIRDataSource,
         requestDelayInSeconds: Double = 0.1,
         schedulers: Schedulers = Schedulers()) {
        self.cloud = cloud
        delay = requestDelayInSeconds
        self.schedulers = schedulers
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

    func loadLocalAll() -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        currentValue
            .first()
            .delay(for: .seconds(delay), scheduler: uiScheduler)
            .eraseToAnyPublisher()
    }

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        pharmacies.forEach { pharmacy in
            if store.contains(pharmacy) {
                store.update(with: pharmacy)
            }
        }
        return Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        store.formUnion(Set(pharmacies))
        return Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }
}
