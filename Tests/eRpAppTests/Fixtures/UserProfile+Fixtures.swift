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

extension UserProfile {
    enum Fixtures {
        static let theo = UserProfile(
            profile: Profile(
                name: "Theo Testprofil",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .green,
                lastAuthenticated: nil,
                erxTasks: []
            ),
            connectionStatus: .connected,
            activityIndicating: false
        )

        static let olafOffline = UserProfile(
            profile: Profile(
                name: "Olaf Offline",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .red,
                lastAuthenticated: nil,
                erxTasks: []
            ),
            connectionStatus: .disconnected,
            activityIndicating: false
        )

        static let privatePaul = UserProfile(
            from: Profile(
                name: "Private Paul",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                insuranceType: .pKV,
                color: .red,
                lastAuthenticated: nil,
                erxTasks: []
            ),
            isAuthenticated: true
        )
    }
}
