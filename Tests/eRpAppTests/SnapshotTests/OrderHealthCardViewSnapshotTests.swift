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

import ComposableArchitecture
@testable import eRpFeatures
import SnapshotTesting
import SwiftUI
import XCTest

final class OrderHealthCardViewSnapshotTests: ERPSnapshotTestCase {
    func testOrderHealthCardView() {
        let sut = OrderHealthCardListView(store:
            StoreOf<OrderHealthCardDomain>(
                initialState: .init(searchText: "EmptyKK")

            ) {
                EmptyReducer()
            })

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOrderHealthCardView_SelectedInsuranceNoContact() {
        let sut = OrderHealthCardInquiryView(store:
            StoreOf<OrderHealthCardInquiryDomain>(
                initialState: .init(insuranceCompany: OrderHealthCardDomain
                    .HealthInsuranceCompany(name: "EmptyKK",
                                            healthCardAndPinPhone: "",
                                            healthCardAndPinMail: "",
                                            healthCardAndPinUrl: "",
                                            pinUrl: "",
                                            subjectCardAndPinMail: "",
                                            bodyCardAndPinMail: "",
                                            subjectPinMail: "",
                                            bodyPinMail: ""))

            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOrderHealthCardView_SelectedInsurance() {
        let sut = OrderHealthCardInquiryView(store:
            StoreOf<OrderHealthCardInquiryDomain>(
                initialState: OrderHealthCardInquiryDomain.Dummies.state
            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOrderHealthCardView_ContactFull() {
        let sut = OrderHealthCardContactView(store:
            StoreOf<OrderHealthCardContactDomain>(
                initialState: .init(insuranceCompany: .dummyHealthInsuranceCompany,
                                    serviceInquiry: .healthCardAndPin)

            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOrderHealthCardView_ContactEmpty() {
        let sut = OrderHealthCardContactView(store:
            StoreOf<OrderHealthCardContactDomain>(
                initialState: .init(insuranceCompany: OrderHealthCardDomain
                    .HealthInsuranceCompany(name: "EmptyKK",
                                            healthCardAndPinPhone: "",
                                            healthCardAndPinMail: "",
                                            healthCardAndPinUrl: "",
                                            pinUrl: "",
                                            subjectCardAndPinMail: "",
                                            bodyCardAndPinMail: "",
                                            subjectPinMail: "",
                                            bodyPinMail: ""),
                    serviceInquiry: .healthCardAndPin)

            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
