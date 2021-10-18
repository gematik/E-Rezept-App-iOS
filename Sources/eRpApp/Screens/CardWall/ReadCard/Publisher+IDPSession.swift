//
//  Copyright (c) 2021 gematik GmbH
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
import HealthCardAccess
import HealthCardControl
import IDP

extension Publisher where Self.Output == IDPExchangeToken, Failure == CardWallReadCardDomain.State.Error {
    func exchangeIDPToken(idp: IDPSession,
                          challengeSession: IDPChallengeSession,
                          redirectURI: String? = nil)
        -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> {
        flatMap { token in
            idp
                .exchange(token: token, challengeSession: challengeSession, redirectURI: redirectURI)
                .mapError { CardWallReadCardDomain.State.Error.idpError($0) }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == IDPToken, Failure == CardWallReadCardDomain.State.Error {
    func eraseToCardWallLoginState() -> AnyPublisher<CardWallReadCardDomain.State.Output, Never> {
        map { _ in
            CardWallReadCardDomain.State.Output.loggedIn
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
