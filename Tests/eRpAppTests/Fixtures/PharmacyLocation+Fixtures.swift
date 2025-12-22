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

@testable import eRpFeatures
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
            name: "Bdler Apotheke",
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

        // pharmacy with specialClosing that will be closed
        static let pharmacyF = PharmacyLocation(
            id: "AdlerClosed",
            status: .active,
            telematikID: "12344.3",
            name: "AdlerClosed",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Zooweg", houseNumber: "1", zip: "12099", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "17:00:00",
                    closingTime: "21:00:00"
                ),
            ],
            specialClosingHours: [.init(
                reason: "Ruhetag 1",
                startDate: TestDate.createFormattedDate(.dayBeforeYesterday),
                endDate: TestDate.createFormattedDate(.dayAfterTomorrow)
            ),
            .init(
                reason: "Ruhetag 2",
                startDate: TestDate.createFormattedDate(.twelveDaysAhead),
                endDate: TestDate.createFormattedDate(.twelveDaysAhead)
            )]
        )

        // pharmacy with specialClosing that will close early
        static let pharmacyG = PharmacyLocation(
            id: "AdlerEarly",
            status: .active,
            telematikID: "12344.5",
            name: "AdlerEarly",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Parkweg", houseNumber: "2", zip: "13098", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "23:59:00"
                ),
            ],
            specialClosingHours: [.init(
                reason: "Abendessen",
                startDate: TestDate.createFormattedDate(.oneHourAhead),
                endDate: TestDate.createFormattedDate(.tomorrow)
            )]
        )

        // pharmacy with specialClosing that is closed but will open later again
        static let pharmacyH = PharmacyLocation(
            id: "AdlerLater",
            status: .active,
            telematikID: "12344.6",
            name: "AdlerLater",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Parkweg", houseNumber: "3", zip: "13041", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "23:59:00"
                ),
            ],
            specialClosingHours: [.init(
                reason: "Ausschlafen",
                startDate: TestDate.createFormattedDate(.yesterday),
                endDate: TestDate.createFormattedDate(.halfanHourAhead)
            )]
        )

        // pharmacy with specialClosing already closed and emergencyServiceHours taht will later again
        static let pharmacyI = PharmacyLocation(
            id: "EmergencyAfterAdler",
            status: .active,
            telematikID: "12344.6",
            name: "Nacht-Adler",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Parkweg", houseNumber: "3", zip: "13041", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "22:30:00"
                ),
            ],
            specialClosingHours: [.init(
                reason: "Ausschlafen",
                startDate: TestDate.createFormattedDate(.sixteenDaysBefore),
                endDate: TestDate.createFormattedDate(.weekBefore)
            ), .init(
                reason: "Ausschlafen",
                startDate: TestDate.createFormattedDate(.yesterday),
                endDate: TestDate.createFormattedDate(.oneHourAhead)
            )],
            emergencyServiceHours: [.init(startDate: TestDate.createFormattedDate(.sixteenDaysBefore),
                                          endDate: TestDate.createFormattedDate(.weekBefore)),
                                    .init(startDate: TestDate.createFormattedDate(.oneHourAhead),
                                          endDate: TestDate.createFormattedDate(.tomorrow))]
        )

        // pharmacy with emergencyServiceHours that starts early
        static let pharmacyJ = PharmacyLocation(
            id: "EmergencyBeforeBird",
            status: .active,
            telematikID: "12344.6",
            name: "Early-Adler",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Parkweg", houseNumber: "3", zip: "13041", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "22:45:00",
                    closingTime: "23:59:00"
                ),
            ],
            emergencyServiceHours: [.init(startDate: TestDate.createFormattedDate(.yesterday),
                                          endDate: TestDate.createFormattedDate(.halfanHourAhead))]
        )

        // pharmacy with emergencyServiceHours that ends on the next day
        static let pharmacyK = PharmacyLocation(
            id: "NormalEmergencyAdler",
            status: .active,
            telematikID: "12344.6",
            name: "NextDay-Adler",
            types: [PharmacyLocation.PharmacyType.delivery],
            address: .init(street: "Parkweg", houseNumber: "3", zip: "13041", city: "Berlin"),
            hoursOfOperation: [
                .init(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:30:00",
                    closingTime: "19:00:00"
                ),
            ],
            emergencyServiceHours: [.init(startDate: TestDate.createFormattedDate(.oneHourAgo),
                                          endDate: TestDate.createFormattedDate(.sixHoursAhead)),
                                    .init(startDate: TestDate.createFormattedDate(.twelveDaysAhead),
                                          endDate: TestDate.createFormattedDate(.twentyEightDaysAhead))]
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
