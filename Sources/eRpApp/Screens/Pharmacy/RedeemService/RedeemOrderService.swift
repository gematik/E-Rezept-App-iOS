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
import CodedError
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation
import IdentifiedCollections
import Pharmacy

@DependencyClient
struct RedeemOrderService {
    var redeemOptionProvider: @Sendable (_ pharmacy: PharmacyLocation) async throws -> RedeemOptionProvider
    var redeemViaErxTaskRepository: @Sendable (_ orders: [OrderRequest], _ profileId: UUID) async throws
        -> IdentifiedArrayOf<OrderResponse>
    var redeemViaErxTaskRepositoryDiGa: @Sendable (_ orders: [OrderDiGaRequest], _ profileId: UUID) async throws
        -> IdentifiedArrayOf<OrderDiGaResponse>
}

extension RedeemOrderService: DependencyKey {
    static let liveValue: Self = {
        @Dependency(\.userSession) var userSession: UserSession
        @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
        @Dependency(\.erxTaskRepositoryRedeemService) var erxTaskRepositoryRedeemService

        return Self(
            redeemOptionProvider: { pharmacy in
                var pharmacy = pharmacy
                let profile = try await userSession.profile().async(\RedeemOrderServiceError.Cases.localStore)

                return RedeemOptionProvider(
                    wasAuthenticatedBefore: profile.isLinkedToInsuranceId,
                    pharmacy: pharmacy
                )
            },
            redeemViaErxTaskRepository: { orders, profileId in
                try await erxTaskRepositoryRedeemService().redeem(orders, profileId: profileId)
                    .async(\RedeemOrderServiceError.Cases.redeem)
            },
            redeemViaErxTaskRepositoryDiGa: { orders, profileId in
                try await erxTaskRepositoryRedeemService().redeemDiGa(orders, profileId: profileId)
                    .async(\RedeemOrderServiceError.Cases.redeem)
            }
        )
    }()
}

extension DependencyValues {
    var redeemOrderService: RedeemOrderService {
        get { self[RedeemOrderService.self] }
        set { self[RedeemOrderService.self] = newValue }
    }
}

@CodedError("045")
@CasePathable
enum RedeemOrderServiceError: Swift.Error, Equatable, LocalizedError {
    @ErrorCode("01")
    case localStore(LocalStoreError)
    @ErrorCode("02")
    case pharmacy(PharmacyRepositoryError)
    @ErrorCode("03")
    case redeem(RedeemServiceError)
}
