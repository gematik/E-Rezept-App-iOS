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

@testable import eRpFeatures
import eRpKit
import Foundation

extension PharmacyLocationViewModel {
    enum Fixtures {
        static let referenceDateMonday1645: Date = {
            let dateComponents = DateComponents(
                calendar: Calendar.current,
                timeZone: TimeZone.current,
                year: 2022,
                hour: 16,
                minute: 45,
                weekday: 3,
                weekOfYear: 25
            ) // tue, 16:45
            return dateComponents.date!
        }()

        static let pharmacyA = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyA,
            referenceDate: referenceDateMonday1645
        )

        static let pharmacyB = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyB,
            referenceDate: referenceDateMonday1645
        )

        static let pharmacyC = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyC,
            referenceDate: referenceDateMonday1645
        )

        static let pharmacyD = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyD,
            referenceDate: referenceDateMonday1645
        )

        static let pharmacyE = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyE,
            referenceDate: referenceDateMonday1645
        )

        static let pharmacyInactive = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Fixtures.pharmacyInactive,
            referenceDate: referenceDateMonday1645
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
