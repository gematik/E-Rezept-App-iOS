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

public struct ErxPatient: Hashable, Codable {
    public init(title: String? = nil,
                name: String? = nil,
                address: String? = nil,
                birthDate: String? = nil,
                phone: String? = nil,
                status: String? = nil,
                insurance: String? = nil,
                insuranceId: String? = nil,
                coverageType: CoverageType? = nil) {
        self.title = title
        self.name = name
        self.address = address
        self.birthDate = birthDate
        self.phone = phone
        self.status = status
        self.insurance = insurance
        self.insuranceId = insuranceId
        self.coverageType = coverageType
    }

    /// Degree or Title
    public let title: String?
    /// First and last name of the patient (e.g.: Anna Vetter)
    public let name: String?
    /// Full address incl. street, city, postcode
    public let address: String?
    /// Patient birthdate (e.g.: 2010-01-31)
    public let birthDate: String?
    /// Patient phone number
    public let phone: String?
    /// Contract status (e.g.: 3 == family)
    public let status: String?
    /// Name of the health insurance (e.g.:  IT Versicherung)
    public let insurance: String?
    /// Health card insurance identifier a.k.a. kvnr (e.g: X764228533)
    public let insuranceId: String?
    /// Patient type of coverage (e.g.: SEL = Selbstzahler)
    public let coverageType: CoverageType?
}

extension ErxPatient {
    /// https://simplifier.net/packages/de.basisprofil.r4/1.5.0/files/2461199/
    public enum CoverageType: String, Codable, Equatable, Hashable {
        public enum CodingKeysV2 {
            public static var gesetzlicheKrankenversicherung = "GKV"
            public static var privateKrankenversicherung = "PKV"
            public static var Berufsgenossenschaft = "BG"
            public static var Selbstzahler = "SEL"
            public static var Sozialamt = "SOZ"
            public static var gesetzlichePflegeversicherung = "GPV"
            public static var PrivatePflegeversicherung = "PPV"
            public static var Beihilfe = "BEI"
        }

        /// gesetzliche Krankenversicherung
        case GKV
        /// private Krankenversicherung
        case PKV
        /// Berufsgenossenschaft
        case BG // swiftlint:disable:this identifier_name
        /// Selbstzahler
        case SEL
        /// Sozialamt
        case SOZ
        /// gesetzliche Pflegeversicherung
        case GPV
        /// private Pflegeversicherung
        case PPV
        /// Beihilfe
        case BEI

        public init?(rawValue: String?) {
            guard let rawValue = rawValue else { return nil }
            switch rawValue {
            case CodingKeysV2.gesetzlicheKrankenversicherung: self = .GKV
            case CodingKeysV2.privateKrankenversicherung: self = .PKV
            case CodingKeysV2.Berufsgenossenschaft: self = .BG
            case CodingKeysV2.Selbstzahler: self = .SEL
            case CodingKeysV2.Sozialamt: self = .SOZ
            case CodingKeysV2.gesetzlichePflegeversicherung: self = .GPV
            case CodingKeysV2.PrivatePflegeversicherung: self = .PPV
            case CodingKeysV2.Beihilfe: self = .BEI
            default: return nil
            }
        }

        public var rawValue: String? {
            switch self {
            case .GKV: return CodingKeysV2.gesetzlicheKrankenversicherung
            case .PKV: return CodingKeysV2.privateKrankenversicherung
            case .BG: return CodingKeysV2.Berufsgenossenschaft
            case .SEL: return CodingKeysV2.Selbstzahler
            case .SOZ: return CodingKeysV2.Sozialamt
            case .GPV: return CodingKeysV2.gesetzlichePflegeversicherung
            case .PPV: return CodingKeysV2.PrivatePflegeversicherung
            case .BEI: return CodingKeysV2.Beihilfe
            }
        }
    }
}
