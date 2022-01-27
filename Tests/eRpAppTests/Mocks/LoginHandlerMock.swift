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

import Combine
@testable import eRpApp
import Foundation

// MARK: - LoginHandlerMock -

final class LoginHandlerMock: LoginHandler {
    // MARK: - isAuthenticated

    var isAuthenticatedCallsCount = 0
    var isAuthenticatedCalled: Bool {
        isAuthenticatedCallsCount > 0
    }

    var isAuthenticatedReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedCallsCount += 1
        return isAuthenticatedClosure.map { $0() } ?? isAuthenticatedReturnValue
    }

    // MARK: - isAuthenticatedOrAuthenticate

    var isAuthenticatedOrAuthenticateCallsCount = 0
    var isAuthenticatedOrAuthenticateCalled: Bool {
        isAuthenticatedOrAuthenticateCallsCount > 0
    }

    var isAuthenticatedOrAuthenticateReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedOrAuthenticateClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedOrAuthenticateCallsCount += 1
        return isAuthenticatedOrAuthenticateClosure.map { $0() } ?? isAuthenticatedOrAuthenticateReturnValue
    }
}
