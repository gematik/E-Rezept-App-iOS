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

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import ModelsR4
import Pharmacy
import SwiftUI

extension PharmacySearchDomain.Environment {
    func searchPharmacies(searchTerm: String, location: ComposableCoreLocation.Location?)
        -> Effect<PharmacySearchDomain.Action, Never> {
        var position: Position?
        if let latitude = location?.coordinate.latitude,
           let longitude = location?.coordinate.longitude {
            position = Position(lat: latitude, lon: longitude)
        }
        return pharmacyRepository.searchPharmacies(searchTerm: searchTerm, position: position)
            .catchToEffect()
            .map(PharmacySearchDomain.Action.pharmaciesReceived)
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }

    func sortPharmacies(pharmacyLocations: [PharmacyLocationViewModel],
                        sortOrder: PharmacySearchDomain.SortOrder) -> Effect<[PharmacyLocationViewModel], Never> {
        var sorted: [PharmacyLocationViewModel]
        switch sortOrder {
        case .alphabetical:
            sorted = pharmacyLocations.sorted(by: alphabetical)
        case .distance:
            sorted = pharmacyLocations.sorted(by: distance)
        }
        return Just(sorted).eraseToEffect()
    }

    private func alphabetical(pharmacy1: PharmacyLocationViewModel,
                              pharmacy2: PharmacyLocationViewModel) -> Bool {
        pharmacy1.pharmacyLocation.name?.localizedCompare(pharmacy2.pharmacyLocation.name ?? "") == .orderedAscending
    }

    private func distance(pharmacy1: PharmacyLocationViewModel,
                          pharmacy2: PharmacyLocationViewModel) -> Bool {
        pharmacy1.distanceInKm ?? 0 < pharmacy2.distanceInKm ?? 0
    }
}
