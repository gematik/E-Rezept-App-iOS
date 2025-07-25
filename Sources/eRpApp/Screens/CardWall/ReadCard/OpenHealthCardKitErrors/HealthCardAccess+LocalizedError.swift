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

import Foundation
import HealthCardAccess
import HealthCardControl

extension HealthCard.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .operational:
            return "HealthCard.Error: operational error of the underlying card"
        case let .unexpectedResponse(actual: actual, expected: expected):
            return "HealthCard.Error: unexpected response: actual \(actual), expected: \(expected)"
        case let .unknownCardType(aid: aid):
            return "HealthCard.Error: unknown card type with application identifier: \(aid?.rawValue.hexString() ?? "")"
        case let .illegalGeneration(version: version):
            let description = version.generation()?.description ?? String(describing: version)
            return "HealthCard.Error: illegal card generation of version: \(description)"
        case .unsupportedCardType:
            return "HealthCard.Error: unsupported card type"
        }
    }
}

extension ApplicationIdentifier.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "application identifier has an illegal argument: \(arg)"
        case let .invalidLength(length: length):
            return "application identifier has an invalid length: \(length)"
        }
    }
}

extension FileControlParameter.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "FileControlParameter has an illegal argument: \(arg)"
        case let .asn1ParseError(asn1: asn1, reason: reason):
            return "FileControlParameter asn1 (\(asn1))  parser error with reason: \(reason)"
        case let .invalidCard(description):
            return "FileControlParameter invalid card: \(description)"
        }
    }
}

extension FileIdentifier.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "FileIdentifier.Error: illegal argument: \(arg)"
        case let .invalidLength(length: length):
            return "FileIdentifier.Error: invalid length: \(length)"
        }
    }
}

extension Format2Pin.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "Format2Pin.Error: illegal argument: \(arg)"
        }
    }
}

extension GemCvCertificate.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .unexpected(tag: tag):
            return "GemCvCertificate.Error: unexpected tag \(tag)"
        case let .missing(tag: tag, source: source):
            return "GemCvCertificate.Error: missing tag \(tag) for sourcer \(source)"
        case .missingTagParameter:
            return "GemCvCertificate.Error: missing tag parameter"
        }
    }
}

extension Key.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "Key.Error: illegal argument \(arg)"
        }
    }
}

extension Password.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "Password.Error: illegal argument \(arg)"
        }
    }
}

extension ShortFileIdentifier.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .illegalArgument(arg):
            return "ShortFileIdentifier.Error: illegal argument \(arg)"
        }
    }
}

extension CardVersion2.Error: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .parseError(error):
            return "CardVersion2.Error: parser error \(error)"
        }
    }
}

extension HealthCardCommandBuilder.InvalidArgument: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .offsetOutOfBounds(offset, usingShortFileIdentifier: isShort):
            return """
            HealthCardCommandBuilder.InvalidArgument: offset \(offset) out of bounds.
            Is using short file Identifier: \(isShort)
            """
        case let .recordDataSizeOutOfBounds(data):
            return "HealthCardCommandBuilder.InvalidArgument: record data size out of bounds \(data)"
        case .expectedLengthMustNotBeZero:
            return "HealthCardCommandBuilder.InvalidArgument: expected length must not be zero"
        case let .expectedLengthNotAWildcardValue(length):
            return "HealthCardCommandBuilder.InvalidArgument: expected length \(length) is not a wildcard Value"
        case let .wrongMACLength(length):
            return "HealthCardCommandBuilder.InvalidArgument: wrong MAC length \(length)"
        case let .wrongHashLength(length, expected: expected):
            return "HealthCardCommandBuilder.InvalidArgument: wrong hash length \(length), expected: \(expected)"
        case let .wrongSignatureLength(length, expected: expected):
            return "HealthCardCommandBuilder.InvalidArgument: wrong signature length \(length), expected: \(expected)"
        case let .unsupportedKey(secKey):
            return "HealthCardCommandBuilder.InvalidArgument: unsupported key \(secKey)"
        case let .illegalSize(size, expected: expected):
            return "HealthCardCommandBuilder.InvalidArgument: illegal size \(size). expected size \(expected)"
        case let .illegalValue(value, for: string, expected: expected):
            return """
            HealthCardCommandBuilder.InvalidArgument: illegal value \(value) for \(string). expected: \(expected)
            """
        case let .illegalOid(oid):
            return "HealthCardCommandBuilder.InvalidArgument: illegal Oid \(oid)"
        }
    }
}
