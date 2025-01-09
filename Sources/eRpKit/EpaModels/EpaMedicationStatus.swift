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

/// This code system http://hl7.org/fhir/CodeSystem/medication-status defines the following codes:
public enum EpaMedicationStatus: String, Equatable, Codable, Sendable {
    // The medication is available for use.
    case active
    // "The medication is not available for use.
    case inactive
    // The medication was entered in error.
    case enteredInError = "entered-in-error"
}
