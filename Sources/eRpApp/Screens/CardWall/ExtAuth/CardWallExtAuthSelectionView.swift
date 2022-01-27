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

import ComposableArchitecture
import IDP
import SwiftUI

struct CardWallExtAuthSelectionView: View {
    let store: CardWallExtAuthSelectionDomain.Store
    @ObservedObject
    var viewStore: ViewStore<CardWallExtAuthSelectionDomain.State, CardWallExtAuthSelectionDomain.Action>

    init(store: CardWallExtAuthSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let error = viewStore.state.error {
                ErrorView(error: error) {
                    viewStore.send(.loadKKList, animation: .default)
                }
                .padding()
            } else {
                List {
                    if let kkList = viewStore.kkList {
                        Section(header: Header {
                            viewStore.send(.showOrderEgk(true))
                        }) {
                            ForEach(kkList.apps) { app in
                                Button(action: {
                                    viewStore.send(.selectKK(app))
                                }, label: {
                                    HStack {
                                        Text(app.name)
                                            .foregroundColor(Color(.label))

                                        Spacer()

                                        if viewStore.selectedKK?.identifier == app.identifier {
                                            Image(systemName: SFSymbolName.checkmark)
                                        }
                                    }.contentShape(Rectangle())
                                })
                            }
                        }
                        .textCase(.none)
                    } else {
                        Section(header: CenteredActivityIndicator()) {}
                    }
                }
                .listStyle(GroupedListStyle())
                .introspectTableView { tableView in
                    tableView.separatorStyle = .none
                    tableView.tableHeaderView = nil
                    tableView.backgroundColor = UIColor.systemBackground
                }
                .listStyle(PlainListStyle())

                Spacer()

                GreyDivider()

                PrimaryTextButton(
                    text: L10n.cdwBtnExtauthSelectionContinue,
                    a11y: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionConfirm,
                    isEnabled: viewStore.state.selectedKK != nil
                ) {
                    viewStore.send(.confirmKK)
                }
                .padding()

                EmptyView()
                    .sheet(isPresented: viewStore.binding(
                        get: \.orderEgkVisible,
                        send: CardWallExtAuthSelectionDomain.Action.showOrderEgk
                    )) {
                        NavigationView {
                            OrderHealthCardView {
                                viewStore.send(.showOrderEgk(false))
                            }
                        }.navigationViewStyle(StackNavigationViewStyle())
                    }
            }

            NavigationLink(
                destination: IfLetStore(store.scope(
                    state: \.confirmation,
                    action: CardWallExtAuthSelectionDomain.Action.confirmation
                ),
                then: CardWallExtAuthConfirmationView.init),
                isActive: Binding<Bool>(get: {
                    viewStore.confirmation != nil
                }, set: { value in
                    if !value {
                        viewStore.send(.hideConfirmation)
                    }
                })
            ) {}
        }
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.close)
            }
            .accessibility(identifier: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionCancel)
            .accessibility(label: Text(L10n.cdwBtnExtauthSelectionCancel))
        )
        .navigationTitle(L10n.cdwTxtExtauthSelectionTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewStore.send(.loadKKList)
        }
    }

    struct CenteredActivityIndicator: View {
        var body: some View {
            HStack {
                Spacer()
                ActivityIndicator(shouldAnimate: true, hideWhenStopped: true)
                Spacer()
            }
        }
    }

    struct Header: View {
        var action: () -> Void
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.cdwTxtExtauthSelectionHeadline)
                    .font(Font.title3.bold())
                    .foregroundColor(Color(.label))
                    .padding(.vertical, 8)

                Text(L10n.cdwTxtExtauthSelectionDescription)
                    .font(Font.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)

                TertiaryListButton(
                    text: L10n.cdwBtnExtauthSelectionOrderEgk,
                    imageName: nil,
                    accessibilityIdentifier: A11y.orderEGK.ogkBtnEgkInfo
                ) {
                    action()
                }
            }
            .padding(.bottom, 16)
        }
    }
}

extension CardWallExtAuthSelectionView {
    private struct ErrorView: View {
        let error: LocalizedError
        let action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
                    .font(.headline)

                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                } else {
                    Text(L10n.cdwTxtExtauthSelectionErrorFallback)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }

                Button(action: action) {
                    Text(L10n.cdwBtnExtauthSelectionRetry)
                        .font(.subheadline)
                }
                .accessibility(identifier: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionRetry)
            }
        }
    }
}

struct CardWallExtAuthSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallExtAuthSelectionView(store: CardWallExtAuthSelectionDomain.Store(
                initialState:
                .init(kkList: .init(apps: [
                    .init(name: "Gematik KK", identifier: "abc"),
                    .init(name: "Other KK", identifier: "def"),
                    .init(name: "Yet Another KK", identifier: "ghi"),
                ]),
                error: nil,
                selectedKK: .init(name: "Other KK", identifier: "def")),
                reducer: .empty,
                environment: CardWallExtAuthSelectionDomain.Dummies.environment
            ))
        }
    }
}
