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
import eRpKit
import Foundation

/// Repository for the app to the Pharmacy data layer handling the syncing between its data stores.
public struct DefaultPharmacyRepository: PharmacyRepository {
    private let disk: PharmacyLocalDataStore
    private let cloud: PharmacyRemoteDataStore

    /// Initializes a new PharmacyRepository as the gateway between Presentation layer and underlying data layer(s)
    ///
    /// - Parameters:
    ///   - disk: The data source that represents the disk/local storage
    ///   - cloud: The data source that represents the cloud/remote storage
    public init(
        disk: PharmacyLocalDataStore,
        cloud: PharmacyRemoteDataStore
    ) {
        self.disk = disk
        self.cloud = cloud
    }

    public func updateFromRemote(by telematikId: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        cloud.fetchPharmacy(by: telematikId)
            .mapError(PharmacyRepositoryError.remote)
            .flatMap { pharmacy -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> in
                guard let remotePharmacy = pharmacy else {
                    return Fail(error: PharmacyRepositoryError.remote(.notFound)).eraseToAnyPublisher()
                }
                return disk.update(telematikId: telematikId) { pharmacyInStore in
                    // update only data that comes from remote and stored localy
                    pharmacyInStore.name = remotePharmacy.name
                    pharmacyInStore.telecom = remotePharmacy.telecom
                    pharmacyInStore.position = remotePharmacy.position
                    pharmacyInStore.address = remotePharmacy.address

                    pharmacyInStore.id = remotePharmacy.id
                }
                .map { pharmacyInStore in
                    // return a pharmacy with the stored data and the remote data
                    var updatedPharmacy = pharmacyInStore
                    updatedPharmacy.types = remotePharmacy.types
                    updatedPharmacy.status = remotePharmacy.status
                    updatedPharmacy.hoursOfOperation = remotePharmacy.hoursOfOperation
                    updatedPharmacy.avsEndpoints = remotePharmacy.avsEndpoints
                    updatedPharmacy.avsCertificates = remotePharmacy.avsCertificates
                    return updatedPharmacy
                }
                .mapError(PharmacyRepositoryError.local)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func loadCached(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        disk.fetchPharmacy(by: telematikId)
            .first()
            .mapError(PharmacyRepositoryError.local)
            .flatMap { result -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> in
                if let pharmacy = result {
                    return Just(pharmacy)
                        .setFailureType(to: PharmacyRepositoryError.self)
                        .eraseToAnyPublisher()
                } else {
                    return cloud.fetchPharmacy(by: telematikId)
                        .mapError(PharmacyRepositoryError.remote)
                        .flatMap { pharmacy -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> in
                            guard let pharmacy = pharmacy else {
                                return Just(nil)
                                    .setFailureType(to: PharmacyRepositoryError.self)
                                    .eraseToAnyPublisher()
                            }
                            return self.disk.save(pharmacies: [pharmacy])
                                .map { _ in pharmacy }
                                .mapError(PharmacyRepositoryError.local)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public func searchRemote(searchTerm: String, position: Position?,
                             filter: [PharmacyRepositoryFilter]) -> AnyPublisher<
        [PharmacyLocation],
        PharmacyRepositoryError
    > {
        cloud.searchPharmacies(by: searchTerm, position: position, filter: filter.asAPIFilter())
            .mapError(PharmacyRepositoryError.remote)
            .flatMap { remotePharmacies in
                disk.listPharmacies(count: nil) // AnyPublisher<[PharmacyLocation], LocalStoreError>
                    .map { [remotePharmacies] localPharmacies in
                        remotePharmacies.map { pharmacy in
                            var remotePharmacy = pharmacy
                            if let localPharmacy = localPharmacies
                                .first(where: { $0.telematikID == pharmacy.telematikID }) {
                                remotePharmacy.updateLocalStoredProperties(with: localPharmacy)
                            }
                            return remotePharmacy
                        }
                    }
                    .map { pharmacies in
                        if filter.contains(.delivery) {
                            // server filtering is not supported for delivery, hence do it manually until available
                            return pharmacies.filter(\.hasDeliveryService)
                        }
                        return pharmacies
                    }
                    .mapError(PharmacyRepositoryError.local)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func loadLocal(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        disk.fetchPharmacy(by: telematikId)
            .mapError(PharmacyRepositoryError.local)
            .eraseToAnyPublisher()
    }

    public func loadLocal(count: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        disk.listPharmacies(count: count)
            .mapError(PharmacyRepositoryError.local)
            .eraseToAnyPublisher()
    }

    public func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        disk.save(pharmacies: pharmacies)
            .mapError(PharmacyRepositoryError.local)
            .eraseToAnyPublisher()
    }

    public func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        disk.delete(pharmacies: pharmacies)
            .mapError(PharmacyRepositoryError.local)
            .eraseToAnyPublisher()
    }
}
