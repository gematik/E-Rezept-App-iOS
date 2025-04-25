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

import Combine
import Foundation

public class BiometricsSHA256Signer: JWTSigner {
    let privateKeyContainer: PrivateKeyContainer

    public init(privateKeyContainer: PrivateKeyContainer) {
        self.privateKeyContainer = privateKeyContainer
    }

    var certificates: [Data] {
        [Data()]
    }

    // sourcery: CodedError = "102"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case sessionClosed
        // sourcery: errorCode = "02"
        case signatureFailed
    }

    public func sign(message: Data) async throws -> Data {
        do {
            return try privateKeyContainer.sign(data: message)
        } catch {
            throw Error.signatureFailed
        }
    }
}
