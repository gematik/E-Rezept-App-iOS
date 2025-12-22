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
// swiftlint:disable file_length

import Foundation
import IDP

public class JWTSignerMock: JWTSigner {
    public init() {}

    // MARK: - sign

    public var signMessageDataDataThrowableError: (any Error)?
    public var signMessageDataDataCallsCount = 0
    public var signMessageDataDataCalled: Bool {
        signMessageDataDataCallsCount > 0
    }

    public var signMessageDataDataReceivedMessage: (Data)?
    public var signMessageDataDataReceivedInvocations: [Data] = []
    public var signMessageDataDataReturnValue: Data!
    public var signMessageDataDataClosure: ((Data) async throws -> Data)?

    public func sign(message: Data) async throws -> Data {
        signMessageDataDataCallsCount += 1
        signMessageDataDataReceivedMessage = message
        signMessageDataDataReceivedInvocations.append(message)
        if let error = signMessageDataDataThrowableError {
            throw error
        }
        if let signMessageDataDataClosure = signMessageDataDataClosure {
            return try await signMessageDataDataClosure(message)
        } else {
            return signMessageDataDataReturnValue
        }
    }
}
