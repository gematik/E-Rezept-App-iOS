// swiftlint:disable:this file_name
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

import CardReaderProviderApi
import Foundation

extension CardError: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .securityError(error):
            return error?.localizedDescription ?? "CardError.securityError \(String(describing: error))"
        case let .connectionError(error):
            return error?.localizedDescription ?? "CardError.connectionError \(String(describing: error))"
        case let .illegalState(error):
            return error?.localizedDescription ?? "CardError.illegalState \(String(describing: error))"
        case let .objcError(exception):
            return exception?.description ?? "CardError.objcError with exception \(String(describing: exception))"
        }
    }
}

extension APDU.Error: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .commandBodyDataTooLarge:
            return "command body data is too large"
        case .expectedResponseLengthOutOfBounds:
            return "expected response length out of bounds"
        case let .insufficientResponseData(data: data):
            return "insufficient response data: \(data)"
        }
    }
}
