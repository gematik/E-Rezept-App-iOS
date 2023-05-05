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

import Foundation

/// Represents a record of a healthcare consumer’s choices, which permits or denies identified recipient(s) or
/// recipient role(s) to perform one or more actions within a given policy context,
/// for specific purposes and periods of time.
public struct ErxConsent: Identifiable, Hashable {
    /// ErxConsent default initializer
    public init(
        identifier: String,
        insuranceId: String,
        timestamp: String,
        scope: Scope = .patientPrivacy,
        category: Category = .chargcons,
        policyRule: Act = .optIn
    ) {
        self.identifier = identifier
        self.insuranceId = insuranceId
        self.timestamp = timestamp
        self.scope = scope
        self.category = category
        self.policyRule = policyRule
    }

    /// Id of the consent
    public var id: String { identifier }
    /// Identifier of the consent
    public let identifier: String
    /// Health card insurance identifier a.k.a. kvnr (e.g: X764228533)
    public let insuranceId: String
    /// Timestamp of the consent
    public let timestamp: String
    /// A selector of the type of consent being presented
    public let scope: Scope
    /// The associated category of a consent
    public let category: Category

    public let policyRule: Act

    public enum Category: String, Equatable {
        /// Consent for saving electronic charge item
        case chargcons = "CHARGCONS"
    }

    public enum Scope: String, Equatable {
        /// Actions to be taken if they are no longer able to make decisions for themselves
        case adr
        /// Consent to participate in research protocol and information sharing required
        case research
        /// Agreement to collect, access, use or disclose (share) information
        case patientPrivacy = "patient-privacy"
        /// Consent to undergo a specific treatment
        case treatment
    }

    /// A code specifying the particular kind of Act
    public enum Act: String, Equatable {
        case optIn = "OPTIN"
    }
}

extension ErxConsent {
    // sourcery: CodedError = "206"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        /// Unable to construct consent request
        case unableToConstructConsentRequest
        // sourcery: errorCode = "02"
        /// Invalid ErxConsent input
        case invalidErxConsentInput(String)
    }
}
