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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Pharmacy
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyRedeemViewSnapshotTests: ERPSnapshotTestCase {
    func testPharmacyRedeemViewMissingAddress() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            prescriptions: Shared(Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedPrescriptions: Shared(Prescription.Fixtures.prescriptions),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationStack {
            PharmacyRedeemView(store: StoreOf<PharmacyRedeemDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }.frame(width: 375, height: 1200, alignment: .top)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testPharmacyRedeemViewFullAddress() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            prescriptions: Shared(Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedPrescriptions: Shared(Prescription.Fixtures.prescriptions),
            selectedShipmentInfo: ShipmentInfo(
                name: "Anna Maria Vetter",
                street: "Benzelrather Str. 29",
                addressDetail: "Postfach 11122",
                zip: "50226",
                city: "Frechen",
                phone: "+491771234567",
                mail: "anna.vetter@gematik.de",
                deliveryInfo: "Please do not hesitate to ring the bell twice"
            ),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationStack {
            PharmacyRedeemView(store: StoreOf<PharmacyRedeemDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }.frame(width: 375, height: 1210, alignment: .top)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testPharmacyRedeemViewTypeShipmentMissingPhone() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            prescriptions: Shared(Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedPrescriptions: Shared(Prescription.Fixtures.prescriptions),
            selectedShipmentInfo: ShipmentInfo(
                name: "Anna Vetter",
                street: "Benzelrather Str. 29",
                zip: "50226",
                city: "Frechen",
                mail: "anna.vetter@gematik.de"
            ),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationStack {
            PharmacyRedeemView(store: StoreOf<PharmacyRedeemDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }.frame(width: 375, height: 1200, alignment: .top)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testPharmacyRedeemViewSelfPayerWarning() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            prescriptions: Shared([Prescription.Dummies.prescriptionSelfPayer]),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedPrescriptions: Shared([Prescription.Dummies.prescriptionSelfPayer]),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationStack {
            PharmacyRedeemView(store: StoreOf<PharmacyRedeemDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }.frame(width: 375, height: 1200, alignment: .top)

        assertSnapshots(of: sut, as: snapshotModi())
    }
}
