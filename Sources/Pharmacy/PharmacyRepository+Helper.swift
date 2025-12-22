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
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation
import OpenSSL

extension PharmacyRepository {
    // swiftlint:disable function_body_length cyclomatic_complexity
    /// Create an instance of PharamcyRepository based on the `PharmacyLocalDataStore` and `PharmacyRemoteDataStore`
    public static func createWithMocks(disk: PharmacyLocalDataStore) -> PharmacyRepository {
        @Dependency(\.pharmacyRemoteDataStore) var cloud
        return PharmacyRepository(
            updateFromRemote: { telematikId in
                do {
                    // Fetch the remote pharmacy asynchronously
                    guard let remotePharmacy = try await cloud.fetchPharmacy(telematikId) else {
                        throw PharmacyRepositoryError.remote(.notFound)
                    }

                    // Update local disk store asynchronously
                    let pharmacyInStore = try await disk.update(telematikId: telematikId) { pharmacyInStore in
                        pharmacyInStore.name = remotePharmacy.name
                        pharmacyInStore.telecom = remotePharmacy.telecom
                        pharmacyInStore.position = remotePharmacy.position
                        pharmacyInStore.address = remotePharmacy.address
                        pharmacyInStore.id = remotePharmacy.id
                    }
                    .async()

                    // Merge additional remote properties
                    var updated = pharmacyInStore
                    updated.types = remotePharmacy.types
                    updated.status = remotePharmacy.status
                    updated.hoursOfOperation = remotePharmacy.hoursOfOperation
                    updated.avsEndpoints = remotePharmacy.avsEndpoints
                    updated.avsCertificates = remotePharmacy.avsCertificates

                    return updated

                } catch let error as PharmacyRemoteStoreError {
                    throw PharmacyRepositoryError.remote(error)
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            loadCached: { telematikId in
                do {
                    let localPharmacy = try await disk.fetchPharmacy(by: telematikId).first().async()

                    if let pharmacy = localPharmacy {
                        return pharmacy
                    } else {
                        let remotePharmacy = try await cloud.fetchPharmacy(telematikId)
                        guard let pharmacy = remotePharmacy else { return nil }
                        _ = try await disk.save(pharmacies: [pharmacy]).async()
                        return pharmacy
                    }
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            searchRemote: { searchTerm, position, filter in
                do {
                    let remotePharmacies = try await cloud.searchPharmacies(
                        searchTerm,
                        position,
                        filter
                    )

                    let localPharmacies = try await disk.listPharmacies(count: nil).async()

                    let merged = remotePharmacies.map { remote in
                        var copy = remote
                        if let local = localPharmacies.first(where: { $0.telematikID == remote.telematikID }) {
                            copy.updateLocalStoredProperties(with: local)
                        }
                        return copy
                    }

                    if filter.contains(.delivery) {
                        return merged.filter(\.hasDeliveryService)
                    }

                    return merged
                } catch let error as PharmacyRemoteStoreError {
                    throw PharmacyRepositoryError.remote(error)
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            loadLocalById: { telematikId in
                do {
                    return try await disk.fetchPharmacy(by: telematikId).async()
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            loadLocalCount: { count in
                do {
                    return try await disk.listPharmacies(count: count).async()
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            saveMultiple: { pharmacies in
                do {
                    return try await disk.save(pharmacies: pharmacies).async()
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            deleteMultiple: { pharmacies in
                do {
                    return try await disk.delete(pharmacies: pharmacies).async()
                } catch let error as LocalStoreError {
                    throw PharmacyRepositoryError.local(error)
                }
            },
            fetchInsurance: { ikNumber in
                do {
                    return try await cloud.fetchInsurance(ikNumber)
                } catch let error as PharmacyRemoteStoreError {
                    throw PharmacyRepositoryError.remote(error)
                }
            },
            fetchAllInsurances: {
                do {
                    return try await cloud.fetchAllInsurances()
                } catch let error as PharmacyRemoteStoreError {
                    throw PharmacyRepositoryError.remote(error)
                }
            },
            fetchEuCountries: {
                do {
                    return try await cloud.fetchEuCountries()
                } catch let error as PharmacyRemoteStoreError {
                    throw PharmacyRepositoryError.remote(error)
                }
            }
        )
    }

    // swiftlint:enable function_body_length cyclomatic_complexity
}
