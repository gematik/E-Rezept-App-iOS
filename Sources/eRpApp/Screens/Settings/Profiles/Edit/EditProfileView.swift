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

struct EditProfileView: View {
    @Perception.Bindable var store: StoreOf<EditProfileDomain>

    var showChargeItemsSection: Bool {
        switch store.insuranceType {
        case .pKV: return true
        case .gKV, .unknown: return false
        }
    }

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 8) {
                    ProfilePictureView(
                        image: store.image,
                        userImageData: store.userImageData,
                        color: store.color,
                        connection: nil,
                        style: .xxLarge,
                        isBorderOn: true
                    ) {
                        store.send(.editProfilePictureTapped)
                    }
                    .padding(.top, 24)

                    NavigationLink(item: $store.scope(state: \.destination?.editProfilePicture,
                                                      action: \.destination.editProfilePicture),
                                   onTap: { store.send(.editProfilePictureTapped) },
                                   destination: { store in
                                       EditProfilePictureView(store: store)
                                           .navigationTitle(L10n.editPictureTxt)
                                           .navigationBarTitleDisplayMode(.inline)
                                   },
                                   label: { Text(L10n.stgBtnEditPicture) })

                    SingleElementSectionContainer(footer: {
                        WithPerceptionTracking {
                            if store.name.lengthOfBytes(using: .utf8) == 0 {
                                EmptyProfileError()
                            }
                        }
                    }, content: {
                        TextFieldWithDelete(
                            title: L10n.stgTxtEditProfileNamePlaceholder.key,
                            text: $store.name
                        )
                        .animation(.easeInOut, value: store.name)
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileNameInput)
                    })

                    ConnectedProfile(store: store)

                    if showChargeItemsSection {
                        ChargeItemsSectionView(store: store)
                    }

                    LoginSectionView(store: store)

                    TokenSectionView(store: store)

                    Button {
                        store.send(.showDeleteProfileAlert)
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
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .task {
                await store.send(.task).finish()
            }
            .onAppear {
                store.send(.onAppear)
            }
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
        @Perception.Bindable var store: StoreOf<EditProfileDomain>

        var hasConnectingData: Bool {
            if let fullName = store.fullName, !fullName.isEmpty {
                return true
            }
            if let insurance = store.insurance, insurance.isEmpty {
                return true
            }
            if let insuranceId = store.insuranceId, !insuranceId.isEmpty {
                return true
            }
            if let can = store.can, !can.isEmpty {
                return true
            }
            return false
        }

        var body: some View {
            WithPerceptionTracking {
                if hasConnectingData {
                    SectionContainer(header: {
                        Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                    }, content: {
                        if let fullName = store.fullName, !fullName.isEmpty {
                            SubTitle(title: fullName, description: L10n.stgTxtEditProfileLabelName)
                                .accessibilityElement(children: .combine)
                                .accessibility(label: Text(L10n.stgTxtEditProfileLabelName))
                                .accessibility(value: Text(fullName))
                                .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileName)
                        }
                        if let insurance = store.insurance {
                            SubTitle(title: insurance, description: L10n.stgTxtEditProfileLabelInsuranceCompany)
                                .accessibilityElement(children: .combine)
                                .accessibility(label: Text(L10n.stgTxtEditProfileLabelInsuranceCompany))
                                .accessibility(value: Text(insurance))
                                .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileInsuranceCompany)
                        }
                        if let can = store.can {
                            SubTitle(title: can, description: L10n.stgTxtEditProfileLabelCan)
                                .accessibilityElement(children: .combine)
                                .accessibility(label: Text(L10n.stgTxtEditProfileLabelCan))
                                .accessibility(value: Text(can))
                                .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileCan)
                        }
                        if let insuranceId = store.insuranceId {
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

                if store.token != nil {
                    Button(action: {
                        store.send(.delegate(.logout))
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
                        store.send(.login)
                    }, label: {
                        Text(L10n.stgBtnEditProfileLogin)
                    })
                        .buttonStyle(.primary)
                        .padding(.bottom)
                        .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogin)
                }
            }
        }
    }

    private struct ChargeItemsSectionView: View {
        @Perception.Bindable var store: StoreOf<EditProfileDomain>

        var body: some View {
            WithPerceptionTracking {
                SectionContainer(
                    header: {
                        Text(L10n.stgTxtEditProfileChargeItemListSectionTitle)
                            .accessibility(identifier: A11y.settings.editProfile
                                .stgTxtEditProfileChargeItemListSectionTitle)
                    },
                    content: {
                        EmptyView()

                        NavigationLink(item: $store.scope(state: \.destination?.chargeItemList,
                                                          action: \.destination.chargeItemList),
                                       onTap: { store.send(.chargeItemListTapped) },
                                       destination: { store in
                                           ChargeItemListView(store: store)
                                       },
                                       label: { Label(
                                           title: { Text(L10n.stgBtnEditProfileChargeItemList) },
                                           icon: {
                                               Image(systemName: SFSymbolName.euroSign)
                                           }
                                       )
                                       })
                            .buttonStyle(.navigation)
                            .accessibilityElement(children: .combine)
                            .accessibility(identifier: A11y.settings.editProfile
                                .stgTxtEditProfileChargeItemListSectionShowChargeItemList)
                    }
                )
            }
        }
    }

    private struct LoginSectionView: View {
        @Perception.Bindable var store: StoreOf<EditProfileDomain>

        enum AuthenticationType: Equatable {
            case biometric
            case card
            case biometryNotEnrolled(String)
            case none
        }

        var authType: AuthenticationType {
            if let error = store.securityOptionsError {
                return .biometryNotEnrolled(error.localizedDescriptionWithErrorList)
            }
            if store.hasBiometricKeyID == true {
                return .biometric
            }
            if store.token != nil {
                return .card
            }
            return .none
        }

        var body: some View {
            WithPerceptionTracking {
                SectionContainer(header: {
                    Text(L10n.stgTxtEditProfileLoginSectionTitle)
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLoginSectionTitle)
                }, footer: {
                    WithPerceptionTracking {
                        FooterView(authType: authType)
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLoginSectionShowHint)
                    }
                }, content: {
                    WithPerceptionTracking {
                        switch authType {
                        case .biometric:
                            Button(action: {
                                store.send(.showDeleteBiometricPairingAlert)
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
                                store.send(.relogin)
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
                                store.send(.login)
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
                    NavigationLink(item: $store.scope(state: \.destination?.registeredDevices,
                                                      action: \.destination.registeredDevices),
                                   onTap: { store.send(.registeredDevicesTapped) },
                                   destination: { store in
                                       RegisteredDevicesView(store: store)
                                   },
                                   label: { Label(
                                       title: { Text(L10n.stgBtnEditProfileRegisteredDevices) },
                                       icon: {}
                                   )
                                   }).buttonStyle(.navigation)
                        .accessibilityElement(children: .combine)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgTxtEditProfileLoginSectionConnectedDevices)
                })
            }
        }

        private struct FooterView: View {
            var authType: AuthenticationType

            var body: some View {
                WithPerceptionTracking {
                    switch authType {
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
        }
    }

    private struct TokenSectionView: View {
        @Perception.Bindable var store: StoreOf<EditProfileDomain>

        var body: some View {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.stgTxtEditProfileSecuritySectionTitle)
                        .accessibilityIdentifier(A11y.settings.editProfile
                            .stgTxtEditProfileSecuritySectionTitle)
                },
                footer: {
                    WithPerceptionTracking {
                        if store.token == nil {
                            FootnoteView(
                                text: L10n.stgTxtEditProfileSecurityShowTokensHint,
                                a11y: A11y.settings.editProfile
                                    .stgTxtEditProfileSecurityShowTokensHint
                            )
                        } else {
                            EmptyView()
                        }
                    }
                },
                content: {
                    TokenSectionViewNavigation(store: store)
                }
            )
        }
    }

    private struct TokenSectionViewNavigation: View {
        @Perception.Bindable var store: StoreOf<EditProfileDomain>

        var body: some View {
            WithPerceptionTracking {
                NavigationLink(item: $store.scope(state: \.destination?.token,
                                                  action: \.destination.token),
                               onTap: { store.send(.tokenViewTapped) },
                               destination: { scopedStore in
                                   IDPTokenView(store: scopedStore)
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
                               })
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileSecuritySectionShowTokens)
                    .buttonStyle(.navigation)
                    .disabled(store.state.token == nil)

                // [REQ:gemSpec_eRp_FdV:A_19177#2,A_19185#3] Actual Button to open the audit events
                // [REQ:BSI-eRp-ePA:O.Auth_6#2] Actual Button to open the audit events
                NavigationLink(item: $store.scope(state: \.destination?.auditEvents,
                                                  action: \.destination.auditEvents),
                               onTap: { store.send(.auditEventsTapped) },
                               destination: { store in AuditEventsView(store: store) },
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
                               })
                    .buttonStyle(.navigation)
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile
                        .stgBtnEditProfileSecuritySectionShowAuditEvents)
            }
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
