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
import SwiftUI

struct OrderHealthCardInquiryView: View {
    let store: OrderHealthCardDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, OrderHealthCardDomain.Action>

    init(store: OrderHealthCardDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: OrderHealthCardDomain.Destinations.State.Tag?

        init(state: OrderHealthCardDomain.State) {
            routeTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Spacer()

                Image(Asset.OrderEGK.blueEGK)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 240, height: 240)

                Text(L10n.orderEgkServiceTitle)
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(Color(.label))
                    .padding()
                    .multilineTextAlignment(.center)

                Text(L10n.orderEgkServiceSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Group {
                    Button(action: {
                        viewStore.send(.setService(service: .pin))
                    }, label: {
                        HStack {
                            Text(L10n.orderEgkPin)
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Colors.systemLabel)
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier(A11y.cardWall.intro.cdwBtnIntroLater)

                            Spacer(minLength: 8)
                            Image(systemName: SFSymbolName.rightDisclosureIndicator)
                                .font(Font.headline.weight(.semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                                .padding(8)
                        }
                        .padding()
                    })
                        .buttonStyle(DefaultButtonStyle())
                        .background(Colors.systemBackgroundTertiary)
                        .border(Colors.separator, width: 0.5, cornerRadius: 16)
                        .padding()

                    Button(action: {
                        viewStore.send(.setService(service: .healthCardAndPin))
                    }, label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.orderEgkPinCard)
                                    .font(Font.body.weight(.bold))
                                    .foregroundColor(Colors.systemLabel)
                            }
                            .multilineTextAlignment(.leading)

                            Spacer(minLength: 8)
                            Image(systemName: SFSymbolName.rightDisclosureIndicator)
                                .font(Font.headline.weight(.semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                                .padding(8)
                        }
                        .padding()
                    })
                        .buttonStyle(DefaultButtonStyle())
                        .background(Colors.systemBackgroundTertiary)
                        .border(Colors.separator, width: 0.5, cornerRadius: 16)
                        .padding([.trailing, .leading, .bottom])
                }

                NavigationLink(
                    isActive: .init(
                        get: {
                            viewStore.routeTag != .searchPicker && viewStore.routeTag != .serviceInquiry
                        },
                        set: { active in
                            if active {
                                // Handled by Domain
                            } else {
                                viewStore.send(.setNavigation(tag: .serviceInquiry))
                            }
                        }
                    ),
                    destination: {
                        OrderHealthCardContactView(store: store)
                    },
                    label: {
                        EmptyView()
                    }
                )
                .accessibility(hidden: true)
            }
        }
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.delegate(.close))
            }
            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
            .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
        )
    }
}

struct OrderHealthCardInquiryView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHealthCardInquiryView(store: OrderHealthCardDomain.Dummies.store)
        }
    }
}
