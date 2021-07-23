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

import ComposableArchitecture
import SwiftUI

/// Defines available routing endpoints within the CardWall modal.
enum CardWallRoute {
    case intro
    case capabilitiesMissing
    case enterCAN
    case enterPIN
    case loginOption
    case readCard
    case none
}

/// Conforming types provide navigational context.
protocol Navigating {
    associatedtype Context

    func next(with context: Context) -> Self
}

extension CardWallRoute: Navigating {
    init(with context: CardWallDomain.State) {
        self = CardWallRoute.none.next(with: context)
    }

    func next(with context: CardWallDomain.State) -> CardWallRoute {
        switch self {
        case .none:
            if context.introAlreadyDisplayed {
                return CardWallRoute.intro.next(with: context)
            } else {
                return .intro
            }
        case .intro:
            if !context.isCapable {
                return .capabilitiesMissing
            } else {
                if context.canAvailable {
                    return .enterPIN
                } else {
                    return .enterCAN
                }
            }
        case .capabilitiesMissing:
            return .none
        case .enterCAN:
            return .enterPIN
        case .enterPIN:
            return .loginOption
        case .loginOption:
            return .readCard
        case .readCard:
            return .none
        }
    }
}

extension CardWallRoute {
    func provideView(state: CardWallDomain.State,
                     store: CardWallDomain.Store) -> AnyView {
        switch self {
        case .intro:
            return introViewFor(state: state,
                                store: store)
        case .capabilitiesMissing:
            return AnyView(CapabilitiesView(store: store))
        case .enterCAN:
            return canViewFor(state: state, store: store)
        case .enterPIN:
            return pinViewFor(state: state, store: store)
        case .loginOption:
            return loginOptionViewFor(state: state, store: store)
        case .readCard:
            return readCardViewFor(store: store)
        case .none:
            return AnyView(EmptyView())
        }
    }

    private func introViewFor(state: CardWallDomain.State,
                              store: CardWallDomain.Store) -> AnyView {
        AnyView(
            CardWallIntroductionView(
                store: store.scope(
                    state: \.introduction,
                    action: CardWallDomain.Action.introduction(action:)
                )
            ) {
                next(with: state).provideView(state: state, store: store)
            }
        )
    }

    private func canViewFor(state: CardWallDomain.State,
                            store: CardWallDomain.Store) -> AnyView {
        AnyView(
            IfLetStore(
                store.scope(
                    state: \.can,
                    action: CardWallDomain.Action.canAction(action:)
                ),
                then: { canStore in
                    CardWallCANView(
                        store: canStore,
                        nextView: next(with: state).provideView(state: state, store: store)
                    )
                },
                else: { EmptyView() }
            )
        )
    }

    private func pinViewFor(state: CardWallDomain.State,
                            store: CardWallDomain.Store) -> AnyView {
        AnyView(
            CardWallPINView(
                store: store.scope(
                    state: \.pin,
                    action: CardWallDomain.Action.pinAction(action:)
                )
            ) { _ in
                next(with: state).provideView(state: state, store: store)
            }
        )
    }

    private func loginOptionViewFor(state: CardWallDomain.State,
                                    store: CardWallDomain.Store) -> AnyView {
        AnyView(
            CardWallLoginOptionView(
                store: store.scope(
                    state: \.loginOption,
                    action: CardWallDomain.Action.loginOption(action:)
                )
            ) {
                next(with: state).provideView(state: state, store: store)
            }
        )
    }

    private func readCardViewFor(store: CardWallDomain.Store) -> AnyView {
        AnyView(
            IfLetStore(
                store.scope(
                    state: \.readCard,
                    action: CardWallDomain.Action.readCard(action:)
                )
            ) { store in
                CardWallReadCardView(store: store)
            }
        )
    }
}
