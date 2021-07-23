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

import SwiftUI

struct ActionNavigationLink<Destination: View>: View {
    private let destination: Destination

    @Binding private var continueToDestination: Bool

    init(
        destination: Destination,
        activate: Binding<Bool>
    ) {
        self.destination = destination
        _continueToDestination = activate
    }

    var body: some View {
        NavigationLink(destination: destination, isActive: $continueToDestination) {
            EmptyView()
        }
    }
}
