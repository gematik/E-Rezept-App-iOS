//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Foundation

/// Protocol for types that have error codes
public protocol CodedError: LocalizedError {
    /// The error code for this specific error instance
    var erpErrorCode: String { get }
    /// List of error codes including nested error codes from associated values
    var erpErrorCodeList: [String] { get }
}

extension CodedError {
    /// Returns the localized description with the list of error codes appended
    public var localizedDescriptionWithErrorList: String {
        localizedDescription + "\n\n" + l10n("err_codes_prefix") + "\n" + erpErrorCodeList.joined(separator: ", ")
    }

    /// Returns the recovery suggestion with the list of error codes appended
    public var recoverySuggestionWithErrorList: String {
        if let suggestion = recoverySuggestion {
            return suggestion + "\n\n" + l10n("err_codes_prefix") + "\n" + erpErrorCodeList.joined(separator: ", ")
        } else {
            return "\n\n" + l10n("err_codes_prefix") + "\n" + erpErrorCodeList.joined(separator: ", ")
        }
    }

    /// Returns the description and suggestion with the list of error codes appended
    public var descriptionAndSuggestionWithErrorList: String {
        if let suggestion = recoverySuggestion {
            return localizedDescription + "\n" + suggestion + "\n\n" + l10n("err_codes_prefix")
                + "\n" + erpErrorCodeList.joined(separator: ", ")
        } else {
            return localizedDescriptionWithErrorList
        }
    }
}

extension CodedError {
    /// Check if this error contains another error by comparing error codes
    public func contains(_ error: CodedError) -> Bool {
        erpErrorCodeList.contains(error.erpErrorCode)
    }
}

/// A macro that generates CodedError conformance for enums with error code annotations.
/// For example:
///
///     @CodedError("029")
///     enum Error: Swift.Error {
///         @ErrorCode("01")
///         case someError
///     }
///
/// This will generate a CodedError extension with erpErrorCode and erpErrorCodeList properties.
@attached(extension, conformances: CodedError, names: named(erpErrorCode),
          named(erpErrorCodeList)) // swiftlint:disable:previous attributes
public macro CodedError(_ baseErrorCode: String) = #externalMacro(module: "CodedErrorMacros", type: "CodedErrorMacro")

/// A macro that annotates enum cases with specific error codes.
/// This macro works in conjunction with @CodedError to specify the error code for each case.
/// For example:
///
///     @CodedError("029")
///     enum Error: Swift.Error {
///         @ErrorCode("01")
///         case someError
///
///         @ErrorCode("02")
///         case anotherError
///     }
@attached(peer)
public macro ErrorCode(_ code: String) = #externalMacro(module: "CodedErrorMacros", type: "ErrorCodeMacro")
