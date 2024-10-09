// swiftlint:disable:this file_name
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
import Pharmacy

extension PharmacyFHIRDataSource.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .fhirClient(error):
            return error.localizedDescription
        case .notFound:
            return L10n.phaSearchTxtLocalPharmErrNotFound.text
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .fhirClient(error):
            return error.recoverySuggestion
        case .notFound:
            return L10n.phaSearchTxtLocalPharmErrNotFoundRecovery.text
        }
    }
}

extension PharmacyRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .local(localError):
            return localError.localizedDescription
        case let .remote(remoteError):
            return remoteError.localizedDescription
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .local(localError):
            return localError.recoverySuggestion
        case let .remote(remoteError):
            return remoteError.recoverySuggestion
        }
    }
}
