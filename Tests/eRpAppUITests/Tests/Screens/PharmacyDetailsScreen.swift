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

import eRpResources
import Nimble
import XCTest

@MainActor
struct PharmacyDetailsScreen: Screen {
    var app: XCUIApplication

    func tapRedeem(
        _ service: Service = .shipment,
        fileID _: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) -> RedeemScreen {
        buttonForService(service, file: file, line: line).tap()

        return RedeemScreen(app: app)
    }

    func tapBackButton(fileID: String = #fileID, file: String = #filePath,
                       line: UInt = #line) {
        button(within: app.navigationBars, by: "Apothekensuche", fileID: fileID, file: file, line: line).tap()
    }

    func expandSheet(file _: StaticString = #file, line _: UInt = #line) {
        app.scrollViews.firstMatch.swipeUp(velocity: 1000.0)
    }

    @discardableResult
    func tapClose(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> OrderDetailsScreen {
        button(by: A11y.pharmacyDetail.phaDetailBtnClose, fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapFavorite(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: "star", fileID: fileID, file: file, line: line).tap()
    }

    func contactSectionHeader(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.pharmacyDetail.phaDetailContact, fileID: fileID, file: file, line: line)
    }

    func buttonForService(_ service: Service, fileID: String = #fileID, file: String = #filePath,
                          line: UInt = #line) -> XCUIElement {
        button(by: service.buttonId, fileID: fileID, file: file, line: line)
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

    func buttonForContact(_ contact: Contact, fileID: String = #fileID, file: String = #filePath,
                          line: UInt = #line) -> XCUIElement {
        button(by: contact.buttonId, fileID: fileID, file: file, line: line)
    }

    enum Contact: String, CaseIterable {
        case phone
        case mail
        case map

        var buttonId: String {
            switch self {
            case .phone:
                return A11y.pharmacyDetail.phaDetailBtnOpenPhone
            case .mail:
                return A11y.pharmacyDetail.phaDetailBtnOpenMail
            case .map:
                return A11y.pharmacyDetail.phaDetailBtnOpenMap
            }
        }
    }
}
