//
//  Copyright (c) 2024 gematik GmbH
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
import eRpStyleKit
import IDP
import SwiftUI
import SwiftUIIntrospect

// [REQ:BSI-eRp-ePA:O.Auth_4#4] View containing the list of insurance companies
struct CardWallExtAuthSelectionView: View {
    @Perception.Bindable var store: StoreOf<CardWallExtAuthSelectionDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if let error = store.error {
                    ErrorView(error: error) {
                        store.send(.loadKKList, animation: .default)
                    }
                    .padding()
                } else {
                    if store.kkList == nil {
                        List {
                            Section(header: CenteredActivityIndicator()) {}
                        }
                        .listStyle(GroupedListStyle())
                        .introspect(.list, on: .iOS(.v15)) { tableView in
                            tableView.separatorStyle = .none
                            tableView.tableHeaderView = nil
                            tableView.backgroundColor = UIColor.systemBackground
                        }
                        .listStyle(PlainListStyle())
                    } else if let kkList = store.kkList,
                              !kkList.apps.isEmpty {
                        SearchBar(
                            searchText: $store.searchText.sending(\.updateSearchText),
                            prompt: L10n.cdwTxtExtauthSearchprompt.key
                        ) {}
                            .padding()

                        List {
                            Section(header: Header {
                                store.send(.helpButtonTapped)
                            }) {
                                // [REQ:gemSpec_IDP_Frontend:A_23082#5] Display of KK apps
                                if !store.filteredKKList.apps.isEmpty {
                                    ForEach(store.filteredKKList.apps) { app in
                                        WithPerceptionTracking {
                                            // [REQ:BSI-eRp-ePA:O.Auth_4#5] User selection of the insurance company
                                            Button(action: {
                                                store.send(.selectKK(app))
                                            }, label: {
                                                HStack {
                                                    Text(app.name)
                                                        .foregroundColor(Color(.label))

                                                    Spacer()

                                                    if store.selectedKK?.identifier == app.identifier {
                                                        Image(systemName: SFSymbolName.checkmark)
                                                    }
                                                }.contentShape(Rectangle())
                                            })
                                        }
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
                        .listStyle(GroupedListStyle())
                        .introspect(.list, on: .iOS(.v15)) { tableView in
                            tableView.separatorStyle = .none
                            tableView.tableHeaderView = nil
                            tableView.backgroundColor = UIColor.systemBackground
                        }

                        .listStyle(PlainListStyle())
                        .onAppear {
                            store.send(.reset)
                        }

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
                        isEnabled: store.state.selectedKK != nil
                    ) {
                        // workaround: dismiss keyboard to fix safearea bug for iOS 16
                        if #available(iOS 16, *) {
                            UIApplication.shared.dismissKeyboard()
                        }
                        store.send(.confirmKK)
                    }
                    .padding()
                }
            }
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    store.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionCancel)
                .accessibility(label: Text(L10n.cdwBtnExtauthSelectionCancel))
            )
            .navigationTitle(L10n.cdwTxtExtauthSelectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.send(.loadKKList)
            }
            .destinations(store: $store)
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

                Button {
                    action()
                } label: {
                    Label(L10n.cdwBtnExtauthSelectionHelp, systemImage: SFSymbolName.arrowForward)
                        .labelStyle(.trailingIcon)
                }
                .font(.subheadline)
                .foregroundColor(Colors.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityIdentifier(A11y.cardWall.extAuthSelection.cdwBtnExtauthSelectionHelp)
            }
            .padding(.bottom, 16)
        }
    }
}

extension View {
    func destinations(store: Perception.Bindable<StoreOf<CardWallExtAuthSelectionDomain>>) -> some View {
        navigationDestination(
            item: store.scope(state: \.destination?.help, action: \.destination.help)
        ) { _ in
            CardWallExtAuthHelpView()
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.confirmation, action: \.destination.confirmation)
        ) { store in
            CardWallExtAuthConfirmationView(store: store)
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
        NavigationStack {
            CardWallExtAuthSelectionView(
                store: StoreOf<CardWallExtAuthSelectionDomain>(
                    initialState: .init(
                        kkList: .init(apps: [KKAppDirectory.Entry(name: "abc", identifier: "123")]),
                        filteredKKList: .init(apps: [KKAppDirectory.Entry(name: "abc", identifier: "123")]),
                        error: nil,
                        selectedKK: .init(name: "Other KK", identifier: "def")
                    )
                ) {
                    EmptyReducer()
//                    CardWallExtAuthSelectionDomain()
                }
            )
        }
    }
}
