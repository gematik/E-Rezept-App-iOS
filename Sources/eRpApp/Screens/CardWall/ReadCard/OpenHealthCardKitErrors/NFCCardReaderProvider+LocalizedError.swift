// swiftlint:disable:this file_name
//
//  Copyright (c) 2022 gematik GmbH
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
            return "NFCTagReaderSession could not be initalized"
        case .unsupportedTag:
            return "NFCTagReaderSession.Error: The read tag is not supported"
        case let .nfcTag(error: error):
            return error.localizedDescription
        case let .userCancelled(error: error):
            return error.localizedDescription
        @unknown default:
            return "unknown NFCTagReaderSession.Error"
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
        @unknown default:
            return "unknown NFCCardError"
        }
    }
}
