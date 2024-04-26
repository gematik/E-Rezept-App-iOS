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

// swiftlint:disable file_length
struct EditProfileView: View {
    let store: EditProfileDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

    init(store: EditProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let name: String
        let acronym: String
        let fullName: String?
        let insurance: String?
        let insuranceId: String?
        let image: ProfilePicture?
        let userImageData: Data?
        let color: ProfileColor
        let isLoggedIn: Bool
        let showEmptyNameWarning: Bool
        let can: String?
        let showChargeItemsSection: Bool
        let destinationTag: EditProfileDomain.Destinations.State.Tag?

        init(with state: EditProfileDomain.State) {
            name = state.name
            acronym = state.acronym
            fullName = state.fullName
            insurance = state.insurance
            can = state.can
            insuranceId = state.insuranceId
            image = state.image
            userImageData = state.userImageData
            color = state.color
            isLoggedIn = state.token != nil
            showEmptyNameWarning = state.name.lengthOfBytes(using: .utf8) == 0
            showChargeItemsSection = state.showChargeItemsSection
            destinationTag = state.destination?.tag
        }

        var hasConnectingData: Bool {
            if let fullName = fullName, !fullName.isEmpty {
                return true
            }
            if let insurance = insurance, insurance.isEmpty {
                return true
            }
            if let insuranceId = insuranceId, !insuranceId.isEmpty {
                return true
            }
            if let can = can, !can.isEmpty {
                return true
            }
            return false
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ProfilePictureView(
                    image: viewStore.image,
                    userImageData: viewStore.userImageData,
                    color: viewStore.color,
                    connection: nil,
                    style: .xxLarge,
                    isBorderOn: true
                ) {
                    viewStore.send(.setNavigation(tag: .editProfilePicture))
                }
                .padding(.top, 24)

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
                    state: /EditProfileDomain.Destinations.State.editProfilePicture,
                    action: EditProfileDomain.Destinations.Action.editProfilePictureAction,
                    onTap: { viewStore.send(.setNavigation(tag: .editProfilePicture)) },
                    destination: { store in
                        EditProfilePictureView(store: store)
                            .navigationTitle(L10n.editPictureTxt)
                            .navigationBarTitleDisplayMode(.inline)
                    },
                    label: { Text(L10n.stgBtnEditPicture) }
                )

                SingleElementSectionContainer(footer: {
                    if viewStore.showEmptyNameWarning {
                        EmptyProfileError()
                    }
                }, content: {
                    TextFieldWithDelete(
                        title: L10n.stgTxtEditProfileNamePlaceholder.key,
                        text: viewStore.binding(
                            get: \.name,
                            send: EditProfileDomain.Action.setName
                        )
                        .animation()
                    )
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileNameInput)
                })

                ConnectedProfile(viewStore: viewStore)

                if viewStore.showChargeItemsSection {
                    ChargeItemsSectionView(store: store)
                }

                LoginSectionView(store: store)

                TokenSectionView(store: store)

                Button {
                    viewStore.send(.showDeleteProfileAlert)
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
            store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
            state: /EditProfileDomain.Destinations.State.alert,
            action: EditProfileDomain.Destinations.Action.alert
        )
        .task {
            await viewStore.send(.task).finish()
        }
        .onAppear {
            viewStore.send(.onAppear)
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
        @ObservedObject var viewStore: ViewStore<EditProfileView.ViewState, EditProfileDomain.Action>

        var body: some View {
            if viewStore.hasConnectingData {
                SectionContainer(header: {
                    Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                }, content: {
                    if let fullName = viewStore.state.fullName, !fullName.isEmpty {
                        SubTitle(title: fullName, description: L10n.stgTxtEditProfileLabelName)
                            .accessibilityElement(children: .combine)
                            .accessibility(label: Text(L10n.stgTxtEditProfileLabelName))
                            .accessibility(value: Text(fullName))
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileName)
                    }
                    if let insurance = viewStore.state.insurance {
                        SubTitle(title: insurance, description: L10n.stgTxtEditProfileLabelInsuranceCompany)
                            .accessibilityElement(children: .combine)
                            .accessibility(label: Text(L10n.stgTxtEditProfileLabelInsuranceCompany))
                            .accessibility(value: Text(insurance))
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileInsuranceCompany)
                    }
                    if let can = viewStore.state.can {
                        SubTitle(title: can, description: L10n.stgTxtEditProfileLabelCan)
                            .accessibilityElement(children: .combine)
                            .accessibility(label: Text(L10n.stgTxtEditProfileLabelCan))
                            .accessibility(value: Text(can))
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileCan)
                    }
                    if let insuranceId = viewStore.state.insuranceId {
                        Button(action: {
                            UIPasteboard.general.string = insuranceId
                        }, label: {
                            Label {
                                SubTitle(title: insuranceId, description: L10n.stgTxtEditProfileLabelKvnr)
                            } icon: {
                                Image(systemName: SFSymbolName.copy)
                            }
                            .labelStyle(.trailingIconCell)
                        })
                            .accessibility(label: Text(L10n.stgTxtEditProfileLabelKvnr))
                            .accessibility(value: Text(insuranceId))
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileInsuranceId)
                    }
                })
            } else {
                Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
            }

            if viewStore.isLoggedIn {
                // [REQ:BSI-eRp-ePA:O.Tokn_6#2] Logout Button
                Button(action: {
                    viewStore.send(.delegate(.logout))
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
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLogoutInfo)
            } else {
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
    }

    private struct ChargeItemsSectionView: View {
        let store: EditProfileDomain.Store

        @ObservedObject var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

        init(store: EditProfileDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let destinationTag: EditProfileDomain.Destinations.State.Tag?

            init(state: EditProfileDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            SectionContainer(
                header: {
                    Text(L10n.stgTxtEditProfileChargeItemListSectionTitle)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgTxtEditProfileChargeItemListSectionTitle)
                },
                content: {
                    EmptyView()

                    NavigationLinkStore(
                        store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
                        state: /EditProfileDomain.Destinations.State.chargeItemList,
                        action: EditProfileDomain.Destinations.Action.chargeItemListAction,
                        onTap: { viewStore.send(.setNavigation(tag: .chargeItemList)) },
                        destination: ChargeItemListView.init(store:),
                        label: {
                            Label(
                                title: { Text(L10n.stgBtnEditProfileChargeItemList) },
                                icon: {
                                    Image(systemName: SFSymbolName.euroSign)
                                }
                            )
                        }
                    )
                    .buttonStyle(.navigation)
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile
                        .stgTxtEditProfileChargeItemListSectionShowChargeItemList)
                }
            )
        }
    }

    private struct LoginSectionView: View {
        let store: EditProfileDomain.Store

        @ObservedObject var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

        init(store: EditProfileDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let authType: EditProfileDomain.State.AuthenticationType
            let destinationTag: EditProfileDomain.Destinations.State.Tag?

            init(state: EditProfileDomain.State) {
                authType = state.authType
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            SectionContainer(header: {
                Text(L10n.stgTxtEditProfileLoginSectionTitle)
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLoginSectionTitle)
            }, footer: {
                footer
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLoginSectionShowHint)
            }, content: {
                Group {
                    switch viewStore.state.authType {
                    case .biometric:
                        Button(action: {
                            viewStore.send(.showDeleteBiometricPairingAlert)
                        }, label: {
                            Label(title: {
                                KeyValuePair(
                                    key: L10n.stgTxtEditProfileLoginActivateDescription,
                                    value: L10n.stgTxtEditProfileLoginActivateTitle
                                )
                            }, icon: {})
                        })
                    case .card:
                        Button(action: {
                            viewStore.send(.relogin)
                        }, label: {
                            Label(title: {
                                KeyValuePair(
                                    key: L10n.stgTxtEditProfileLoginActivateDescription,
                                    value: L10n.stgTxtEditProfileLoginDeactivateTitle
                                )
                            }, icon: {})
                        })
                    case .none:
                        Button(action: {
                            viewStore.send(.login)
                        }, label: {
                            Label(title: {
                                Text(L10n.stgTxtEditProfileLoginActivateDescription)
                            }, icon: {})
                        })
                            .disabled(true)
                    case .biometryNotEnrolled:
                        Label(title: {
                            Text(L10n.stgTxtEditProfileLoginActivateDescription)
                                .foregroundColor(Colors.systemGray)
                        }, icon: {})
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibility(
                    identifier: A11y.settings.editProfile.stgTxtEditProfileLoginSectionActivate
                )

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
                    state: /EditProfileDomain.Destinations.State.registeredDevices,
                    action: EditProfileDomain.Destinations.Action.registeredDevicesAction,
                    onTap: { viewStore.send(.setNavigation(tag: .registeredDevices)) },
                    destination: RegisteredDevicesView.init(store:),
                    label: {
                        Label(
                            title: { Text(L10n.stgBtnEditProfileRegisteredDevices) },
                            icon: {}
                        )
                    }
                )
                .buttonStyle(.navigation)
                .accessibilityElement(children: .combine)
                .accessibility(
                    identifier: A11y.settings.editProfile
                        .stgTxtEditProfileLoginSectionConnectedDevices
                )
            })
        }

        @ViewBuilder var footer: some View {
            switch viewStore.authType {
            case .biometryNotEnrolled:
                Text(L10n.stgTxtEditProfileLoginFootnoteBiometry)
                Button(action: {
                    guard let url = URL(string: "https://www.gematik.de/anwendungen/e-rezept/faq/"),
                          UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url)
                }, label: { Text(L10n.stgTxtEditProfileLoginFootnoteMore) })
            case .card, .none:
                Text(L10n.stgTxtEditProfileLoginFootnoteRetry)
            case .biometric:
                EmptyView()
            }
        }
    }

    // [REQ:BSI-eRp-ePA:O.Tokn_5#2] Section for Token display
    private struct TokenSectionView: View {
        let store: EditProfileDomain.Store

        @ObservedObject var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

        init(store: EditProfileDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let isLoggedIn: Bool

            init(state: EditProfileDomain.State) {
                isLoggedIn = state.token != nil
            }
        }

        var body: some View {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.stgTxtEditProfileSecuritySectionTitle)
                        .accessibilityIdentifier(A11y.settings.editProfile
                            .stgTxtEditProfileSecuritySectionTitle)
                },
                footer: {
                    if !viewStore.isLoggedIn {
                        FootnoteView(
                            text: L10n.stgTxtEditProfileSecurityShowTokensHint,
                            a11y: A11y.settings.editProfile
                                .stgTxtEditProfileSecurityShowTokensHint
                        )
                    } else {
                        EmptyView()
                    }
                },
                content: {
                    TokenSectionViewNavigation(store: store)
                }
            )
        }
    }

    private struct TokenSectionViewNavigation: View {
        let store: EditProfileDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, EditProfileDomain.Action>

        init(store: EditProfileDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let token: IDPToken?
            let destinationTag: EditProfileDomain.Destinations.State.Tag?

            init(state: EditProfileDomain.State) {
                destinationTag = state.destination?.tag
                token = state.token
            }
        }

        var body: some View {
            NavigationLinkStore(
                store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
                state: /EditProfileDomain.Destinations.State.token,
                action: EditProfileDomain.Destinations.Action.token,
                onTap: { viewStore.send(.setNavigation(tag: .token)) },
                destination: { _ in
                    IDPTokenView(token: viewStore.state.token)
                },
                label: {
                    Label(
                        title: {
                            SubTitle(
                                title: L10n.stgTxtEditProfileSecurityShowTokensLabel,
                                description: L10n.stgTxtEditProfileSecurityShowTokensDescription
                            )
                        },
                        icon: {
                            Image(systemName: SFSymbolName.key)
                        }
                    )
                }
            )
            .accessibilityElement(children: .combine)
            .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileSecuritySectionShowTokens)
            .buttonStyle(.navigation)
            .disabled(viewStore.state.token == nil)

            // [REQ:gemSpec_eRp_FdV:A_19177#2,A_19185#3] Actual Button to open the audit events
            // [REQ:BSI-eRp-ePA:O.Auth_5#2] Actual Button to open the audit events
            NavigationLinkStore(
                store.scope(state: \.$destination, action: EditProfileDomain.Action.destination),
                state: /EditProfileDomain.Destinations.State.auditEvents,
                action: EditProfileDomain.Destinations.Action.auditEventsAction,
                onTap: { viewStore.send(.setNavigation(tag: .auditEvents)) },
                destination: AuditEventsView.init(store:),
                label: {
                    Label(
                        title: {
                            SubTitle(
                                title: L10n.stgTxtEditProfileSecurityShowAuditEventsLabel,
                                description: L10n.stgTxtEditProfileSecurityShowAuditEventsDescription
                            )
                        },
                        icon: {
                            Image(systemName: SFSymbolName.arrowUpArrowDown)
                        }
                    )
                }
            )
            .buttonStyle(.navigation)
            .accessibilityElement(children: .combine)
            .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileSecuritySectionShowAuditEvents)
        }
    }
}

struct ProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                EditProfileView(
                    store: .init(
                        initialState: {
                            var state: EditProfileDomain.State = .init(profile: UserProfile.Dummies.profileE)
                            state.token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "")
                            return state
                        }()
                    ) {
                        EditProfileDomain()
                    }
                )
            }

            NavigationView {
                EditProfileView(store: EditProfileDomain.Dummies.store)
            }
        }
    }
}
