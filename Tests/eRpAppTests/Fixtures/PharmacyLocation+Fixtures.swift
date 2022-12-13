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

@testable import eRpApp
import eRpKit
import Foundation

extension PharmacyLocation {
    enum Fixtures {
        static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )
        static let pharmacyA = PharmacyLocation(
            id: "Adler1",
            status: .active,
            telematikID: "12345.1",
            name: "Adler Apotheke",
            types: [PharmacyLocation.PharmacyType.mobl, PharmacyLocation.PharmacyType.emergency],
            position: Position(latitude: 49.2470345, longitude: 8.8668786),
            address: .init(street: "Tempelhofer Damm", houseNumber: "145", zip: "12099", city: "Berlin"),
            telecom: telecom,
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "12:00:00",
                    closingTime: "18:00:00"
                ),
            ]
        )

        static let pharmacyB = PharmacyLocation(
            id: "Adler2",
            status: .active,
            telematikID: "12345.2",
            name: "Adler Apotheke",
            types: [PharmacyLocation.PharmacyType.mobl, PharmacyLocation.PharmacyType.emergency],
            address: .init(street: "Zooweg", houseNumber: "1", zip: "12099", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "12:00:00",
                    closingTime: "17:00:00"
                ),
            ]
        )

        static let pharmacyC = PharmacyLocation(
            id: "Adler3",
            status: .active,
            telematikID: "12345.3",
            name: "Adler Apotheke",
            types: [PharmacyLocation.PharmacyType.mobl, PharmacyLocation.PharmacyType.emergency],
            address: .init(street: "Zooweg", houseNumber: "1", zip: "12099", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "17:00:00",
                    closingTime: "21:00:00"
                ),
            ]
        )

        static let pharmacyD = PharmacyLocation(
            id: "Adler4",
            status: .active,
            telematikID: "12345.4",
            name: "@dler @potheke",
            types: [PharmacyLocation.PharmacyType.delivery],
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon"],
                    openingTime: "12:00:00",
                    closingTime: "14:00:00"
                ),
            ]
        )

        static let pharmacyE = PharmacyLocation(
            id: "ProfMaurice1",
            status: .active,
            telematikID: "12345.5",
            name: "ProfMaurice",
            types: [PharmacyLocation.PharmacyType.delivery],
            hoursOfOperation: []
        )

        static let pharmacyInactive = PharmacyLocation(
            id: "ProfMaurice1",
            status: .inactive,
            telematikID: "3-09.2.S.10.124",
            name: "ProfMaurice",
            types: [PharmacyLocation.PharmacyType.pharm,
                    PharmacyLocation.PharmacyType.outpharm],
            address: .init(
                street: "Meisenweg",
                houseNumber: "23",
                zip: "54321",
                city: "Linsengericht"
            ),
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["wed"],
                    openingTime: "08:00:00",
                    closingTime: "12:00:00"
                ),
            ]
        )

        static let pharmacies = [
            pharmacyA,
            pharmacyB,
            pharmacyC,
            pharmacyD,
            pharmacyE,
        ]
    }
}
