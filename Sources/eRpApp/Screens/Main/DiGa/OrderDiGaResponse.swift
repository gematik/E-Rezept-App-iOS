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

import Foundation
import IdentifiedCollections

struct OrderDiGaResponse: Identifiable, Equatable, Codable {
    var id: String {
        requested.taskID
    }

    var requested: OrderDiGaRequest
    var result: ProgressResponse<Bool, RedeemServiceError, OrderResponse.Progress>

    var inProgress: Bool {
        if case .progress = result {
            return true
        }
        return false
    }

    var isSuccess: Bool {
        if case .success = result {
            return true
        }
        return false
    }

    var isFailure: Bool {
        if case .failure = result {
            return true
        }
        return false
    }

    enum Progress: Equatable, Codable {
        case loading
        case done
    }
}

extension IdentifiedArrayOf where Element == OrderDiGaResponse {
    var areSuccessful: Bool {
        allSatisfy { $0.isSuccess == true }
    }

    var arePartiallySuccessful: Bool {
        !contains { $0.inProgress } && contains { $0.isFailure } && contains { $0.isSuccess }
    }

    var areFailing: Bool {
        allSatisfy { $0.isFailure == true }
    }

    var failedCount: Int {
        compactMap { $0.isFailure ? true : nil }.count
    }

    var inProgress: Bool {
        contains { $0.inProgress }
    }

    var progress: Double {
        let progressCount = filter(\.inProgress).count
        if progressCount > 0 {
            return Double(count - progressCount) / Double(count)
        }
        return 1.0
    }
}
