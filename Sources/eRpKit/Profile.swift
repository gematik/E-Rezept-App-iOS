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

import Foundation
import IDP

/// Represents a user profile selectable within the settings
public struct Profile: Identifiable, Hashable, Equatable, Codable {
    public init(
        name: String,
        identifier: UUID = UUID(),
        created: Date = Date(),
        givenName: String? = nil,
        familyName: String? = nil,
        displayName: String? = nil,
        insurance: String? = nil,
        insuranceId: String? = nil,
        insuranceIK: String? = nil,
        insuranceType: InsuranceType = .unknown,
        color: Color = Color.grey,
        image: ProfilePictureType = .none,
        userImageData: Data? = nil,
        lastAuthenticated: Date? = nil,
        erxTasks: [ErxTask] = [],
        hidePkvConsentDrawerOnMainView: Bool = false,
        shouldAutoUpdateNameAtNextLogin: Bool = false,
        gIdEntry: KKAppDirectory.Entry? = nil
    ) {
        self.name = name
        self.identifier = identifier
        self.created = created
        self.givenName = givenName
        self.familyName = familyName
        self.displayName = displayName ?? ((givenName ?? "") + " " + (familyName ?? ""))
            .trimmingCharacters(in: .whitespaces)
        self.insurance = insurance
        self.insuranceId = insuranceId
        self.insuranceIK = insuranceIK
        self.insuranceType = insuranceType
        self.color = color
        self.image = image
        self.userImageData = userImageData
        self.lastAuthenticated = lastAuthenticated
        self.erxTasks = erxTasks
        self.hidePkvConsentDrawerOnMainView = hidePkvConsentDrawerOnMainView
        self.shouldAutoUpdateNameAtNextLogin = shouldAutoUpdateNameAtNextLogin
        self.gIdEntry = gIdEntry
    }

    public var id: UUID {
        identifier
    }

    public var name: String
    public let identifier: UUID
    public let created: Date
    public var givenName: String?
    public var familyName: String?
    public var displayName: String?
    public var insurance: String?
    public var insuranceId: String?
    public var insuranceIK: String?
    public var insuranceType: InsuranceType
    public var color: Color
    public var image: ProfilePictureType
    public var userImageData: Data?
    public var lastAuthenticated: Date?
    public var erxTasks: [ErxTask]
    // Note: When the list of preferences per Profile keeps growing, consider extracting them to separate struct.
    public var hidePkvConsentDrawerOnMainView: Bool
    public var shouldAutoUpdateNameAtNextLogin: Bool
    public var gIdEntry: KKAppDirectory.Entry?

    public var fullName: String? {
        if displayName != nil {
            return displayName
        } else {
            return [givenName, familyName]
                .compactMap { $0 }
                .joined(separator: " ")
        }
    }

    public var isLinkedToInsuranceId: Bool {
        insuranceId != nil
    }

    public enum InsuranceType: String, Equatable, Codable {
        case unknown
        case gKV
        case pKV
    }

    public enum Color: String, CaseIterable, Codable {
        case grey
        case yellow
        case red
        case green
        case blue

        static var lastUsedColor: Color?

        public static func next() -> Color {
            guard let lastColor = Self.lastUsedColor,
                  let index = Self.allCases.firstIndex(of: lastColor) else {
                let newColor = Self.random()
                Self.lastUsedColor = newColor
                return newColor
            }

            let isLastColor = index == Self.allCases.endIndex - 1
            let nextColor = Self.allCases[isLastColor ? Self.allCases.startIndex : index.advanced(by: 1)]
            Self.lastUsedColor = nextColor
            return nextColor
        }

        private static func random() -> Color {
            var generator = SystemRandomNumberGenerator()
            return Color.random(using: &generator)
        }

        private static func random<G: RandomNumberGenerator>(using generator: inout G) -> Color {
            Color.allCases.randomElement(using: &generator) ?? .grey
        }
    }

    public enum ProfilePictureType: String, CaseIterable, Codable {
        case baby
        case boyWithCard
        case developer
        case doctorFemale
        case pharmacist
        case manWithPhone
        case oldDoctor
        case oldMan
        case oldWoman
        case doctorMale
        case pharmacist2
        case wheelchair
        case womanWithPhone
        case none
    }
}
