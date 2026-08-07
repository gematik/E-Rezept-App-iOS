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

import AsyncHelpers
import CasePaths
import CodedError
import Combine
import Dependencies
import eRpKit
import ErxTaskRepository
import FHIRVZD
import Foundation
import IdentifiedCollections
import Pharmacy

protocol OrdersRepository {
    func
        loadAllOrders() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>
    /// we load all local EuOrders but when fetching from remote we only fetch for current selected profile
    func loadEuOrders(profileId: UUID) -> AsyncThrowingStream<IdentifiedArray<String, EuOrder>, Swift.Error>
}

final class DefaultOrdersRepository: OrdersRepository {
    @Dependency(\.erxTaskRepository) var erxTaskRepository
    @Dependency(\.pharmacyRepository) var pharmacyRepository
    @Dependency(\.userDataStore) var userDataStore

    func loadAllOrders() -> AsyncThrowingStream<IdentifiedCollections.IdentifiedArray<String, Order>, Swift.Error> {
        AsyncThrowingStream { continuation in
            Task { [erxTaskRepository, pharmacyRepository] in
                do {
                    let communications = try await erxTaskRepository.loadLocalCommunications(.all)
                    var pharmacyLocations: [String: PharmacyLocation] = [:]
                    for id in communications.map(\.telematikId).unique() {
                        if let pharmacy = try await pharmacyRepository.loadCached(id) {
                            pharmacyLocations[pharmacy.telematikID] = pharmacy
                        }
                    }

                    let groupedCommunications = Dictionary(grouping: communications) { $0.orderId }

                    var orders: IdentifiedArray<String, Order> = IdentifiedArray()
                    for (orderId, communications) in groupedCommunications {
                        let chargeItems = try await loadChargeItems(for: Set(communications.map(\.taskId)))
                        // If there is no orderId the communications can be from different orders and pharmacies.
                        // Only add the pharmacy if the communications belong to same order id
                        var pharmacy: PharmacyLocation?
                        if orderId != nil, let telematikId = communications.first?.telematikId {
                            pharmacy = pharmacyLocations[telematikId]
                        }
                        orders.append(
                            Order(
                                orderId: orderId ?? Order.unknownOrderId,
                                communications: IdentifiedArray(uniqueElements: communications),
                                chargeItems: chargeItems,
                                pharmacy: pharmacy
                            )
                        )
                    }

                    continuation
                        .yield(IdentifiedArray(uniqueElements: orders
                                .sorted {
                                    if $0.lastUpdated == $1.lastUpdated,
                                       let pharmacy1Name = $0.pharmacy?.name,
                                       let pharmacy2Name = $1.pharmacy?.name {
                                        return pharmacy1Name < pharmacy2Name
                                    } else {
                                        return $0.lastUpdated > $1.lastUpdated
                                    }
                                }))

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func loadChargeItems(for taskIds: Set<ErxTask.ID>) async throws -> IdentifiedArray<String, ErxChargeItem> {
        var foundChargeItems: IdentifiedArray<String, ErxChargeItem> = IdentifiedArray()
        for taskId in taskIds {
            if let sparse = try await erxTaskRepository.loadLocalChargeItem(nil, taskId) {
                // Parse FHIR data on the main thread to avoid stack overflow from large
                // FHIR value types (ResourceProxy) on the cooperative thread pool's limited stack
                if let chargeItem = await MainActor.run(body: { sparse.chargeItem }) {
                    // Known issue: A Task can be assigned to multiple orders and different pharmacies.
                    // With adding the ChargeItem to each order with this taskId we potentially add it to wrong orders
                    // Also we cannot relate it to a pharmacy, since the telematikId is not part of the ChargeItem
                    foundChargeItems.append(chargeItem)
                }
            }
        }

        return foundChargeItems
    }

    func loadEuOrders(profileId: UUID) -> AsyncThrowingStream<IdentifiedArray<String, EuOrder>, Swift.Error> {
        AsyncThrowingStream { continuation in
            Task { [erxTaskRepository] in
                do {
                    var orders: IdentifiedArray<String, EuOrder> = IdentifiedArray()

                    let communications = try await erxTaskRepository.loadEuCommunications(nil, nil)
                    let groupedCommunications = Dictionary(grouping: communications) { $0.orderId }
                    let euErxTasks = try await loadAllEuTasks(profileId: profileId)

                    for (orderId, communications) in groupedCommunications {
                        orders.append(
                            EuOrder(
                                orderId: orderId ?? EuOrder.unknownOrderId,
                                communications: IdentifiedArray(uniqueElements: communications),
                                countryCode: communications.first?.countryCode ?? EuOrder.unknownCountryCode,
                                erxTasks: euErxTasks
                            )
                        )
                    }

                    continuation
                        .yield(IdentifiedArray(
                            uniqueElements: orders.sorted {
                                $0.lastUpdated > $1.lastUpdated
                            }
                        ))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func loadAllEuTasks(profileId: UUID?) async throws -> [ErxTask] {
        let tasks = try await erxTaskRepository.loadLocalAllTasks(profileId).async()
        return tasks.filter { task in
            task.isSetEURedeemableByPatient == true
        }
    }

    @CodedError("037")
    @CasePathable
    enum Error: Swift.Error, Equatable, LocalizedError {
        @ErrorCode("01")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("02")
        case pharmacyRepository(PharmacyRepositoryError)
        @ErrorCode("03")
        case unspecified(error: Swift.Error)

        var errorDescription: String? {
            switch self {
            case let .erxRepository(error):
                return error.localizedDescription
            case let .pharmacyRepository(error):
                return error.localizedDescription
            case let .unspecified(error: error):
                return error.localizedDescription
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case let .erxRepository(error):
                return error.recoverySuggestion
            case let .pharmacyRepository(error):
                return error.recoverySuggestion
            case .unspecified:
                return "Please help us and report this error"
            }
        }

        static func ==(lhs: DefaultOrdersRepository.Error, rhs: DefaultOrdersRepository.Error) -> Bool {
            switch (lhs, rhs) {
            case let (.erxRepository(lhsError), .erxRepository(rhsError)):
                lhsError.erpErrorCodeList == rhsError.erpErrorCodeList
            case let (.pharmacyRepository(lhsError), .pharmacyRepository(rhsError)):
                lhsError.erpErrorCodeList == rhsError.erpErrorCodeList
            case let (.unspecified(lhsError), .unspecified(rhsError)):
                lhsError.localizedDescription == rhsError.localizedDescription
            default:
                false
            }
        }
    }
}

extension Swift.Error {
    /// Map any Error to an DefaultOrdersRepository.Error
    func asOrdersError() -> DefaultOrdersRepository.Error {
        if let error = self as? DefaultOrdersRepository.Error {
            return error
        } else if let error = self as? ErxRepositoryError {
            return .erxRepository(error)
        } else if let error = self as? PharmacyRepositoryError {
            return .pharmacyRepository(error)
        } else {
            return .unspecified(error: self)
        }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
