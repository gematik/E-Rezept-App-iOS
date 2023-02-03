//
//  Copyright (c) 2023 gematik GmbH
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

import DataKit
import eRpKit
import Foundation
import IDP

struct UserProfile: ProfileCellModel, Equatable, Identifiable {
    var id: UUID { profile.id }

    var name: String { profile.name }
    let acronym: String

    var fullName: String? { profile.fullName }
    var insurance: String? { profile.insurance }
    var insuranceId: String? { profile.insuranceId }

    var emoji: String? { profile.emoji }
    var color: ProfileColor { profile.color.viewModelColor }

    var lastSuccessfulSync: Date? { profile.lastAuthenticated }

    let profile: Profile
    let connectionStatus: ProfileConnectionStatus
    let activityIndicating: Bool

    init(profile: Profile, connectionStatus: ProfileConnectionStatus, activityIndicating: Bool) {
        self.profile = profile
        acronym = profile.name.acronym()
        self.connectionStatus = connectionStatus
        self.activityIndicating = activityIndicating
    }
}

extension UserProfile {
    init(from profile: Profile, token: IDPToken?, activityIndicating: Bool = false) {
        self.init(
            profile: profile,
            connectionStatus: Self.connectionStatus(for: token, lastAuthenticated: profile.lastAuthenticated),
            activityIndicating: activityIndicating
        )
    }

    init(from profile: Profile, isAuthenticated: Bool, activityIndicating: Bool = false) {
        self.init(
            profile: profile,
            connectionStatus: Self.connectionStatus(for: isAuthenticated, lastAuthenticated: profile.lastAuthenticated),
            activityIndicating: activityIndicating
        )
    }

    struct SSOTokenHeader: Claims, Decodable {
        public let exp: Date?
    }

    private static func connectionStatus(
        for isAuthenticated: Bool,
        lastAuthenticated: Date?
    ) -> ProfileConnectionStatus {
        if isAuthenticated {
            return .connected
        }
        if lastAuthenticated != nil {
            return .disconnected
        }
        return .never
    }

    private static func connectionStatus(for token: IDPToken?, lastAuthenticated: Date?) -> ProfileConnectionStatus {
        if let ssoToken = token?.ssoToken?.data(using: .utf8) {
            let elements = ssoToken.split(separator: 0x2E, omittingEmptySubsequences: false)
            if let header = elements.first,
               let decodedHeader = try? Base64.decode(data: header),
               let tokenHeader = try? JSONDecoder().decode(SSOTokenHeader.self, from: decodedHeader),
               tokenHeader.exp?.compare(Date()) == .orderedDescending {
                return .connected
            }
        }
        if token?.expires.compare(Date()) == .orderedDescending {
            return .connected
        }
        if lastAuthenticated != nil {
            return .disconnected
        }
        return .never
    }
}

extension UserProfile {
    enum Dummies {
        static let profileA = UserProfile(
            from: Profile(
                name: "Spooky Dennis",
                identifier: UUID(),
                created: Date(),
                givenName: "Dennis",
                familyName: "Doe",
                insurance: "Spooky BKK",
                insuranceId: "X112233445",
                color: .blue,
                emoji: "🎃",
                lastAuthenticated: Date().addingTimeInterval(-60 * 8),
                erxTasks: []
            ),
            isAuthenticated: true
        )
        static let profileB = UserProfile(
            from: Profile(
                name: "Gruseliger Günther",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .blue,
                emoji: "💀",
                lastAuthenticated: nil,
                erxTasks: []
            ),
            isAuthenticated: false
        )
        static let profileC = UserProfile(
            from: Profile(
                name: "Spooky Gerald",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .blue,
                emoji: "🎃",
                lastAuthenticated: Date().addingTimeInterval(-60 * 60 * 1.5),
                erxTasks: []
            ),
            isAuthenticated: false
        )
        static let profileD = UserProfile(
            from: Profile(
                name: "Everloading Evan",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .yellow,
                emoji: "🎃",
                lastAuthenticated: Date().addingTimeInterval(-60 * 60 * 1.5),
                erxTasks: []
            ),
            isAuthenticated: true,
            activityIndicating: true
        )
    }
}
