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

import Nimble
import XCTest

struct PharmacyDetailsScreen: Screen {
    var app: XCUIApplication

    func tapRedeem(file: StaticString = #file, line: UInt = #line) -> RedeemScreen {
        buttonForService(.shipment, file: file, line: line).tap()

        return RedeemScreen(app: app)
    }

    func buttonForService(_ service: Service, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: service.buttonId, file: file, line: line)
    }

    enum Service: String, CaseIterable {
        case pickup
        case pickupViaLogin
        case delivery
        case deliveryViaLogin
        case shipment
        case shipmentViaLogin

        var buttonId: String {
            switch self {
            case .pickup:
                return A11y.pharmacyDetail.phaDetailBtnPickup
            case .pickupViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnPickupViaLogin
            case .delivery:
                return A11y.pharmacyDetail.phaDetailBtnDelivery
            case .deliveryViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnDeliveryViaLogin
            case .shipment:
                return A11y.pharmacyDetail.phaDetailBtnShipment
            case .shipmentViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnShipmentViaLogin
            }
        }
    }
}
