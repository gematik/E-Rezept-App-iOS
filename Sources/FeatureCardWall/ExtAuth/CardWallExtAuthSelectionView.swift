//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import IDP
import SwiftUI
import SwiftUIIntrospect

// [REQ:BSI-eRp-ePA:O.Auth_4#4] View containing the list of insurance companies
struct CardWallExtAuthSelectionView: View {
    @Bindable var store: StoreOf<CardWallExtAuthSelectionDomain>

    var body: some View {
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
                    .listStyle(PlainListStyle())
                } else if let kkList = store.kkList,
                          !kkList.apps.isEmpty {
                    ScrollView {
                        SingleElementSectionContainer(header: {
                            VStack(spacing: 16) {
                                Header {
                                    store.send(.helpButtonTapped)
                                }

                                SearchBar(
                                    searchText: $store.searchText.sending(\.updateSearchText),
                                    prompt: L10n.cdwTxtExtauthSearchprompt.text
                                ) {}
                                    .font(.body)
                            }
                        }, content: {
                            // [REQ:gemSpec_IDP_Frontend:A_23082#5] Display of KK apps
                            if !store.filteredKKList.apps.isEmpty {
                                ForEach(store.filteredKKList.apps) { app in
                                    // [REQ:BSI-eRp-ePA:O.Auth_4#5] User selection of the insurance company
                                    Button(action: {
                                        store.send(.selectKK(app))
                                    }, label: {
                                        Label {
                                            Text(app.name)
                                                .foregroundColor(Colors.systemLabel)
                                        } icon: {
                                            let imageUrl = URL(string: app.logo ?? "")
                                            AsyncCachedImage(url: imageUrl) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                            } placeholder: {
                                                Image(
                                                    asset: Asset.CardWall.insuranceLogoPlaceholder
                                                )
                                            }
                                            .frame(width: 42, height: 42)
                                        }
                                    })
                                    .buttonStyle(.navigation)
                                    .modifier(SectionContainerCellModifier())
                                    .disabled(store.selectLoading)
                                }
                            } else {
                                VStack {
                                    Text(L10n.cdwTxtExtauthNoresultsTitle)
                                        .font(.headline)
                                        .padding(.bottom, 1)
                                    Text(L10n.cdwTxtExtauthNoresults)
                                        .font(.subheadline)
                                        .foregroundColor(Colors.systemLabelSecondary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        })
                    }
                    .onAppear {
                        store.send(.reset)
                    }
                    .scrollContentBackground(.hidden)

                    if store.selectLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }

                } else {
                    VStack(spacing: 8) {
                        Text(L10n.cdwTxtExtauthSelectionEmptyListHeadline)
                            .multilineTextAlignment(.center)
                            .font(.headline)

                        Text(L10n.cdwTxtExtauthSelectionEmptyListDescription)
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                }

                Spacer()
            }
        }
        .navigationBarItems(
            trailing: Button {
                store.send(.delegate(.close))
            } label: {
                Text(L10n.navCancel)
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
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .confirmationDialog($store.scope(
            state: \.destination?.contactSheet,
            action: \.destination.contactSheet
        ))
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
                    .foregroundColor(Colors.systemLabel)
                    .padding(.vertical, 8)
                    .accessibilityAddTraits(.isHeader)

                Text(L10n.cdwTxtExtauthSelectionDescription)
                    .font(Font.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
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
        }
    }
}

extension View {
    func destinations(store: Bindable<StoreOf<CardWallExtAuthSelectionDomain>>) -> some View {
        navigationDestination(
            item: store.scope(state: \.destination?.help, action: \.destination.help)
        ) { store in
            CardWallExtAuthHelpView(store: store)
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
                        .foregroundColor(Colors.systemLabelSecondary)
                } else {
                    Text(L10n.cdwTxtExtauthSelectionErrorFallback)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
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
                        profileId: UUID(),
                        kkList: .init(apps: [
                            KKAppDirectory.Entry(name: "abc", identifier: "123"),
                            KKAppDirectory.Entry(name: "def", identifier: "345"),
                        ]),
                        filteredKKList: .init(apps: [
                            KKAppDirectory.Entry(name: "abc", identifier: "123"),
                            KKAppDirectory.Entry(name: "def", identifier: "345"),
                        ]),
                        error: nil
                    )
                ) {
                    EmptyReducer()
                }
            )
        }
    }
}
