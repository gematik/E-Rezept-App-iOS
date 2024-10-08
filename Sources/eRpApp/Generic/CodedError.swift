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

protocol CodedError: LocalizedError {
    var erpErrorCode: String { get }
    var erpErrorCodeList: [String] { get }
}

extension CodedError {
    var localizedDescriptionWithErrorList: String {
        localizedDescription + "\n\n" + L10n.errCodesPrefix.text + "\n" + erpErrorCodeList.joined(separator: ", ")
    }

    var recoverySuggestionWithErrorList: String {
        if let suggestion = recoverySuggestion {
            return suggestion + "\n\n" + L10n.errCodesPrefix.text + "\n" + erpErrorCodeList.joined(separator: ", ")
        } else {
            return "\n\n" + L10n.errCodesPrefix.text + "\n" + erpErrorCodeList.joined(separator: ", ")
        }
    }

    var descriptionAndSuggestionWithErrorList: String {
        if let suggestion = recoverySuggestion {
            return localizedDescription + "\n" + suggestion + "\n\n" + L10n.errCodesPrefix
                .text + "\n" + erpErrorCodeList.joined(separator: ", ")
        } else {
            return localizedDescriptionWithErrorList
        }
    }
}

extension CodedError {
    func contains(_ error: CodedError) -> Bool {
        erpErrorCodeList.contains(error.erpErrorCode)
    }
}

extension CodedError {
    var analyticsName: String {
        Analytics.Screens.errorAlert.name + erpErrorCodeList.joined(separator: ",")
    }
}
