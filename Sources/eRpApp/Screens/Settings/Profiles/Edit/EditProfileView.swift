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
import eRpStyleKit
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
        ScrollView {
            VStack(spacing: 8) {
                ProfilePicturePicker(
                    emoji: viewStore.binding(
                        get: \.emoji,
                        send: EditProfileDomain.Action.setEmoji
                    ),
                    acronym: viewStore.acronym,
                    color: viewStore.color.background,
                    borderColor: viewStore.color.border
                )
                .padding(.top, 24)

                SingleElementSectionContainer(footer: {
                    if viewStore.showEmptyNameWarning {
                        EmptyProfileError()
                    }
                }, content: {
                    FormTextField(L10n.stgTxtEditProfileNamePlaceholder.key,
                                  text: viewStore.binding(
                                      get: \.name,
                                      send: EditProfileDomain.Action.setName
                                  )
                                  .animation())
                })

                ProfileColorPicker(color: viewStore.binding(get: \.color, send: EditProfileDomain.Action.setColor))
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileBgColorPicker)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(16)
                    .padding([.horizontal, .bottom])

                ConnectedProfile(viewStore: viewStore)

                TokenSectionView(store: store)

                Button {
                    viewStore.send(.delete)
                } label: {
                    Text(L10n.stgBtnEditProfileDelete)
                }
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: true))
                .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileDelete)
                .padding(.vertical)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .gesture(TapGesture().onEnded {
            UIApplication.shared.dismissKeyboard()
        })
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
        }
    }

    private struct ConnectedProfile: View {
        @ObservedObject
        var viewStore: ViewStore<EditProfileView.ViewState, EditProfileDomain.Action>

        var body: some View {
            if viewStore.isLoggedIn {
                SectionContainer(header: {
                    Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                }, content: {
                    if let fullName = viewStore.state.fullName {
                        SubTitle(title: fullName, description: L10n.stgTxtEditProfileLabelName)
                    }
                    if let insurance = viewStore.state.insurance {
                        SubTitle(title: insurance, description: L10n.stgTxtEditProfileLabelInsuranceCompany)
                    }
//                    Insert CAN here
//                    if let insurance = viewStore.state.insurance {
//                        SubTitle(title: insurance, description: L10n.stgTxtEditProfileLabelCan)
//                    }
                    if let insuranceId = viewStore.state.insuranceId {
                        Button(action: {
                            UIPasteboard.general.string = insuranceId
                        }, label: {
                            Label {
                                SubTitle(title: insuranceId, description: L10n.stgTxtEditProfileLabelKvnr)
                            } icon: {
                                Image(systemName: SFSymbolName.copy)
                            }
                            .labelStyle(.trailingIcon)
                        })
                    }
                })

                Button(action: {
                    viewStore.send(.logout)
                }, label: {
                    Text(L10n.stgBtnEditProfileLogout)
                })
                    .buttonStyle(eRpStyleKit.SecondaryButtonStyle(enabled: true, destructive: true))
                    .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogout)

                Text(L10n.stgTxtEditProfileLogoutInfo)
                    .padding(.horizontal)
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.bottom)
            } else {
                Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)

                Button(action: {
                    viewStore.send(.login)
                }, label: {
                    Text(L10n.stgBtnEditProfileLogin)
                })
                    .buttonStyle(.primary)
                    .padding(.bottom)
                    .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogin)
            }
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
            SectionContainer(header: {
                                 Text(L10n.stgTxtEditProfileSecuritySectionTitle)
                                     .accessibilityIdentifier(A11y.settings.editProfile
                                         .stgTxtEditProfileSecuritySectionTitle)
                             },
                             footer: {
                                 footnote
                             },
                             content: {
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
                                     Label(title: {
                                         SubTitle(title: L10n.stgTxtEditProfileSecurityShowTokensLabel,
                                                  description: L10n.stgTxtEditProfileSecurityShowTokensDescription)
                                     }, icon: {
                                         Image(systemName: SFSymbolName.key)
                                     })
                                 }
                                 .accessibilityElement(children: .combine)
                                 .accessibility(identifier: A11y.settings.editProfile
                                     .stgBtnEditProfileSecuritySectionShowTokens)
                                 .buttonStyle(.navigation)
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
                                     Label(title: {
                                         SubTitle(title: L10n.stgTxtEditProfileSecurityShowAuditEventsLabel,
                                                  description: L10n.stgTxtEditProfileSecurityShowAuditEventsDescription)
                                     }, icon: {
                                         Image(systemName: SFSymbolName.arrowUpArrowDown)
                                     })
                                 }
                                 .buttonStyle(.navigation)
                                 .accessibilityElement(children: .combine)
                                 .accessibility(
                                     identifier: A11y.settings.editProfile
                                         .stgBtnEditProfileSecuritySectionShowAuditEvents
                                 )

                             })
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
                EditProfileView(store: EditProfileDomain.Store(initialState: EditProfileDomain.Dummies.onlineState,
                                                               reducer: .empty,
                                                               environment: EditProfileDomain.Dummies.environment))
            }
        }
    }
}
