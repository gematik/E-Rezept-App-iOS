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
            // sourcery: AnalyticsScreen = redeem_success
            case redeemSuccess(RedeemSuccessDomain.State)
            // sourcery: AnalyticsScreen = redeem_editContactInformation
            case contact(PharmacyContactDomain.State)
            // sourcery: AnalyticsScreen = cardWall
            case cardWall(CardWallIntroductionDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case redeemSuccessView(action: RedeemSuccessDomain.Action)
            case pharmacyContact(action: PharmacyContactDomain.Action)
            case cardWall(action: CardWallIntroductionDomain.Action)
            case alert(Alert)

            enum Alert: Equatable {
                case dismiss
                case contact
            }
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
