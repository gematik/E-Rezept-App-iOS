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
import IDP
import SwiftUI

struct CardWallExtAuthSelectionView: View {
    let store: CardWallExtAuthSelectionDomain.Store
    @ObservedObject
    var viewStore: ViewStore<ViewState, CardWallExtAuthSelectionDomain.Action>

    init(store: CardWallExtAuthSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: CardWallExtAuthSelectionDomain.Route.Tag?
        let error: IDPError?
        let kkList: KKAppDirectory?
        let selectedKK: KKAppDirectory.Entry?
        var filteredKKList: KKAppDirectory
        var searchText: String

        init(state: CardWallExtAuthSelectionDomain.State) {
            routeTag = state.route?.tag
            error = state.error
            kkList = state.kkList
            selectedKK = state.selectedKK
            filteredKKList = state.filteredKKList
            searchText = state.searchText
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let error = viewStore.error {
                ErrorView(error: error) {
                    viewStore.send(.loadKKList, animation: .default)
                }
                .padding()
            } else {
                if viewStore.kkList == nil {
                    List {
                        Section(header: CenteredActivityIndicator()) {}
                            .listStyle(GroupedListStyle())
                            .introspectTableView { tableView in
                                tableView.separatorStyle = .none
                                tableView.tableHeaderView = nil
                                tableView.backgroundColor = UIColor.systemBackground
                            }
                            .listStyle(PlainListStyle())
                    }
                } else if let kkList = viewStore.kkList,
                          !kkList.apps.isEmpty {
                    SearchBar(
                        searchText: viewStore.binding(get: \.searchText) { .updateSearchText(newString: $0) },
                        prompt: L10n.cdwTxtExtauthSearchprompt.key
                    ) {}
                        .padding()

                    List {
                        Section(header: Header {
                            viewStore.send(.setNavigation(tag: .egk))
                        }) {
                            if !viewStore.filteredKKList.apps.isEmpty {
                                ForEach(viewStore.filteredKKList.apps) { app in
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
                            } else {
                                VStack {
                                    Text(L10n.cdwTxtExtauthNoresultsTitle)
                                        .font(.headline)
                                        .padding(.bottom, 1)
                                    Text(L10n.cdwTxtExtauthNoresults)
                                        .font(.subheadline)
                                        .foregroundColor(Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .textCase(.none)
                    }
                    .onAppear {
                        viewStore.send(.reset)
                    }
                    .listStyle(GroupedListStyle())
                    .introspectTableView { tableView in
                        tableView.separatorStyle = .none
                        tableView.tableHeaderView = nil
                        tableView.backgroundColor = UIColor.systemBackground
                    }
                    .listStyle(PlainListStyle())
                } else {
                    VStack(spacing: 8) {
                        Text(L10n.cdwTxtExtauthSelectionEmptyListHeadline)
                            .multilineTextAlignment(.center)
                            .font(.headline)

                        Text(L10n.cdwTxtExtauthSelectionEmptyListDescription)
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                }

                Spacer()

                GreyDivider()

                PrimaryTextButton(
                    text: L10n.cdwBtnExtauthSelectionContinue,
                    a11y: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionConfirm,
                    isEnabled: viewStore.state.selectedKK != nil
                ) {
                    // workaround: dismiss keyboard to fix safearea bug for iOS 16
                    if #available(iOS 16, *) {
                        UIApplication.shared.dismissKeyboard()
                    }
                    viewStore.send(.confirmKK)
                }
                .padding()

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(
                        get: { viewStore.state.routeTag == .egk },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    )) {
                        NavigationView {
                            IfLetStore(
                                store.scope(
                                    state: (\CardWallExtAuthSelectionDomain.State.route)
                                        .appending(path: /CardWallExtAuthSelectionDomain.Route.egk)
                                        .extract(from:),
                                    action: CardWallExtAuthSelectionDomain.Action.egkAction(action:)
                                ),
                                then: OrderHealthCardView.init(store:)
                            )
                        }.navigationViewStyle(StackNavigationViewStyle())
                    }
                    .hidden()
                    .accessibility(hidden: true)
            }

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: (\CardWallExtAuthSelectionDomain.State.route)
                            .appending(path: /CardWallExtAuthSelectionDomain.Route.confirmation)
                            .extract(from:),
                        action: CardWallExtAuthSelectionDomain.Action.confirmation
                    ),
                    then: CardWallExtAuthConfirmationView.init
                ),
                tag: CardWallExtAuthSelectionDomain.Route.Tag.confirmation,
                selection: viewStore.binding(
                    get: \.routeTag
                ) {
                    .setNavigation(tag: $0)
                }
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
                ProgressView()
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
        let error: IDPError
        let action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Text(error.localizedDescriptionWithErrorList)
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

                switch error {
                case .notAvailableInDemoMode:
                    EmptyView()
                default:
                    Button(action: action) {
                        Text(L10n.cdwBtnExtauthSelectionRetry)
                            .font(.subheadline)
                    }
                    .accessibility(identifier: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionRetry)
                }
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
                    //                    .init(name: "Gematik KK", identifier: "abc"),
//                    .init(name: "Other KK", identifier: "def"),
//                    .init(name: "Yet Another KK", identifier: "ghi"),
                ]),
                error: nil,
                selectedKK: .init(name: "Other KK", identifier: "def")),
                reducer: .empty,
                environment: CardWallExtAuthSelectionDomain.Dummies.environment
            ))
        }
    }
}
