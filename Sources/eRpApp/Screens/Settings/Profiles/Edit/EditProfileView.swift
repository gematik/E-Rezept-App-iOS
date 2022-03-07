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

struct EditProfileView: View {
    let store: EditProfileDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

    init(store: EditProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let name: String
        let acronym: String
        let emoji: String?
        let fullName: String?
        let insurance: String?
        let insuranceId: String?
        let color: ProfileColor
        let isLoggedIn: Bool
        let showEmptyNameWarning: Bool

        init(with state: EditProfileDomain.State) {
            name = state.name
            acronym = state.acronym
            emoji = state.emoji
            fullName = state.fullName
            insurance = state.insurance
            insuranceId = state.insuranceId
            color = state.color
            isLoggedIn = state.token != nil
            showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0
        }
    }

    var body: some View {
        List {
            Section(header: ProfilePicturePicker(emoji: viewStore
                    .binding(get: \.emoji, send: EditProfileDomain.Action.setEmoji),
                acronym: viewStore.acronym,
                color: viewStore.color.background,
                borderColor: viewStore.color.border)) {}
                .textCase(.none)

            Section {
                TextField(L10n.stgTxtEditProfileNamePlaceholder,
                          text: viewStore.binding(
                              get: \.name,
                              send: EditProfileDomain.Action.setName
                          )
                          .animation())
            }
            .textCase(.none)

            if viewStore.showEmptyNameWarning {
                Section(header: EmptyProfileError()) {}
                    .textCase(.none)
            }

            Section(header: ConnectedProfile(viewStore: viewStore)) {}
                .textCase(.none)

            Section(
                header: SectionHeaderView(
                    text: L10n.stgTxtEditProfileBackgroundSectionTitle,
                    a11y: A11y.settings.editProfile.stgTxtEditProfileBgColorTitle
                ).padding(.bottom, 8)
            ) {
                ProfileColorPicker(color: viewStore.binding(get: \.color, send: EditProfileDomain.Action.setColor))
                    .padding(.vertical)
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileBgColorPicker)
            }
            .textCase(.none)

            TokenSectionView(store: store)

            if viewStore.isLoggedIn {
                Section(
                    header:
                    Button(action: {
                        viewStore.send(.logout)
                    }, label: {
                        Text(L10n.stgBtnEditProfileLogout)
                    })
                        .buttonStyle(DestructiveSecondaryButtonStyle())
                        .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogout),
                    footer:
                    Text(L10n.stgTxtEditProfileLogoutInfo)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                ) {}
                    .textCase(.none)
            } else {
                Section(
                    header:
                    Button(action: {
                        viewStore.send(.login)
                    }, label: {
                        Text(L10n.stgBtnEditProfileLogin)
                    })
                        .buttonStyle(DestructiveSecondaryButtonStyle())
                        .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogin)
                ) {}
                    .textCase(.none)
            }

            Section(
                footer: DestructiveTextButton(text: L10n.stgBtnEditProfileDelete) {
                    viewStore.send(.delete)
                }
                .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileDelete)
            ) {}
                .textCase(.none)
        }
        .listStyle(InsetGroupedListStyle())
        // TODO: refactor, maybe custom gestur recognizer "ontouchesbegan" // swiftlint:disable:this todo
        //            .gesture(TapGesture().onEnded {
        //                UIApplication.shared.dismissKeyboard()
        //            })
        .navigationTitle(L10n.stgTxtEditProfileTitle)
        .alert(
            store.scope(
                state:
                (\EditProfileDomain.State.route)
                    .appending(path: /EditProfileDomain.Route.alert)
                    .extract(from:)
            ),
            dismiss: EditProfileDomain.Action.dismissAlert
        )
        .onAppear {
            viewStore.send(.registerListener)
        }
    }
}

extension EditProfileView {
    private struct EmptyProfileError: View {
        var body: some View {
            Text(L10n.stgTxtEditProfileEmptyNameErrorMessage)
                .foregroundColor(Colors.red600)
                .fixedSize(horizontal: false, vertical: true)
                .transformEffect(.init(translationX: 0, y: -16))
        }
    }

    private struct ConnectedProfile: View {
        let viewStore: ViewStore<EditProfileView.ViewState, EditProfileDomain.Action>

        var body: some View {
            Text(profileSubtitle)
                .font(.footnote)
                .foregroundColor(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
                .transformEffect(.init(translationX: 0, y: -20))
        }

        var profileSubtitle: LocalizedStringKey {
            let title = [
                viewStore.state.fullName,
                viewStore.state.insuranceId,
                viewStore.state.insurance,
            ]
            .compactMap { $0 }
            .joined(separator: "\n")

            return !title.isEmpty ?
                L10n.stgTxtEditProfileNameConnection(title).key :
                L10n.stgTxtEditProfileNameConnectionPlaceholder.key
        }
    }

    private struct TokenSectionView: View {
        let store: EditProfileDomain.Store

        @ObservedObject
        var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

        init(store: EditProfileDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let token: IDPToken?
            let routeTag: EditProfileDomain.Route.Tag?
            let isLoggedIn: Bool

            init(state: EditProfileDomain.State) {
                token = state.token
                routeTag = state.route?.tag
                isLoggedIn = state.token != nil
            }
        }

        var body: some View {
            Section(
                header: SectionHeaderView(
                    text: L10n.stgTxtEditProfileSecuritySectionTitle,
                    a11y: A11y.settings.editProfile.stgTxtEditProfileSecuritySectionTitle
                ).padding(.bottom, 8),
                footer: footnote
            ) {
                NavigationLink(
                    destination: IfLetStore(tokenStore) { tokenStore in
                        WithViewStore(tokenStore) { scopedViewStore in
                            IDPTokenView(token: scopedViewStore.state)
                        }
                    },
                    tag: EditProfileDomain.Route.Tag.token,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: EditProfileDomain.Action.setNavigation
                    )
                ) {
                    HStack(spacing: 16) {
                        Image(systemName: SFSymbolName.key)
                            .font(.body.weight(.bold))
                            .foregroundColor(viewStore.isLoggedIn ? Colors.primary500 : Colors.systemLabelSecondary)
                            .frame(width: 16, height: 16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.stgTxtEditProfileSecurityShowTokensLabel)
                                .foregroundColor(highlightColor)
                            Text(L10n.stgTxtEditProfileSecurityShowTokensDescription)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileSecuritySectionShowTokens)
                }
                .disabled(viewStore.state.token == nil)
                NavigationLink(
                    destination: IfLetStore(auditEventsStore) { auditEventsStore in
                        AuditEventsView(store: auditEventsStore)
                    },
                    tag: EditProfileDomain.Route.Tag.auditEvents,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: EditProfileDomain.Action.setNavigation
                    )
                ) {
                    HStack(spacing: 16) {
                        Image(systemName: SFSymbolName.arrowUpArrowDown)
                            .font(.body.weight(.bold))
                            .foregroundColor(Colors.primary500)
                            .frame(width: 16, height: 16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.stgTxtEditProfileSecurityShowAuditEventsLabel)
                                .foregroundColor(Colors.systemLabel)
                            Text(L10n.stgTxtEditProfileSecurityShowAuditEventsDescription)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibility(
                        identifier: A11y.settings.editProfile.stgBtnEditProfileSecuritySectionShowAuditEvents
                    )
                }
            }
            .textCase(.none)
        }

        @ViewBuilder
        var footnote: some View {
            if !viewStore.isLoggedIn {
                FootnoteView(text: L10n.stgTxtEditProfileSecurityShowTokensHint,
                             a11y: A11y.settings.editProfile.stgTxtEditProfileSecurityShowTokensHint)
            } else {
                EmptyView()
            }
        }

        var highlightColor: Color {
            viewStore.isLoggedIn ? Colors.systemLabel : Colors.systemLabelSecondary
        }

        private var tokenStore: Store<IDPToken?, EditProfileDomain.Action> {
            store.scope(
                state: (\EditProfileDomain.State.route)
                    .appending(path: /EditProfileDomain.Route.token)
                    .extract(from:)
            )
        }

        private var auditEventsStore: Store<AuditEventsDomain.State?, AuditEventsDomain.Action> {
            store.scope(
                state: (\EditProfileDomain.State.route)
                    .appending(path: /EditProfileDomain.Route.auditEvents)
                    .extract(from:),
                action: EditProfileDomain.Action.auditEvents(action:)
            )
        }
    }
}

struct ProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                EditProfileView(store: EditProfileDomain.Dummies.store)
            }
            NavigationView {
                EditProfileView(store: EditProfileDomain.Dummies.store)
            }
        }
    }
}
