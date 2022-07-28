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

import Foundation
import Pharmacy

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
        if wasAuthenticatedBefore {
            return pharmacy.hasReservationService ? .erxTaskRepository : .noService
        } else {
            if pharmacy.hasReservationAVSService {
                return .avs
            } else if pharmacy.hasReservationService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }
    }

    var shipmentService: RedeemServiceOption {
        if wasAuthenticatedBefore {
            return pharmacy.hasShipmentService ? .erxTaskRepository : .noService
        } else {
            if pharmacy.hasShipmentAVSService {
                return .avs
            } else if pharmacy.hasShipmentService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }
    }

    var deliveryService: RedeemServiceOption {
        if wasAuthenticatedBefore {
            return pharmacy.hasDeliveryService ? .erxTaskRepository : .noService
        } else {
            if pharmacy.hasDeliveryAVSService {
                return .avs
            } else if pharmacy.hasDeliveryService {
                return .erxTaskRepositoryAvailable
            } else {
                return .noService
            }
        }
    }
}
