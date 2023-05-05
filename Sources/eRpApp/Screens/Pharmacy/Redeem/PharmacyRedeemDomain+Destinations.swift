//
//  Copyright (c) 2023 gematik GmbH
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

import ComposableArchitecture

extension PharmacyRedeemDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case redeemSuccess(RedeemSuccessDomain.State)
            case contact(PharmacyContactDomain.State)
            case cardWall(CardWallIntroductionDomain.State)
            case alert(ErpAlertState<PharmacyRedeemDomain.Action>)
        }

        enum Action: Equatable {
            case redeemSuccessView(action: RedeemSuccessDomain.Action)
            case pharmacyContact(action: PharmacyContactDomain.Action)
            case cardWall(action: CardWallIntroductionDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.redeemSuccess,
                action: /Action.redeemSuccessView
            ) {
                RedeemSuccessDomain()
            }
            Scope(
                state: /State.contact,
                action: /Action.pharmacyContact
            ) {
                PharmacyContactDomain()
            }
            Scope(
                state: /State.cardWall,
                action: /Action.cardWall
            ) {
                CardWallIntroductionDomain()
            }
        }
    }
}
