//
//  Copyright (c) 2025 gematik GmbH
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

/// Structure is based on https://simplifier.net/evdga/kbv_pr_evdga_healthapprequest
public struct ErxDeviceRequest: Equatable, Hashable, Codable, Sendable {
    public init(
        status: DeviceRequestStatus? = nil,
        intent: DeviceRequestIntent? = nil,
        pzn: String? = nil,
        appName: String? = nil,
        isSER: Bool? = false,
        accidentInfo: AccidentInfo? = nil,
        authoredOn: String? = nil,
        diGaInfo: DiGaInfo? = nil
    ) {
        self.status = status
        self.intent = intent
        self.pzn = pzn
        self.appName = appName
        self.isSER = isSER ?? false
        self.accidentInfo = accidentInfo
        self.authoredOn = authoredOn
        self.diGaInfo = diGaInfo
    }

    /// status of the request.
    public let status: DeviceRequestStatus?
    /// intent of the request
    public let intent: DeviceRequestIntent?
    /// (PZN) of the DiGA prescription
    public let pzn: String?
    /// Name of the DiGA
    public let appName: String?
    /// Relation to social compensation law
    public let isSER: Bool
    /// Work-related accident info
    public let accidentInfo: AccidentInfo?
    /// When the deviceRequest was authored
    public let authoredOn: String?
    /// Information about the DiGa that are saved local
    public var diGaInfo: DiGaInfo?

    // This code system http://hl7.org/fhir/request-status defines the following codes:
    public enum DeviceRequestStatus: String, Equatable, Codable, Sendable {
        /// request has been created but is not yet complete or ready for action.
        case draft
        /// The request is in force and ready to be acted upon.
        case active
        /// The request has been temporarily withdrawn but is expected to resume in the future.
        case onHold = "on-hold"
        /// The request has been terminated prior. No further activity should occur.
        case revoked
        /// The request has been fully performed. No further activity will occur.
        case completed
        /// This request should never have existed and should be considered 'void'.
        /// If real-world activity has occurred, the status should be "revoked"
        case enteredInError = "entered-in-error"
        /// The authoring/source system does not know which of the status values currently applies for this request.
        case unknown
    }

    /// This code system http://hl7.org/fhir/request-intent defines the following codes:
    public enum DeviceRequestIntent: String, Equatable, Codable, Sendable {
        /// a suggestion made by someone/something that does not have an intention to ensure it occurs and
        /// without providing an authorization to act.
        case proposal
        /// The request represents an intention to ensure something occurs without providing an authorization for others
        case plan
        /// The request represents a legally binding instruction authored by a Patient or RelatedPerson.
        case directive
        /// The request represents a request/demand and authorization for action by a Practitioner.
        case order
        /// The request represents an original authorization for action.
        case originalOrder = "original-order"
        /// The request represents an automatically generated supplemental authorization for action based on a parent
        /// authorization together with initial results of the action taken against that parent authorization.
        case reflexOrder = "reflex-order"
        /// The request represents the view of an authorization instantiated by a fulfilling system representing
        /// the details of the fulfiller's intention to act upon a submitted order.
        case fillerOrder = "filler-order"
        /// An order created in fulfillment of a broader order that represents the authorization for a single activity
        /// occurrence.  E.g. The administration of a single dose of a drug.
        case instanceOrder = "instance-order"
        /// The request represents a component or option for a RequestGroup among a set of requests.
        /// Refer to [[[RequestGroup]]] for additional information on how this status is used.
        case option
    }
}
