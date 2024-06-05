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

import CoreNFC
import NFCCardReaderProvider

extension NFCTagReaderSession.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotInitializeSession:
            return "NFCTagReaderSession could not be initialized"
        case .unsupportedTag:
            return "NFCTagReaderSession.Error: The read tag is not supported"
        case let .nfcTag(error: error):
            switch error {
            case let .tagConnectionLost(readerError):
                return readerError.localizedDescription
            case let .sessionTimeout(readerError):
                return readerError.localizedDescription
            case let .sessionInvalidated(readerError):
                return readerError.localizedDescription

            case let .userCanceled(readerError):
                return readerError.localizedDescription

            case let .unsupportedFeature(readerError):
                return readerError.localizedDescription

            case let .other(readerError):
                return readerError.localizedDescription

            case let .unknown(error):
                return error.localizedDescription
            }
        }
    }
}

extension NFCCardError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noCardPresent:
            return "NFCCardError: no card present"
        case let .transferException(name: name):
            return "NFCCardError: transfer exception with name: \(name)"
        case .sendTimeout:
            return "NFCCardError: send timeout"
        case let .nfcTag(error: error):
            switch error {
            case let .tagConnectionLost(readerError):
                return readerError.localizedDescription
            case let .sessionTimeout(readerError):
                return readerError.localizedDescription
            case let .sessionInvalidated(readerError):
                return readerError.localizedDescription
            case let .userCanceled(readerError):
                return readerError.localizedDescription
            case let .unsupportedFeature(readerError):
                return readerError.localizedDescription
            case let .other(readerError):
                return readerError.localizedDescription
            case let .unknown(error):
                return error.localizedDescription
            }
        }
    }
}

extension CoreNFCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .tagConnectionLost:
            return L10n.ohcTxtNfcErrorTagLostDescription.text
        case .sessionTimeout:
            return L10n.ohcTxtNfcErrorSessionTimeoutDescription.text
        case .sessionInvalidated:
            return L10n.ohcTxtNfcErrorInvalidatedDescription.text
        case .userCanceled:
            return nil
        case .unsupportedFeature:
            return L10n.ohcTxtNfcErrorUnsupportedDescription.text
        case .other, .unknown:
            return L10n.cdwTxtRcErrorGenericCardDescription.text
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .tagConnectionLost:
            return L10n.ohcTxtNfcErrorTagLostRecovery.text
        case .sessionTimeout:
            return L10n.ohcTxtNfcErrorSessionTimeoutRecovery.text
        case .sessionInvalidated:
            return L10n.ohcTxtNfcErrorInvalidatedRecovery.text
        case .userCanceled:
            return nil
        case .unsupportedFeature:
            return L10n.ohcTxtNfcErrorUnsupportedRecovery.text
        case .other, .unknown:
            return L10n.cdwTxtRcErrorGenericCardRecovery.text
        }
    }
}

extension CoreNFCError: CodedError {
    var erpErrorCode: String {
        switch self {
        case .tagConnectionLost:
            return "i-60001"
        case .sessionTimeout:
            return "i-60002"
        case .sessionInvalidated:
            return "i-60003"
        case .userCanceled:
            return "i-60004"
        case .unsupportedFeature:
            return "i-60005"
        case .other:
            return "i-60006"
        case .unknown:
            return "i-60007"
        }
    }

    var erpErrorCodeList: [String] {
        switch self {
        case let .tagConnectionLost(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .sessionTimeout(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .sessionInvalidated(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .userCanceled(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .unsupportedFeature(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .other(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        case let .unknown(error as CodedError):
            return [erpErrorCode] + error.erpErrorCodeList
        default:
            return [erpErrorCode]
        }
    }
}
