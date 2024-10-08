//
//  Copyright (c) 2024 gematik GmbH
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

import eRpKit
import Foundation

enum RedeemServiceOption {
    /// `ErxTaskRepository`  has been used before and should now be used over  `avs`
    case erxTaskRepository
    /// `avs` can be used
    case avs
    ///  No `avs` service is available but `ErxTaskRepository` could be used after user authentication
    case erxTaskRepositoryAvailable
    /// None of the two services can be used.
    case noService

    var hasService: Bool {
        self == .erxTaskRepository || self == .avs || self == .erxTaskRepositoryAvailable
    }

    var hasServiceAfterLogin: Bool {
        self == .erxTaskRepositoryAvailable
    }

    var isAVS: Bool {
        self == .avs
    }

    var isErxTaskRepository: Bool {
        self == .erxTaskRepository || self == .erxTaskRepositoryAvailable
    }
}

struct RedeemOptionProvider: Equatable {
    let wasAuthenticatedBefore: Bool
    let pharmacy: PharmacyLocation

    var reservationService: RedeemServiceOption {
        guard pharmacy.hasAnyAVSService else {
            if wasAuthenticatedBefore, pharmacy.hasReservationService {
                return .erxTaskRepository
            } else if pharmacy.hasReservationService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }

        if wasAuthenticatedBefore, pharmacy.hasReservationAVSService {
            return .erxTaskRepository
        } else if pharmacy.hasReservationAVSService {
            return .avs
        } else {
            return .noService
        }
    }

    var shipmentService: RedeemServiceOption {
        guard pharmacy.hasAnyAVSService else {
            if wasAuthenticatedBefore, pharmacy.hasShipmentService {
                return .erxTaskRepository
            } else if pharmacy.hasShipmentService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }

        if wasAuthenticatedBefore, pharmacy.hasShipmentAVSService {
            return .erxTaskRepository
        } else if pharmacy.hasShipmentAVSService {
            return .avs
        } else {
            return .noService
        }
    }

    var deliveryService: RedeemServiceOption {
        guard pharmacy.hasAnyAVSService else {
            if wasAuthenticatedBefore, pharmacy.hasDeliveryService {
                return .erxTaskRepository
            } else if pharmacy.hasDeliveryService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }

        if wasAuthenticatedBefore, pharmacy.hasDeliveryAVSService {
            return .erxTaskRepository
        } else if pharmacy.hasDeliveryAVSService {
            return .avs
        } else {
            return .noService
        }
    }
}
