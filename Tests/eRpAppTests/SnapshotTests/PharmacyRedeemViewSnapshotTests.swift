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
import eRpKit
import Pharmacy
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyRedeemViewSnapshotTests: ERPSnapshotTestCase {
    func testPharmacyRedeemViewMissingAddress() {
        let initialState = PharmacyRedeemDomain.State(
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red),
            serviceOptionState: .init(
                prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
                selectedOption: .onPremise,
                availableOptions: [.onPremise, .shipment]
            )
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
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
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
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red),
            serviceOptionState: .init(
                prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
                selectedOption: .shipment,
                availableOptions: [.onPremise, .delivery, .shipment]
            )
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
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedShipmentInfo: ShipmentInfo(
                name: "Anna Vetter",
                street: "Benzelrather Str. 29",
                zip: "50226",
                city: "Frechen",
                mail: "anna.vetter@gematik.de"
            ),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red),
            serviceOptionState: .init(
                prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
                selectedOption: .shipment,
                availableOptions: [.onPremise, .delivery]
            )
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
            prescriptions: Shared(value: [Prescription.Dummies.prescriptionSelfPayer]),
            selectedPrescriptions: Shared(value: [Prescription.Dummies.prescriptionSelfPayer]),
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red),
            serviceOptionState: .init(
                prescriptions: Shared(value: [Prescription.Dummies.prescriptionSelfPayer]),
                selectedOption: .onPremise,
                availableOptions: [.delivery]
            )
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
