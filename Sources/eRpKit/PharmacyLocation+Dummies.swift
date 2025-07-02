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

// swiftlint:disable missing_docs
extension PharmacyLocation {
    public enum Dummies {
        static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            houseNumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )
        static let address2 = PharmacyLocation.Address(
            street: "Meisenweg",
            houseNumber: "23",
            zip: "54321",
            city: "Linsengericht"
        )
        static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )

        public static let pharmacy = PharmacyLocation(
            id: "1",
            status: .active,
            telematikID: "3-06.2.ycl.123",
            name: "Apotheke am Wäldchen",
            types: [.pharm, .emergency, .mobl, .outpharm, .delivery],
            position: Position(latitude: 49.2470345, longitude: 8.8668786),
            address: address1,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["tue", "wed"],
                    openingTime: "08:00:00",
                    closingTime: "18:00:00"
                ),
            ]
        )

        public static let pharmacyInactive =
            PharmacyLocation(
                id: "2",
                status: .inactive,
                telematikID: "3-09.2.S.10.124",
                name: "Apotheke hinter der Bahn",
                types: [PharmacyLocation.PharmacyType.pharm,
                        PharmacyLocation.PharmacyType.outpharm],
                position: Position(latitude: 49.2460345, longitude: 8.8668786),
                address: address2,
                telecom: telecom,
                hoursOfOperation: [
                    PharmacyLocation.HoursOfOperation(
                        daysOfWeek: ["wed"],
                        openingTime: "08:00:00",
                        closingTime: "12:00:00"
                    ),
                ]
            )

        public static let referenceDate: Date = {
            let dateComponents = DateComponents(
                calendar: Calendar.current,
                year: 2022,
                hour: 13,
                minute: 45,
                weekday: 3,
                weekOfYear: 25
            ) // tue, 13:45
            return dateComponents.date! // swiftlint:disable:this force_unwrapping
        }()

        public static let pharmacies = [
            pharmacy,
            pharmacyInactive,
            PharmacyLocation(
                id: "3",
                status: .active,
                telematikID: "3-09.2.sdf.125",
                name: "Apotheke Elise mit langem Vor- und Zunamen am Rathaus",
                types: [PharmacyLocation.PharmacyType.pharm,
                        PharmacyLocation.PharmacyType.mobl],
                position: Position(latitude: 49.23, longitude: 8.8668786),
                address: address1,
                telecom: telecom,
                hoursOfOperation: [
                    PharmacyLocation.HoursOfOperation(
                        daysOfWeek: ["mon", "tue", "wed"],
                        openingTime: "07:00:00",
                        closingTime: "14:00:00"
                    ),
                ]
            ),
            PharmacyLocation(
                id: "4",
                status: .inactive,
                telematikID: "3-09.2.dfs.126",
                name: "Eulenapotheke",
                types: [PharmacyLocation.PharmacyType.outpharm],
                address: address2,
                telecom: telecom,
                hoursOfOperation: [
                    PharmacyLocation.HoursOfOperation(
                        daysOfWeek: ["tue"],
                        openingTime: "07:00:00",
                        closingTime: "13:00:00"
                    ),
                ]
            ),
            PharmacyLocation(
                id: "5",
                status: .inactive,
                telematikID: "3-09.2.dfs.127",
                name: "Eulenapotheke 2",
                types: [PharmacyLocation.PharmacyType.outpharm],
                address: address2,
                telecom: telecom,
                hoursOfOperation: [
                    PharmacyLocation.HoursOfOperation(
                        daysOfWeek: ["fri"],
                        openingTime: "07:00:00",
                        closingTime: "13:00:00"
                    ),
                ]
            ),
        ]
    }
}

// swiftlint:enable missing_docs
