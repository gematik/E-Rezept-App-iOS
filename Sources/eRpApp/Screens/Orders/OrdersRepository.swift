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

import CasePaths
import Combine
import Dependencies
import eRpKit
import FHIRVZD
import Foundation
import IdentifiedCollections
import Pharmacy

protocol OrdersRepository {
    func loadAllOrders() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>
}

final class DefaultOrdersRepository: OrdersRepository {
    private let erxTaskRepository: ErxTaskRepository
    private let pharmacyRepository: PharmacyRepository

    internal init(erxTaskRepository: ErxTaskRepository, pharmacyRepository: PharmacyRepository) {
        self.erxTaskRepository = erxTaskRepository
        self.pharmacyRepository = pharmacyRepository
    }

    func loadAllOrders() -> AsyncThrowingStream<IdentifiedCollections.IdentifiedArray<String, Order>, Swift.Error> {
        AsyncThrowingStream { continuation in
            Task { [erxTaskRepository, pharmacyRepository] in
                do {
                    for try await communications in erxTaskRepository.loadLocalCommunications(for: .all).values {
                        var pharmacyLocations: [String: PharmacyLocation] = [:]
                        for id in communications.map(\.telematikId).unique() {
                            if let pharmacy = try await pharmacyRepository.loadCached(by: id)
                                .async(\Error.Cases.pharmacyRepository) {
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
                    }

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
            if let chargeItem = try await erxTaskRepository.loadLocal(by: taskId).async()?.chargeItem {
                // Known issue: A Task can be assigned to multiple orders and different pharmacies.
                // With adding the ChargeItem to each order with this taskId we potentially add it to wrong orders
                // Also we cannot relate it to a pharmacy, since the telematikId is not part of the ChargeItem
                foundChargeItems.append(chargeItem)
            }
        }

        return foundChargeItems
    }

    // sourcery: CodedError = "037"
    @CasePathable
    enum Error: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "02"
        case pharmacyRepository(PharmacyRepositoryError)
        // sourcery: errorCode = "03"
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
