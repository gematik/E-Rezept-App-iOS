//
//  Copyright (c) 2021 gematik GmbH
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

extension PharmacyLocation {
    enum Dummies {
        static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            housenumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )
        static let address2 = PharmacyLocation.Address(
            street: "Meisenweg",
            housenumber: "23",
            zip: "54321",
            city: "Linsengericht"
        )
        static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )

        static let pharmacy = PharmacyLocation(
            id: "1",
            telematikID: "3-06.2.ycl.123",
            name: "Apotheke am Wäldchen",
            type: [.pharm, .emergency, .mobl, .outpharm],
            position: Position(latitude: 49.2470345, longitude: 8.8668786),
            address: address1,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "07:00:00"
                ),
            ]
        )

        static let pharmacies = [
            pharmacy,
            PharmacyLocation(
                id: "2",
                telematikID: "3-09.2.S.10.124",
                name: "Apotheke hinter der Bahn",
                type: [PharmacyLocation.PharmacyType.pharm,
                       PharmacyLocation.PharmacyType.outpharm],
                address: address2,
                telecom: telecom,
                hoursOfOperation: [
                    PharmacyLocation.HoursOfOperation(
                        daysOfWeek: ["wed"],
                        openingTime: "09:00:00",
                        closingTime: "17:30:00"
                    ),
                ]
            ),
            PharmacyLocation(
                id: "3",
                telematikID: "3-09.2.sdf.125",
                name: "Apotheke Elise",
                type: [PharmacyLocation.PharmacyType.pharm,
                       PharmacyLocation.PharmacyType.mobl],
                address: address1,
                telecom: telecom,
                hoursOfOperation: []
            ),
            PharmacyLocation(
                id: "4",
                telematikID: "3-09.2.dfs.126",
                name: "Eulenapotheke",
                type: [PharmacyLocation.PharmacyType.outpharm],
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
