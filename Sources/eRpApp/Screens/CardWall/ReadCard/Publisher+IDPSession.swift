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
import IDP

extension Publisher where Self.Output == IDPExchangeToken, Failure == IDPError {
    func exchangeIDPToken(idp: IDPSession,
                          challengeSession: IDPChallengeSession,
                          idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)
        -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> {
        flatMap { token in
            idp
                .exchange(
                    token: token,
                    challengeSession: challengeSession,
                    idTokenValidator: idTokenValidator
                )
        }
        .mapError { error in
            if case let .unspecified(error) = error,
               let validationError = error as? IDTokenValidatorError {
                return .profileValidation(validationError)
            } else {
                return .idpError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == IDPToken, Failure == CardWallReadCardDomain.State.Error {
    func eraseToCardWallLoginState() -> AnyPublisher<CardWallReadCardDomain.State.Output, Never> {
        map { idpToken in
            CardWallReadCardDomain.State.Output.loggedIn(idpToken)
        }
        .catch { error in
            Just(
                CardWallReadCardDomain.State
                    .Output.verifying(.error(error))
            )
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
