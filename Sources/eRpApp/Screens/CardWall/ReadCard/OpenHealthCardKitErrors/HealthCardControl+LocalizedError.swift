// swiftlint:disable:this file_name
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
import HealthCardControl

extension KeyAgreement.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .illegalArgument:
            return "illegalAgument"
        case .unexpectedFormedAnswerFromCard:
            return "unexpectedFormedAnswerFromCard"
        case .resultOfEcArithmeticWasInfinite:
            return "resultOfEcArithmeticWasInfinite"
        case .macPcdVerificationFailedOnCard:
            return "Wrong CAN (macPcdVerificationFailedOnCard)!"
        case .macPiccVerificationFailedLocally:
            return "macPiccVerificationFailedLocally"
        case .noValidHealthCardStatus:
            return "noValidHealthCardStatus"
        case .efCardAccessNotAvailable:
            return "efCardAccessNotAvailable"
        case let .unsupportedKeyAgreementAlgorithm(identifier):
            return "unsupportedKeyAgreementAlgorithm with identifeir: \(identifier)"
        @unknown default:
            return "unknown KeyAgreement error"
        }
    }
}
